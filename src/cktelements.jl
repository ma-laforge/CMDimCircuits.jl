#NetwAnalysis: Circuit element tools
#-------------------------------------------------------------------------------

#=NOTE

Assumption: use ./ & .*
(Vectors represent lists, not arrays that support matrix operations)
=#


#==Helper functions
===============================================================================#
_zeroone(v::Number) = (zero(v), one(v))
_zeroone(v) = (zeros(v), ones(v))


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


#Create series/shunt elements:
function shunt{T}(::NPType{:ABCD}, y::TAdmittance{T})
	y = y.v; (_0, _1) = _zeroone(y)
	m = Array(T, 2, 2) #Must build array manually
		m[1,1] = _1; m[1,2] = _0
		m[2,1] =  y; m[2,2] = _1
	return Network(:ABCD, m)
end
shunt(t::NPType{:ABCD}, z::TImpedance) = shunt(t, admittance(z))
shunt(t::NPType{:ABCD}, args...; kwargs...) = throw("series: Parameter list not supported")
shunt{TP}(t::NPType{TP}, args...; kwargs...) = Network(t, shunt(t, args...; kwargs...))
shunt(s::Symbol, args...; kwargs...) = shunt(NPType(s), args...; kwargs...)

function series{T}(::NPType{:ABCD}, z::TImpedance{T})
	z = z.v; (_0, _1) = _zeroone(z)
	m = Array(T, 2, 2) #Must build array manually
		m[1,1] = _1; m[1,2] = z
		m[2,1] = _0; m[2,2] = _1
	return Network(:ABCD, m)
end
series(t::NPType{:ABCD}, y::TAdmittance) = series(t, impedance(y))
series(t::NPType{:ABCD}, args...; kwargs...) = throw("series: Parameter list not supported")
series{TP}(t::NPType{TP}, args...; kwargs...) = Network(t, series(t, args...; kwargs...))
series(s::Symbol, args...; kwargs...) = series(NPType(s), args...; kwargs...)


#Last line
