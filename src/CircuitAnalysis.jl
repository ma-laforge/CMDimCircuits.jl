#Circuit analysis tools
#-------------------------------------------------------------------------------

module CircuitAnalysis

#Type used to dispatch on a symbol & minimize namespace pollution:
#-------------------------------------------------------------------------------
struct DS{T}; end #Dispatchable symbol
DS(v::Symbol) = DS{v}()

include("base.jl")
include("functions.jl")
include("unitconvert.jl")
include("show.jl")


#==Exported symbols
===============================================================================#
#Objects
#-------------------------------------------------------------------------------

#Functions
#-------------------------------------------------------------------------------
export dB20, dB10, dB, dBm, dBW, Vpk, Ipk, VRMS, IRMS

#Value tags:
#-------------------------------------------------------------------------------
export impedance
export admittance
export capacitance
export inductance


#==Other interface tools (symbols not exported to avoid collisions):
================================================================================
#Already in base:
==#


#==Symbols *not* exported (useful for implementing custom functions)
================================================================================
#Tagged data types:
	TImpedance{T}
	TAdmittance{T}
	TInductance{T}
	TCapacitance{T}
=#

end #module CircuitAnalysis
