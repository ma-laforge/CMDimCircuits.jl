#EDAData: PSF Reader Interface
#-------------------------------------------------------------------------------


#==Main data structures
===============================================================================#
type PSFReader <: AbstractReader{PSFFmt}
	reader::PSFReaderLib.DataReader
	x::Vector
end


#==Open/read/close functions
===============================================================================#
function Base.open(::Type{PSFReader}, path::AbstractString)
	local x
	reader = PSFReaderLib._open(path)
	try
		x = PSFReaderLib.readsweep(reader)
	catch
		x = Void[] #No sweep
	end
	return PSFReader(reader, x)
end
_open(file::File{PSFFmt}) = open(PSFReader, file.path) #Use PSF reader from this module.
_open(fn::Function, file::File{PSFFmt}) = open(fn, PSFReader, file.path) #For do/end method

function Base.read(r::PSFReader, signame::ASCIIString)
#	if typeof(r.x) <: Vector{Void}
		#Very hacky... Figure out something better
#		return PSFReaderLib.readscalar(r.reader, signame)
#	end
	y = read(r.reader, signame)
	return DataF1(r.x, y)
end

Base.close(r::PSFReader) = return #No close interface provided by library


#==Accessors
===============================================================================#
Base.names(r::PSFReader) = names(r.reader)


#==Generate friendly show functions
===============================================================================#
function Base.show(io::IO, r::PSFReader)
	print(io, "PSFReader($(r.reader.filepath))")
end

#Last line
