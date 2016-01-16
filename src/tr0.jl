#EDAData: TR0 Reader Interface
#-------------------------------------------------------------------------------


#==Main data structures
===============================================================================#
type Tr0Reader <: AbstractReader{Tr0Fmt}
	reader::CppSimData.DataReader
	x::Vector
end


#==Open/read/close functions
===============================================================================#
function Base.open(::Type{Tr0Reader}, path::AbstractString)
	reader = CppSimData.loadsig(path)
	xname = CppSimData.lssig(reader)[1]
	x = CppSimData.evalsig(reader, xname)
	return Tr0Reader(reader, x)
end
_open(file::File{Tr0Fmt}) = open(Tr0Reader, file.path) #Use Tr0 reader from this module.
_open(fn::Function, file::File{Tr0Fmt}) = open(fn, Tr0Reader, file.path) #For do/end method

function Base.read(r::Tr0Reader, signame::ASCIIString)
	y = CppSimData.evalsig(r.reader, signame)
	return DataF1(r.x, y)
end

Base.close(r::Tr0Reader) = return #No close interface provided by library


#==Accessors
===============================================================================#
Base.names(r::Tr0Reader) = CppSimData.lssig(r.reader)[2:end]


#==Generate friendly show functions
===============================================================================#
function Base.show(io::IO, r::Tr0Reader)
	print(io, "Tr0Reader($(r.reader.filename), nsig=$(r.reader.nsig) npts=$(r.reader.npts))")
end

#Last line
