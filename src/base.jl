#CircuitAnalysis: Base tools


#==Main data structures
===============================================================================#

#Object used to provide type information to something:
type AbstractTag{TAGID, T}
	v::T
end


#==Type aliases
===============================================================================#

#Tags:
typealias TImpedance{T} AbstractTag{:Z, T}
typealias TAdmittance{T} AbstractTag{:Y, T}
typealias TInductance{T} AbstractTag{:L, T}
typealias TCapacitance{T} AbstractTag{:C, T}


#==Useful validations/assertions
===============================================================================#


#==Constructor interfaces
===============================================================================#

call{TAGID, T}(::Type{AbstractTag{TAGID}}, v::T) = AbstractTag{TAGID, T}(v)


#==Main functions
===============================================================================#
impedance(v) = TImpedance(v)
admittance(v) = TAdmittance(v)
capacitance(v) = TCapacitance(v)
inductance(v) = TInductance(v)

impedance(y::TAdmittance) = impedance(1./y.v)
admittance(z::TImpedance) = admittance(1./z.v)

#Capacitor values:
_Y(c::TCapacitance, f) = admittance((2*pi*c.v)im.*f)
_Y(c::TCapacitance, ::Void) = throw(ArgumentError("Missing kwarg :f"))
admittance(c::TCapacitance; f = nothing) = _Y(c, f)
impedance(c::TCapacitance, args...; kwargs...) = impedance(admittance(c, args...; kwargs...))
#TODO: create admittance(:L, value, f=x)??

#Inductor values:
_Z(l::TInductance, f) = admittance((2*pi*c.v)im.*f)
_Z(l::TInductance, ::Void) = throw(ArgumentError("Missing kwarg :f"))
impedance(l::TInductance; f = nothing) = _Z(l, f)
admittance(l::TInductance, args...; kwargs...) = admittance(impedance(l, args...; kwargs...))


#==Helper functions
===============================================================================#


#==Traits (utility functions for instances and types)
===============================================================================#

#Last line
