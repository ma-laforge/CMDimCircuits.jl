#CMDimCircuts: Circuit analysis tools operating on CMDimData datasets.
#-------------------------------------------------------------------------------
__precompile__(true)
#=
TAGS:
	#WANTCONST, HIDEWARN_0.7
=#

module CMDimCircuits

using MDDatasets
using CMDimData
using NumericIO

const rootpath = realpath(joinpath(@__DIR__, ".."))
const demoplotcfgscript = joinpath(rootpath, "sample", "cfgplots4demo.jl")

include("physics.jl")
include("dsvfiles.jl")
include("CircuitAnalysis/CircuitAnalysis.jl")
include("NetwAnalysis/NetwAnalysis.jl") #Depends on CircuitAnalysis
include("EDAData/EDAData.jl") #Depends on NetwAnalysis
include("SignalProcessing/SignalProcessing.jl")


#==Convenience macros
===============================================================================#

#"using" C-Data environment into the caller's module:
macro using_CData()
	m = quote
		using MDDatasets
		using CMDimData
		using CMDimData.EasyPlot
		#using CMDimData.EasyData #TODO: Cannot yet because EasyData is "included".
		#using CMDimCircuits #Already there
		using CMDimCircuits.CircuitAnalysis
		using CMDimCircuits.NetwAnalysis
		using CMDimCircuits.SignalProcessing
		using CMDimCircuits.EDAData
	end
	return esc(m) #esc: Evaluate in calling module
end


#==Functions
===============================================================================#
SI(v; ndigits=3) = NumericIO.formatted(v, :SI, ndigits=ndigits)


#==Exported symbols
===============================================================================#
export SI


#==Initialization
===============================================================================#
function __init__()
	return
end

end # module
