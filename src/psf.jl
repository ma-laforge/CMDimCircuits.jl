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
function Base.open(::Type{PSFReader}, path::AbstractString)
	local x
	reader = LibPSF._open(path)
	try
		x = LibPSF.readsweep(reader)
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
#		return LibPSF.readscalar(r.reader, signame)
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
