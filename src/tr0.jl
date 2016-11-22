#EDAData: TR0 Reader Interface
#-------------------------------------------------------------------------------


#==Main data structures
===============================================================================#
type Tr0Reader <: AbstractReader{Tr0Fmt}
	reader::SpiceData.DataReader
end


#==Open/read/close functions
===============================================================================#
function Base.open(::Type{Tr0Reader}, path::String)
	return Tr0Reader(SpiceData._open(path))
end
_open(file::File{Tr0Fmt}) = open(Tr0Reader, file.path) #Use Tr0 reader from this module.
_open(fn::Function, file::File{Tr0Fmt}) = open(fn, Tr0Reader, file.path) #For do/end method

function Base.read(r::Tr0Reader, signame::String)
	y = read(r.reader, signame)
	return DataF1(r.reader.sweep, y)
end

Base.close(r::Tr0Reader) = close(r.reader)


#==Accessors
===============================================================================#
Base.names(r::Tr0Reader) = r.reader.signalnames


#==Generate friendly show functions
===============================================================================#
function Base.show(io::IO, r::Tr0Reader)
	print(io, "Tr0Reader:", r.reader)
end

#Last line
