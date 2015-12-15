#EDAData: PSF Reader Interface
#-------------------------------------------------------------------------------


#==Main data structures
===============================================================================#
immutable PSFFmt <: FileIO2.DataFormat; end
#Add Shorthand File constructor:
FileIO2.File(::FileIO2.Shorthand{:psf}, path::AbstractString) = File{PSFFmt}(path)
#TODO: centralize this PSFFmt/Shorthand definition?

type PSFReader <: AbstractReader{PSFFmt}
	reader::LibPSF.DataReader
	x::Vector
end


#==Open/read/close functions
===============================================================================#
function Base.open(::Type{PSFReader}, file::File{PSFFmt})
	reader = LibPSF._open(file.path)
	x = LibPSF.readsweep(reader)
	return PSFReader(reader, x)
end
_open(file::File{PSFFmt}) = open(PSFReader, file) #Guarantee open psf with this module.
_open(fn::Function, file::File{PSFFmt}) = open(fn, PSFReader, file) #For do/end method

function Base.read(r::PSFReader, signame::ASCIIString)
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
