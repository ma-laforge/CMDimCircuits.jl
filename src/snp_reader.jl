#EDAData: .sNp (Touchstone) file reader
#-------------------------------------------------------------------------------
#=Notes:
   -Since .sNp files don't store # of lines (read until EOF), the algorithm uses
    push!() to read in data files.  TODO: Change algorithm if push!(::Vector)
    implementation is too slow.
=#


#==Constants
===============================================================================#
const SNP_FSCALE_MAP = Dict("GHZ"=>1e9, "MHZ"=>1e6, "KHZ"=>1e3, "HZ"=>1)


#==Main data structures
===============================================================================#
immutable SNPFmt <: FileIO2.TextFormat{FileIO2.ASCIIEncoding}; end
#Add Shorthand File constructor:
FileIO2.File(::FileIO2.Shorthand{:sNp}, path::AbstractString) = File{SNPFmt}(path)
#TODO: centralize this SNPFmt/Shorthand definition?

type SNPReader <: AbstractReader{SNPFmt}
	r::FileIO2.TextReader
	numports::Int
end


#==Helper functions
===============================================================================#
iscomment(line::AbstractString) = length(line) < 1 || '!' == line[1]

#Read mangitude/angle data
snp_read_ma(r::SNPReader) = read(r.r, DataFloat) * e^(im*read(r.r, DataFloat))

#Read dB/angle data
snp_read_db(r::SNPReader) = 10^(read(r.r, DataFloat)/20) * e^(im*read(r.r, DataFloat))

#Read real/imaginary data
snp_read_ri(r::SNPReader) = complex(read(r.r, DataFloat), read(r.r, DataFloat))

const SNP_READ_MAP = Dict("MA"=>snp_read_ma, "DB"=>snp_read_db, "RI"=>snp_read_ri)


#==Open/read/close functions
===============================================================================#
function Base.open(::Type{SNPReader}, path::AbstractString; numports=0)
	#TODO: autodetect numports from path
	if numports < 1
		error("Must specify number of ports > 0")
	end
	#Open with specific reader to ensure consistent behaviour:
	r = open(FileIO2.TextReader, path)
	return SNPReader(r, numports)
end
_open(file::File{SNPFmt}; numports=0) = #Open .sNp with this module.
	open(SNPReader, file.path, numports=numports)

Base.close(r::SNPReader) = close(r.r)


#==Main reader algorithm
===============================================================================#
#Returns DataF1 instead of DataFreq... in case step size is not constant.
function Base.readall(r::SNPReader)
	const str = AbstractString
	x = DataFloat[]
	y = Array(Vector{Complex{DataFloat}}, r.numports,r.numports)

	for row = 1:r.numports, col = 1:r.numports
		y[row, col] = Complex{DataFloat}[]
	end

	line = ""
	while iscomment(line)
		line = lstrip(readline(r.r))
	end

	if !(length(line) < 1 || '#' == line[1])
		error("Options line not found where expected.")
	end

	line = strip(line[2:end])

	local xunit, nptype, datafmt, refres
	optreader = FileIO2.TextReader(IOBuffer(line))
	try
		xunit = uppercase(read(optreader, str))
		nptype = uppercase(read(optreader, str))
		datafmt = uppercase(read(optreader, str))
		refres = uppercase(read(optreader, str))
		refres = read(optreader, DataFloat)
	catch e
		rethrow(e)
	finally
		close(optreader)
	end

	snp_read = SNP_READ_MAP[datafmt]

	#Move to data start:
	line = ""
	datastart = 0
	while iscomment(line)
		datastart = position(r.r.s)
		line = lstrip(readline(r.r))
	end
	seek(r.r.s, datastart)

	#Read all data:
	while !eof(r.r)
		#TODO: push! algorithm potentially slow...
		push!(x, read(r.r, DataFloat))

		for row = 1:r.numports, col = 1:r.numports
			push!(y[row, col], snp_read(r))
		end
	end

	x = x .* SNP_FSCALE_MAP[xunit]
	result = NetworkParameterMatrix{DataF1, symbol(nptype)}(r.numports, ref=refres)
	for row = 1:r.numports, col = 1:r.numports
		result.d[row, col] = DataF1(x, y[row, col])
	end

	return result
end

#Last line
