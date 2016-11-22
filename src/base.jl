#CircuitAnalysis: Base tools


#==Main data structures
===============================================================================#

#Object used to provide type information to something:
type ValueTag{TAGID, T}
	v::T
end


#==Type aliases
===============================================================================#

#Tags:
typealias TImpedance{T} ValueTag{:Z, T}
typealias TAdmittance{T} ValueTag{:Y, T}
typealias TInductance{T} ValueTag{:L, T}
typealias TCapacitance{T} ValueTag{:C, T}


#==Useful validations/assertions
===============================================================================#


#==Constructor interfaces
===============================================================================#

(::Type{ValueTag{TAGID}}){TAGID, T}(v::T) = ValueTag{TAGID, T}(v)


#==Operations
===============================================================================#

#_dotop(x)=Symbol(".$x")
_operators_mult = [:*, :(.*)] #Multiplying a tagged object
_operators_div = [:/, :(./)] #Dividing a tagged object
_operators_scale = vcat(_operators_mult, _operators_div)#Scaling a tagged object
_operators1 = [:+, :-] #Unary operator on a tagged object
#Can be performed between two tagged objects of same type:
_operators_same = [:+, :-, :(.+), :(.-)]

for op in _operators1; @eval begin #CODEGEN-------------------------------------

Base.$op{TAGID}(d1::ValueTag{TAGID}) = ValueTag{TAGID}(Base.$op(d1.v))

end; end #CODEGEN---------------------------------------------------------------

for op in _operators_scale; @eval begin #CODEGEN--------------------------------

Base.$op{TAGID}(d1::ValueTag{TAGID}, d2::Number) =
	ValueTag{TAGID}(Base.$op(d1.v, d2))

end; end #CODEGEN---------------------------------------------------------------

for op in _operators_mult; @eval begin #CODEGEN---------------------------------

Base.$op{TAGID}(d1::Number, d2::ValueTag{TAGID}) =
	ValueTag{TAGID}(Base.$op(d1, d2.v))

end; end #CODEGEN---------------------------------------------------------------

for op in _operators_same; @eval begin #CODEGEN---------------------------------

Base.$op{TAGID}(d1::ValueTag{TAGID}, d2::ValueTag{TAGID}) =
	ValueTag{TAGID}(Base.$op(d1.v, d2.v))

end; end #CODEGEN---------------------------------------------------------------


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
