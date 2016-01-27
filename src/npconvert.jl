#NetwAnalysis: Network parameter conversion tools
#-------------------------------------------------------------------------------


#==Helper functions
===============================================================================#


#==Data type re-structuring
===============================================================================#

#vector_push: Convert Vector{NwPar{Number}} => NwPar{Vector{Number}}
#-------------------------------------------------------------------------------

#Main algorithm for vector_push
#RT: Result type
function _vector_push{NT<:NetworkParameters}(RT::DataType, v::Vector{NT}, z0=nothing)
	T = eltype(RT)
	nports = portcount(v[1])
	vlen = length(v)
	result_m = Array(T, nports, nports)

	for i in 1:vlen
		if portcount(v[i]) != nports
			throw(ArgumentError("Inconsistent number of ports."))
		end
	end

	for row = 1:nports, col = 1:nports
		result_m[row, col] = T(vlen)

		for i in 1:vlen
			result_m[row, col][i] = v[i][row, col]
		end
	end

	if z0 != nothing
		return RT(z0, result_m)
	else
		return RT(result_m)
	end
end
vector_push{TP, NP, T}(np::Vector{NetworkParametersRef{TP, NP, T}}) =
	_vector_push(NetworkParametersRef{TP, NP, Vector{T}}, np, z0=np.z0)
vector_push{TP, NP, T}(np::Vector{NetworkParametersNoRef{TP, NP, T}}) =
	_vector_push(NetworkParametersNoRef{TP, NP, Vector{T}}, np)

#vector_pull: Convert NwPar{Vector{Number}} => Vector{NwPar{Number}}
#-------------------------------------------------------------------------------

#Main algorithm for vector_pull:
#ET: Element type for result
function _vector_pull(ET::DataType, np::NetworkParameters, z0=nothing)
	nports = portcount(np)
	vlen = length(np[1,1])
	result = Array(ET, vlen)

	for row = 1:nports, col = 1:nports
		if length(np[row, col]) != vlen
			throw(ArgumentError("Inconsistent vector lengths."))
		end
	end

	if z0 != nothing
		newelem() = ET(z0, NetworkParameterMatrix{eltype(ET)}(nports, nports))
	else
		newelem() = ET(NetworkParameterMatrix{eltype(ET)}(nports, nports))
	end

	for i in 1:vlen
		inner = newelem() #Inner matrix

		for row = 1:nports, col = 1:nports
			inner.m[row, col] = np[row, col][i]
		end
		result[i] = inner
	end
	return result
end

vector_pull{TP, NP, T}(np::NetworkParametersRef{TP, NP, Vector{T}}) =
	_vector_pull(NetworkParametersRef{TP, NP, T}, np, z0=np.z0)
vector_pull{TP, NP, T}(np::NetworkParametersNoRef{TP, NP, Vector{T}}) =
	_vector_pull(NetworkParametersNoRef{TP, NP, T}, np)


#sub: Obtain subset of a NetworkParameters matrix
#-------------------------------------------------------------------------------
function Base.sub{PT<:Integer}(np::NetworkParameters, ports::Vector{PT}=Int[])
	nports = length(ports)

	if !in(:Y, Set([:S, :Z, :Y]))
		throw(ArgumentError("Can only compute subset of S, Z, or Y matrices"))
	end

	ET = eltype(np)
	result_m = NetworkParameterMatrix{ET}(nports, nports)

	for row=1:nports, col=1:nports
		result_m[row, col] = np[ports[row], ports[col]]
	end

	if typeof(np)<:NetworkParametersRef
		return Network(NPType(np), result_m, z0=np.z0)
	else
		return Network(NPType(np))
	end

end


#==Network parameter conversions: X=>S
===============================================================================#

#Convert T => S-parameters (equations always maintains z0):
function Network(RT::NPType{:S}, T::TParameters)
	(t11, t12, t21, t22) = mx2elem(T)
	s11 = t21/t11
	s12 = t22 - t21*t12/t11
	s21 = 1/t11
	s22 = -t12/t11
	return Network(RT, [s11 s12; s21 s22], z0=T.z0)
end

#Convert ABCD => S-parameters:
function Network(RT::NPType{:S}, ABCD::ABCDParameters; z0::Real = 50.0)
	(A, B, C, D) = mx2elem(ABCD)
	B_z0 = B / z0; Cxz0 = C * z0
	denom = A + B_z0 + Cxz0 + D
	s11 = (A + B_z0 - Cxz0 - D) / denom
	s12 = (2(A*D - B*C)) / denom
	s21 = 2 / denom
	s22 = (-A + B_z0 - Cxz0 + D) / denom
	return Network(RT, [s11 s12; s21 s22], z0=z0)
end

#Convert Z => S-parameters:
function Network(RT::NPType{:S}, Z::ZParameters; z0::Real = 50.0)
	(z11, z12, z21, z22) = mx2elem(Z)
	z12z21 = z12*z21
	denom = (z11+z0)*(z22+z0)-z12z21
	s11 = ((z11-z0)*(z22+z0) - z12z21) / denom
	s12 = 2z12*z0 / denom
	s21 = 2z21*z0 / denom
	s22 = ((z11+z0)*(z22-z0) - z12z21) / denom
	return Network(RT, [s11 s12; s21 s22], z0=z0)
end

#Convert Y => S-parameters:
function Network(RT::NPType{:S}, Y::YParameters; z0::Real = 50.0)
	(y11, y12, y21, y22) = mx2elem(Y)
	y0 = 1/z0
	y12y21 = y12*y21
	denom = (y11+y0)*(y22+y0) - y12y21
	s11 = ((y0-y11)*(y0+y22) + y12y21) / denom
	s12 = -2y12*y0 / denom
	s21 = -2y21*y0 / denom
	s22 = ((y0+y11)*(y0-y22) + y12y21) / denom
	return Network(RT, [s11 s12; s21 s22], z0=z0)
end


#==Network parameter conversions: S=>X
===============================================================================#

#Convert 2-port S-parameters => T (equations always maintains z0):
function Network(RT::NPType{:T}, S::SParameters{2})
	(s11, s12, s21, s22) = mx2elem(S)
	t11 = 1/s21
	t12 = -s22/s21
	t21 = s11/s21
	t22 = s12 - s11*s22/s21
	return Network(RT, [t11 t12; t21 t22], z0=S.z0)
end

#Convert 2-port S-parameters => ABCD:
function Network(RT::NPType{:ABCD}, S::SParameters{2})
	(s11, s12, s21, s22) = mx2elem(S)
	z0 = S.z0
	s12_2 = s12 / 2
	s21x2 = 2*s21
	A = ((1+s11)*(1-s22)) / s21x2 + s12_2
	B = z0*( ((1+s11)*(1+s22)) / s21x2 - s12_2)
	C = (((1-s11)*(1-s22)) / s21x2 - s12_2) / z0
	D = ((1-s11)*(1+s22)) / s21x2 + s12_2
	return Network(RT, [A B; C D])
end

#Convert 2-port S-parameters => Z:
#TODO: Arbitrary number of ports
function Network(RT::NPType{:Z}, S::SParameters{2})
	(s11, s12, s21, s22) = mx2elem(S)
	z0 = S.z0
	s12s21 = s12*s21
	cFact = z0 / ((1-s11)*(1-s22) - s12s21)
	z11 = cFact * ((1+s11)*(1-s22) + s12s21)
	z12 = cFact * 2 * s12
	z21 = cFact * 2 * s21
	z22 = cFact * ((1-s11)*(1+s22) + s12s21)
	return Network(RT, [z11 z12; z21 z22])
end

#Convert 2-port S-parameters => Y:
#TODO: Arbitrary number of ports
function Network(RT::NPType{:Y}, S::SParameters{2})
	(s11, s12, s21, s22) = mx2elem(S)
	z0 = S.z0
	s12s21 = s12*s21
	cFact = 1 / (z0 * ((1+s11)*(1+s22) - s12s21))
	y11 = cFact * ((1-s11)*(1+s22) + s12s21)
	y12 = -2 * s12 * cFact
	y21 = -2 * s21 * cFact
	y22 = cFact * ((1+s11)*(1-s22) + s12s21)
	return Network(RT, [y11 y12; y21 y22])
end


#==Network parameter conversions: {G, H} <=> Z
===============================================================================#

#Convert H-parameters => Z:
function Network(RT::NPType{:Z}, H::HParameters)
	(h11, h12, h21, h22) = mx2elem(H)
	z11 = (h11*h22 - h12*h21) / h22
	z12 = h12 / h22
	z21 = -h21 / h22
	z22 = 1 / h22
	return Network(RT, [z11 z12; z21 z22])
end

#Convert G-parameters => Z:
function Network(RT::NPType{:Z}, G::GParameters)
	(g11, g12, g21, g22) = mx2elem(G)
	z11 = 1 / g11
	z12 = -g12 / g11
	z21 = g21 / g11
	z22 = (g11*g22 - g12*g21) / g11
	return Network(RT, [z11 z12; z21 z22])
end

#Convert 2-port Z-parameters => H:
function Network(RT::NPType{:H}, Z::ZParameters{2})
	(z11, z12, z21, z22) = mx2elem(Z)
	h11 = (z11*z22 - z12*z21) / z22
	h12 = z12 / z22
	h21 = -z21 / z22
	h22 = 1 / z22
	return Network(RT, [h11 h12; h21 h22])
end

#Convert 2-port Z-parameters => G:
function Network(RT::NPType{:G}, Z::ZParameters{2})
	(z11, z12, z21, z22) = mx2elem(Z)
	g11 = 1 / z11
	g12 = -z12 / z11
	g21 = z21 / z11
	g22 = (z11*z22 - z12*z21) / z11
	return Network(RT, [g11 g12; g21 g22])
end


#==Network parameter conversions: Indirect converstions
===============================================================================#
#=NOTE:
All passive 2-port networks are guaranteed to have S-parameters.  Most others
cannot represent all passive networks.

So... indirect conversions try to use S-parameters as the intermediate.
=#

#Stop recursion:
Network(::NPType{:S}, np::Network) = throw("Could not convert to S-parameters")

#DEFAULT: Convert to S parameters, when direct conversion not implemented:
Network(RT::NPType, np::Network) = Network(RT, Network(:S, np))


#Relay network parameters when input already of desired type:
#*******************************************************************************
#Generic, RPS: Result parameter symbol:
_Network{RPS}(RT::NPType{RPS}, np::NetworkParametersRef{RPS}, z0::Void) = np #Relay
_Network(RT::NPType, np::Network, z0::Void) = Network(RT, Network(:S, np))
_Network(RT::NPType, np::Network, z0::Real) =
	Network(RT, Network(:S, Network(:Z, Network(:S, np)), z0=z0)) #HACK: Convert through Z network for arbitrary z0
Network(RT::NPType{:S}, np::NetworkParameters{:S}; z0 = nothing) = _Network(RT, np, z0) #Resolve ambiguity
Network(RT::NPType{:S}, np::Network; z0 = nothing) = _Network(RT, np, z0)
Network(RT::NPType{:T}, np::NetworkParameters{:T}; z0 = nothing) = _Network(RT, np, z0) #Resolve ambiguity
Network(RT::NPType{:T}, np::Network; z0 = nothing) = _Network(RT, np, z0)
Network{RPS}(RT::NPType{RPS}, np::NetworkParameters{RPS}) = np #Relay


#G/H parameters must go through Z:
#*******************************************************************************
Network(RT::NPType{:H}, np::NetworkParameters) = Network(RT, Network(:Z, np))
Network(RT::NPType{:G}, np::NetworkParameters) = Network(RT, Network(:Z, np))
Network{NT<:HParameters}(RT::NPType{:S}, np::NT) = Network(RT, Network(:Z, np))
Network{NT<:HParameters}(RT::NPType, np::NT) = Network(RT, Network(:Z, np))
Network{NT<:GParameters}(RT::NPType{:S}, np::NT) = Network(RT, Network(:Z, np))
Network{NT<:GParameters}(RT::NPType, np::NT) = Network(RT, Network(:Z, np))


#Last line
