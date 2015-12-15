#EDAData
#-------------------------------------------------------------------------------

module EDAData

import CppSimData #tr0 reader implementation
import LibPSF #psf reader implementation
using FileIO2
using MDDatasets

include("tr0.jl")
include("psf.jl")

#==Exported symbols
===============================================================================#
#None

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
