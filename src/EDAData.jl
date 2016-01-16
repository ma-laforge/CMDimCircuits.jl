#EDAData
#-------------------------------------------------------------------------------

module EDAData

import CppSimData #tr0 reader implementation
import LibPSF #psf reader implementation
using FileIO2
using MDDatasets


include("base.jl")
include("tr0.jl")
include("psf.jl")
include("snp_reader.jl")
include("snp_writer.jl")
include("show.jl")


#==Exported symbols
===============================================================================#
export parameter_type


#==Un-exported interface
================================================================================
	type: NetworkParameterMatrix{T, NPTYPE}

	_open(...) #Ensures EDAData opens file.
	_open(File(:tr0/:psf, path::AbstractString)) #Opens {Tr0Reader/PSFReader}

	_read(File(:sNp, path::AbstractString), numports=X) #Returns NetworkParameterMatrix
==#


#==Extensions to other modules
================================================================================
	FileIO2.File(:tr0/:psf/:sNp, filename::AbstractString)

	Base.read(::{Tr0Reader/PSFReader}, signame::ASCIIString)
	Base.names(::{Tr0Reader/PSFReader}) #Returns list of signal names
	Base.close(::{Tr0Reader/PSFReader})
==#


end #EDAData
