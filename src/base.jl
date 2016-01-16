#EDAData: base types & core functions
#-------------------------------------------------------------------------------


#==Useful constants
===============================================================================#


#==Main data structures
===============================================================================#
immutable Tr0Fmt <: FileIO2.DataFormat; end
immutable PSFFmt <: FileIO2.DataFormat; end
immutable SNPFmt <: FileIO2.TextFormat{FileIO2.ASCIIEncoding}; end

#Add Shorthand File constructors:
FileIO2.File(::FileIO2.Shorthand{:tr0}, path::AbstractString) = File{Tr0Fmt}(path)
FileIO2.File(::FileIO2.Shorthand{:psf}, path::AbstractString) = File{PSFFmt}(path)
FileIO2.File(::FileIO2.Shorthand{:sNp}, path::AbstractString) = File{SNPFmt}(path)


#TODO: Improve, and move to a NetworkParameter module
type NetworkParameterMatrix{T, NPTYPE} #NPTYPE: :S/:Y/:Z/...
	ref::Real #Port reference
	d::Array{T, 2}
end
call{T, NT}(::Type{NetworkParameterMatrix{T, NT}}, numports::Integer; ref::Real=50) =
	NetworkParameterMatrix{T, NT}(ref, Array(T, numports, numports))


#==Accessors
===============================================================================#
parameter_type{T, NT}(::Type{NetworkParameterMatrix{T, NT}}) = NT
parameter_type{T, NT}(::NetworkParameterMatrix{T, NT}) = NT


#Last Line
