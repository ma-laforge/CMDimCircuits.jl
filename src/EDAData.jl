#EDAData
#-------------------------------------------------------------------------------

module EDAData

import CppSimData #tr0 reader implementation
import LibPSF #psf reader implementation
using FileIO2
using MDDatasets

#==Main data structures
===============================================================================#

#TODO: Improve, and move to a NetworkParameter module
type NetworkParameterMatrix{T, NPTYPE} #NPTYPE: :S/:Y/:Z/...
	ref #Port reference
	d::Array{T}
end
call{T, NT}(::Type{NetworkParameterMatrix{T, NT}}, numports::Integer; ref=50) =
	NetworkParameterMatrix{T, NT}(ref, Array(T, numports, numports))

parameter_type{T, NT}(::Type{NetworkParameterMatrix{T, NT}}) = NT
parameter_type{T, NT}(::NetworkParameterMatrix{T, NT}) = NT

include("tr0.jl")
include("psf.jl")
include("snp_reader.jl")
include("show.jl")


#==Exported symbols
===============================================================================#
export parameter_type

#==Un-exported interface
================================================================================
	_open(::File{Tr0Fmt/PSFFmt})::{Tr0Reader/PSFReader} #Ensure EDAData opens file.
==#

#==Extensions to other modules
================================================================================
	FileIO2.File(:tr0/:psf, filename::AbstractString)
	Base.open(Tr0Reader/PSFReader, ::File{Tr0Fmt})::{Tr0Reader/PSFReader}
	Base.read(::{Tr0Reader/PSFReader}, signame::ASCIIString)
	Base.close(::{Tr0Reader/PSFReader})
	Base.names(::{Tr0Reader/PSFReader}) #Returns list of signal names
==#


end #EDAData
