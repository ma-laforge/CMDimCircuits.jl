#EDAData
#-------------------------------------------------------------------------------
__precompile__(true)

#=
TAGS:
	#WANTCONST, HIDEWARN_0.7
=#

module EDAData

const defaultPSFReader = :LibPSF #Overwrite with LibPSFC to use alternative algorithm

import SpiceData #SPICE data reader

#Import PSF reader implementation as "PSFReaderLib" (Hacky, but works):
eval(:(using $defaultPSFReader))
eval(:(const PSFReaderLib = $defaultPSFReader))

using FileIO2
using NetwAnalysis
using MDDatasets

import NetwAnalysis: NetworkParameters, NetworkParametersRef, NetworkParametersNoRef
import Dates: now


include("base.jl")
include("tr0.jl")
include("psf.jl")
include("snp_reader.jl")
include("snp_writer.jl")
include("show.jl")


#==Exported symbols
===============================================================================#


#==Un-exported interface
================================================================================
	_open(...) #Ensures EDAData opens file.
	_open(File(:tr0/:psf, path::String)) #Opens {Tr0Reader/PSFReader}

	_read(File(:sNp, path::String), numports=X) #Returns NetworkParameters matrix
==#


#==Extensions to other modules
================================================================================
	FileIO2.File(:tr0/:psf/:sNp, filename::String)

	Base.read(::{Tr0Reader/PSFReader}, signame::String)
	Base.names(::{Tr0Reader/PSFReader}) #Returns list of signal names
	Base.close(::{Tr0Reader/PSFReader})
==#


end #EDAData
