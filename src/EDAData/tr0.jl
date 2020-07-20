#EDAData: TR0 Reader Interface
#-------------------------------------------------------------------------------


#==Main data structures
===============================================================================#
mutable struct Tr0Reader
	reader::SpiceData.DataReader
end


#==Open/read/close functions
===============================================================================#
function Base.open(::Type{Tr0Reader}, path::String)
	return Tr0Reader(SpiceData._open(path))
end

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


#==High-level interface
===============================================================================#
open_tr0(path::String) = open(Tr0Reader, path) #Use Tr0 reader from this module.
open_tr0(fn::Function, path::String) = open(fn, Tr0Reader, path) #For do/end method

#Last line
