#Comparison tools for NetwAnalysis
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#
const SPARAM_THRESH = 1e-12
const TPARAM_THRESH = 1e-12
const ABCD_THRESH = 1e-12


#==Error of NetworkParameters
===============================================================================#
_assert_z0match(n1::NetworkParameters, n2::NetworkParameters) = nothing
function _assert_z0match(n1::NetworkParametersRef, n2::NetworkParametersRef)
	if n1.z0 != n2.z0
		throw(ArgumentError("Type mismatch: NetworkParameters"))
	end
	nothing
end

function maxerror(v1::DataF1, v2::DataF1)
	@assert(v1.x == v2.x, "x-values do not match")
	Δ = v2-v1
	ϵ = maximum(abs(Δ))
end

function maxerror(n1::NetworkParameters, n2::NetworkParameters)
	throw(ArgumentError("Type mismatch: NetworkParameters"))
end


#==Error of NetworkParameters
===============================================================================#
#For matrix of scalars
#-------------------------------------------------------------------------------
function _maxerror(::Type{Number}, n1::NetworkParameters, n2::NetworkParameters)
	_assert_z0match(n1, n2)
	Δ = n2-n1
	ϵ = maximum(abs.(Δ.m))
	return ϵ
end

function maxerror(n1::NetworkParametersRef{TP, NP, T},
	n2::NetworkParametersRef{TP, NP, T2}) where {TP, NP, T<:Number, T2<:Number}
	return _maxerror(Number, n1, n2)
end
function maxerror(n1::NetworkParametersNoRef{TP, NP, T},
	n2::NetworkParametersNoRef{TP, NP, T2}) where {TP, NP, T<:Number, T2<:Number}
	return _maxerror(Number, n1, n2)
end

#For matrix of Vectors
#-------------------------------------------------------------------------------
function _maxerror(::Type{Vector}, n1::NetworkParameters, n2::NetworkParameters)
	_assert_z0match(n1, n2)
	Δv = n2-n1
	Δ = [maximum(abs2.(elem)) for elem in Δv.m]
	ϵ = maximum(Δ)
	return ϵ
end
function maxerror(n1::NetworkParametersRef{TP, NP, T},
	n2::NetworkParametersRef{TP, NP, T}) where {TP, NP, T<:Vector}
	return _maxerror(Vector, n1, n2)
end
function maxerror(n1::NetworkParametersNoRef{TP, NP, T},
	n2::NetworkParametersNoRef{TP, NP, T}) where {TP, NP, T<:Vector}
	return _maxerror(Vector, n1, n2)
end

#For matrix of DataF1
#-------------------------------------------------------------------------------
function _maxerror(::Type{DataF1}, n1::NetworkParameters, n2::NetworkParameters)
	_assert_z0match(n1, n2)
	Δv = n2-n1
	Δ = [maximum(abs2(elem)) for elem in Δv.m]
	ϵ = maximum(Δ)
	return ϵ
end
function maxerror(n1::NetworkParametersRef{TP, NP, T},
	n2::NetworkParametersRef{TP, NP, T2}) where {TP, NP, T<:DataF1, T2<:DataF1}
	return _maxerror(DataF1, n1, n2)
end
function maxerror(n1::NetworkParametersNoRef{TP, NP, T},
	n2::NetworkParametersNoRef{TP, NP, T2}) where {TP, NP, T<:DataF1, T2<:DataF1}
	return _maxerror(DataF1, n1, n2)
end

#Last line
