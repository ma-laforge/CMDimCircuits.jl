#Network analysis tools
#-------------------------------------------------------------------------------

module NetwAnalysis

using CircuitAnalysis
import CircuitAnalysis: TImpedance, TAdmittance, TInductance, TCapacitance

import MDDatasets
import MDDatasets: DataMD
import MDDatasets: DS #To dispatch on a symbol & minimize namespace pollution

#Types that are meant to operate on network parameters:
typealias TNetIop Union{DataMD,Number,Array}

include("base.jl")
include("npconvert.jl")
include("cktelements.jl")
include("gains.jl")
include("show.jl")


#==Exported symbols
===============================================================================#
#Objects
#-------------------------------------------------------------------------------
export Network
export NPType #Network parameter type

#Functions
#-------------------------------------------------------------------------------
export kstab, gain
export series, shunt
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

#==Symbols *not* exported (useful for implementing custom functions)
===============================================================================#
#=
SParameters{NP, T}
TParameters{T}
ZParameters{NP, T}
YParameters{NP, T}
ABCDParameters{T}
=#


#Notation: z0: Reference impedance.  zC: Characteristic impedance
end #module NetwAnalysis
