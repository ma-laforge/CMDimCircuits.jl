#Network analysis tools
#-------------------------------------------------------------------------------

module NetwAnalysis

import MDDatasets
import MDDatasets: DataF1

#Types that are meant to operate on network parameters:
typealias TNetIop Union{DataF1,Number,Array}

include("base.jl")
include("npconvert.jl")
include("show.jl")


#==Exported symbols
===============================================================================#
#Objects
#-------------------------------------------------------------------------------
export Network
export NPType #Network parameter type

#Functions
#-------------------------------------------------------------------------------
export vector_push #Vector{NwPar{Number}} => NwPar{Vector{Number}}
export vector_pull #NwPar{Vector{Number}} => Vector{NwPar{Number}}
export portcount
export mx2elem #Returns 2-port matrix elements as a tuple of elements in intuitive order
	#TODO: Find better name than mx2elem


#==Other interface tools (symbols not exported to avoid collisions):
================================================================================
#Already in base:
	Base.Symbol(::NPType)
	Base.eltype(::NetworkParameters)
	Base.size(::NetworkParameters)
==#

#Notation: z0: Reference impedance.  zC: Characteristic impedance
end #module NetwAnalysis
