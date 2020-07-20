#EDAData
#-------------------------------------------------------------------------------
module EDAData

const defaultPSFReader = :LibPSF #Overwrite with LibPSFC to use alternative algorithm

#=
Wraps lower-level EDA file readers in a more appropriate API.

 - Reads results into DataF1 structures.
 - TODO: Support results of parametric sweeps into MDDatasets.DataRS structures.
=#

using MDDatasets
using CMDimCircuits.NetwAnalysis
import SpiceData #SPICE data reader

#Import PSF reader implementation as "PSFReaderLib" (Hacky, but works):
eval(:(using $defaultPSFReader))
eval(:(const PSFReaderLib = $defaultPSFReader))

import CMDimCircuits.NetwAnalysis: NetworkParameters, NetworkParametersRef, NetworkParametersNoRef
import CMDimCircuits.DSVFiles: DSVReader
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
	open_tr0(path::String) #Opens Tr0Reader
	open_psf(path::String) #Opens PSFReader

	read_sNp(path::String, numports=X) #Returns NetworkParameters matrix
	read_s2p(path::String) #Returns NetworkParameters matrix
==#


#==Extensions to other modules
================================================================================
	Base.read(::{Tr0Reader/PSFReader}, signame::String)
	Base.names(::{Tr0Reader/PSFReader}) #Returns list of signal names
	Base.close(::{Tr0Reader/PSFReader})
==#

end #EDAData
