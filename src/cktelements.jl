#NetwAnalysis: Circuit element tools
#-------------------------------------------------------------------------------

#=NOTE

Assumption: use ./ & .*
(Vectors represent lists, not arrays that support matrix operations)
=#


#==Helper functions
===============================================================================#
_zeroone(v::Number) = (zero(v), one(v))
_zeroone(v::DataMD) = (zeros(v), ones(v))
_zeroone(v) = (t=eltype(v); sz=size(v); return (zeros(t, sz), ones(t, sz))) #Arrays


#==Main functions
===============================================================================#

#Create series/shunt elements:
function shunt(::NPType{:ABCD}, y::TAdmittance{T}) where T
	y = y.v; (_0, _1) = _zeroone(y)
	m = Array{T}(undef, 2, 2) #Must build array manually
		m[1,1] = _1; m[1,2] = _0
		m[2,1] =  y; m[2,2] = _1
	return Network(:ABCD, m)
end
shunt(t::NPType{:ABCD}, z::TImpedance) = shunt(t, admittance(z))
shunt(t::NPType{:ABCD}, args...; kwargs...) = throw("series: Parameter list not supported")
shunt(t::NPType{TP}, args...; kwargs...) where TP = Network(t, shunt(t, args...; kwargs...))
shunt(s::Symbol, args...; kwargs...) = shunt(NPType(s), args...; kwargs...)

function series(::NPType{:ABCD}, z::TImpedance{T}) where T
	z = z.v; (_0, _1) = _zeroone(z)
	m = Array{T}(undef, 2, 2) #Must build array manually
		m[1,1] = _1; m[1,2] = z
		m[2,1] = _0; m[2,2] = _1
	return Network(:ABCD, m)
end
series(t::NPType{:ABCD}, y::TAdmittance) = series(t, impedance(y))
series(t::NPType{:ABCD}, args...; kwargs...) = throw("series: Parameter list not supported")
series(t::NPType{TP}, args...; kwargs...) where TP = Network(t, series(t, args...; kwargs...))
series(s::Symbol, args...; kwargs...) = series(NPType(s), args...; kwargs...)


#Last line
