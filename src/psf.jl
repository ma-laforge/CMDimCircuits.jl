#EDAData: PSF Reader Interface
#-------------------------------------------------------------------------------


#==Main data structures
===============================================================================#
mutable struct PSFReader <: AbstractReader{PSFFmt}
	reader::PSFReaderLib.DataReader
	x::Vector
end


#==Open/read/close functions
===============================================================================#
function Base.open(::Type{PSFReader}, path::String)
	local x
	reader = PSFReaderLib._open(path)
	try
		x = PSFReaderLib.readsweep(reader)
	catch
		x = Nothing[] #No sweep
	end
	return PSFReader(reader, x)
end
_open(file::File{PSFFmt}) = open(PSFReader, file.path) #Use PSF reader from this module.
_open(fn::Function, file::File{PSFFmt}) = open(fn, PSFReader, file.path) #For do/end method

function Base.read(r::PSFReader, signame::String)
#	if typeof(r.x) <: Vector{Nothing}
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
