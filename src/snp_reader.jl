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

mutable struct SNPReader <: AbstractReader{SNPFmt}
	r::FileIO2.TextReader
	numports::Int
end


#==Helper functions
===============================================================================#
iscomment(line::String) = length(line) < 1 || '!' == line[1]

#Read mangitude/angle data
snp_read_ma(r::SNPReader) = read(r.r, DataFloat) * e^(im*read(r.r, DataFloat))

#Read dB/angle data
snp_read_db(r::SNPReader) = 10^(read(r.r, DataFloat)/20) * e^(im*read(r.r, DataFloat))

#Read real/imaginary data
snp_read_ri(r::SNPReader) = complex(read(r.r, DataFloat), read(r.r, DataFloat))

const SNP_READ_MAP = Dict("MA"=>snp_read_ma, "DB"=>snp_read_db, "RI"=>snp_read_ri)


#==Open/read/close functions
===============================================================================#
#TODO: Should "open" read all header info???
function Base.open(::Type{SNPReader}, path::String; numports=0)
	#TODO: autodetect numports from path
	if numports < 1
		error("Must specify number of ports > 0")
	end
	#Open with specific reader to ensure consistent behaviour:
	r = open(FileIO2.TextReader, path)
	return SNPReader(r, numports)
end
_open(file::File{SNPFmt}, args...; kwargs...) = #Open .sNp with this module.
	open(SNPReader, file.path, args...; kwargs...)

Base.close(r::SNPReader) = close(r.r)

function Base.read(::Type{SNPReader}, path::String; numports=0)
	reader = open(SNPReader, path, numports=numports)
	try
		return readall(reader)
	finally
		close(reader)
	end
end
_read(file::File{SNPFmt}, args...; kwargs...) = #read .sNp with this module.
	read(SNPReader, file.path, args...; kwargs...)


#==Main reader algorithm
===============================================================================#
#Returns DataF1 instead of DataFreq... in case step size is not constant.
function readall(r::SNPReader)
	const str = String
	x = DataFloat[]
	y = Array{Vector{Complex{DataFloat}}}(r.numports,r.numports)

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
	m = Array{DataF1}(r.numports, r.numports)
	for row = 1:r.numports, col = 1:r.numports
		m[row, col] = DataF1(x, y[row, col])
	end

	istwoport = (2==r.numports)
	if istwoport
		#Special case: columns represent x11, x21, x12, x22... gross...
		x21 = m[1,2]
		m[1,2] = m[2,1]
		m[2,1] = x21
	end

	nwkwargs = Dict()
	nptype = Symbol(nptype)
	if :S == nptype
		push!(nwkwargs, :z0 => refres)
	end

	return Network(nptype, m; nwkwargs...)
end

#Last line
