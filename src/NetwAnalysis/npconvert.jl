#NetwAnalysis: Network parameter conversion tools
#-------------------------------------------------------------------------------

#=Comments

1) All passive 2-port networks are guaranteed to have S-parameters.  Most others
   cannot represent all passive networks.

   So... indirect conversions should try to use S-parameters as the intermediate.

2) "Default" network parameter conversions are trapped using ::NPT_SConv/NP_SConv
   instead of ::NPType/NetworkParameters.  This allows un-expected conversions
	to be detected, and should avoid infinite recursion issues (ex: continuously
   trying to convert S-parameters -> S-parameters).

3) Network(RT::NPType, np::Network; z0 = nothing) is only a thin interface.
   --> Core algorithm implemented as "_Network" to avoid ambiguity/cyclical issues.
=#


#==Constants
===============================================================================#
const default_z0 = 50.0


#==Convenience types
===============================================================================#

#Network parameter convenience unions:
const NP_SConv = Union{ #Those with S-parameter intermediaries
	ZParameters, YParameters,
	ABCDParameters,
	TParameters
}
const NP_ZConv = Union{ #Those with Z-parameter intermediaries
	HParameters, GParameters,
}

#Network parameter >>type<< convenience unions:
#TODO: auto-calculate from NP_SConv??
const NPT_SConv = Union{ #Those with S-parameter intermediaries
	NPType{:Z}, NPType{:Y},
	NPType{:ABCD},
	NPType{:T}
}
const NPT_ZConv = Union{ #Those with Z-parameter intermediaries
	NPType{:H}, NPType{:G},
}


#==Helper functions
===============================================================================#


#==Data type re-structuring
===============================================================================#

#vector_push: Convert Vector{NwPar{Number}} => NwPar{Vector{Number}}
#-------------------------------------------------------------------------------

#Main algorithm for vector_push
#RT: Result type
function _vector_push(RT::DataType, v::Vector{NT}, z0=nothing) where {NT<:NetworkParameters}
	T = eltype(RT)
	nports = portcount(v[1])
	vlen = length(v)
	result_m = Array{T}(undef, nports, nports)

	for i in 1:vlen
		if portcount(v[i]) != nports
			throw(ArgumentError("Inconsistent number of ports."))
		end
	end

	for row = 1:nports, col = 1:nports
		result_m[row, col] = T(undef, vlen)

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
vector_push(np::Vector{NetworkParametersRef{TP, NP, T}}) where {TP, NP, T} =
	_vector_push(NetworkParametersRef{TP, NP, Vector{T}}, np, z0=np.z0)
vector_push(np::Vector{NetworkParametersNoRef{TP, NP, T}}) where {TP, NP, T} =
	_vector_push(NetworkParametersNoRef{TP, NP, Vector{T}}, np)

#vector_pull: Convert NwPar{Vector{Number}} => Vector{NwPar{Number}}
#-------------------------------------------------------------------------------

#Main algorithm for vector_pull:
#ET: Element type for result
function _vector_pull(ET::DataType, np::NetworkParameters, z0=nothing)
	nports = portcount(np)
	vlen = length(np[1,1])
	result = Array{ET}(undef, vlen)

	for row = 1:nports, col = 1:nports
		if length(np[row, col]) != vlen
			throw(ArgumentError("Inconsistent vector lengths."))
		end
	end

	newelem_z0() = ET(z0, NetworkParameterMatrix{eltype(ET)}(undef, nports, nports))
	newelem_noref() = ET(NetworkParameterMatrix{eltype(ET)}(undef, nports, nports))
	newelem = z0 != nothing ? newelem_z0 : newelem_noref

	for i in 1:vlen
		inner = newelem() #Inner matrix

		for row = 1:nports, col = 1:nports
			inner.m[row, col] = np[row, col][i]
		end
		result[i] = inner
	end
	return result
end

vector_pull(np::NetworkParametersRef{TP, NP, Vector{T}}) where {TP, NP, T} =
	_vector_pull(NetworkParametersRef{TP, NP, T}, np, z0=np.z0)
vector_pull(np::NetworkParametersNoRef{TP, NP, Vector{T}}) where {TP, NP, T} =
	_vector_pull(NetworkParametersNoRef{TP, NP, T}, np)


#submatrix: Obtain subset of a NetworkParameters matrix
#-------------------------------------------------------------------------------
function submatrix(np::NetworkParameters, ports::Vector{PT}=Int[]) where {PT<:Integer}
	nports = length(ports)

	if !in(:Y, Set([:S, :Z, :Y]))
		throw(ArgumentError("Can only compute subset of S, Z, or Y matrices"))
	end

	ET = eltype(np)
	result_m = NetworkParameterMatrix{ET}(undef, nports, nports)

	for row=1:nports, col=1:nports
		result_m[row, col] = np[ports[row], ports[col]]
	end

	if typeof(np)<:NetworkParametersRef
		return Network(NPType(np), result_m, z0=np.z0)
	else
		return Network(NPType(np), result_m)
	end

end


#==Reference impedance transformation
===============================================================================#

#Generate T-matrix of an impedance transformer:
function z0xfrm_matrix(z01::Float64, z02::Float64)
	#Forward reflection coefficient:
	ΓF = (z02 - z01) / (z02+z01)

	return ((1 / (1+ΓF)) * sqrt(z02/z01)) .* [1 ΓF; ΓF 1]
end

#T-parameter impedance transformation:
function z0xfrm(T::TParameters, z0::Float64)
	#NOTE:
	#Impedance transformation done by sandwiching current T-matrix between 2
	#impedance transformers: [z01|z02] [T] [z02|z01]
	#where z01 is the ref impedance of the returned T-matrix.

	T1 = z0xfrm_matrix(z0, T.z0)
	T2 = z0xfrm_matrix(z0, T.z0)
	result = T.m

	return Network(NPType(:T), T1 * T.m * T2, z0=z0)
end


#==Network parameter conversions: {T,ABCD,Z,Y}=>S
===============================================================================#

#Convert T => S-parameters (equations always maintains z0):
function npconv(RT::NPType{:S}, T::TParameters)
	(t11, t12, t21, t22) = mx2elem(T)
	s11 = t21/t11
	s12 = t22 - t21*t12/t11
	s21 = 1/t11
	s22 = -t12/t11
	return Network(RT, [s11 s12; s21 s22], z0=T.z0)
end

#Convert ABCD => S-parameters:
function npconv(RT::NPType{:S}, ABCD::ABCDParameters, z0::Float64)
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
function npconv(RT::NPType{:S}, Z::ZParameters, z0::Float64)
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
function npconv(RT::NPType{:S}, Y::YParameters, z0::Float64)
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


#==Network parameter conversions: S=>{T,ABCD,Z,Y}
===============================================================================#

#Convert 2-port S-parameters => T (equations always maintains z0):
function npconv(RT::NPType{:T}, S::SParameters{2})
	(s11, s12, s21, s22) = mx2elem(S)
	t11 = 1/s21
	t12 = -s22/s21
	t21 = s11/s21
	t22 = s12 - s11*s22/s21
	return Network(RT, [t11 t12; t21 t22], z0=S.z0)
end

#Convert 2-port S-parameters => ABCD:
function npconv(RT::NPType{:ABCD}, S::SParameters{2})
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
function npconv(RT::NPType{:Z}, S::SParameters{2})
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
function npconv(RT::NPType{:Y}, S::SParameters{2})
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
function npconv(RT::NPType{:Z}, H::HParameters)
	(h11, h12, h21, h22) = mx2elem(H)
	z11 = (h11*h22 - h12*h21) / h22
	z12 = h12 / h22
	z21 = -h21 / h22
	z22 = 1 / h22
	return Network(RT, [z11 z12; z21 z22])
end

#Convert G-parameters => Z:
function npconv(RT::NPType{:Z}, G::GParameters)
	(g11, g12, g21, g22) = mx2elem(G)
	z11 = 1 / g11
	z12 = -g12 / g11
	z21 = g21 / g11
	z22 = (g11*g22 - g12*g21) / g11
	return Network(RT, [z11 z12; z21 z22])
end

#Convert 2-port Z-parameters => H:
function npconv(RT::NPType{:H}, Z::ZParameters{2})
	(z11, z12, z21, z22) = mx2elem(Z)
	h11 = (z11*z22 - z12*z21) / z22
	h12 = z12 / z22
	h21 = -z21 / z22
	h22 = 1 / z22
	return Network(RT, [h11 h12; h21 h22])
end

#Convert 2-port Z-parameters => G:
function npconv(RT::NPType{:G}, Z::ZParameters{2})
	(z11, z12, z21, z22) = mx2elem(Z)
	g11 = 1 / z11
	g12 = -z12 / z11
	g21 = z21 / z11
	g22 = (z11*z22 - z12*z21) / z11
	return Network(RT, [g11 g12; g21 g22])
end


#==Reference impedance transformation/passthrough
===============================================================================#
z0xfrm(np::Network, z0::Float64) =
	error("Unable to perform z0 transformation for $(typeof(np)).")
#S-parameter impedance transformation:
z0xfrm(np::SParameters, z0::Float64) =
	npconv(NPType(:S), z0xfrm(npconv(NPType(:T), np), z0)) #TODO: implement directly


#==Network parameter conversions: S <=> T
===============================================================================#
#S -> T WITH z0 conversion - TODO: implement directly
npconv(RT::NPType{:T}, np::SParameters, z0::Float64) =
	z0xfrm(npconv(RT, np), z0)
#T -> S WITH z0 conversion - TODO: implement directly
npconv(RT::NPType{:S}, np::TParameters, z0::Float64) =
	npconv(RT, z0xfrm(np, z0))


#==Basic traps for npconv()
===============================================================================#
#Catch-all:
npconv(npt::NPType, np::Network) =
	error("Unable to convert to $(typeof(np)) -> :$(Symbol(npt)).")
npconv(npt::NPType, np::Network, z0::Float64) =
	error("Unable to convert to $(typeof(np)) -> :$(Symbol(npt)), z0=$z0.")
#TODO: copy(np) on conversion????
npconv(::NPType{TP}, np::NetworkParameters{TP}) where {TP} = np #Already correct format
#Traps to z0 transformation/leaving parameters untouched:
npconv(::NPType{TP}, np::NetworkParameters{TP}, z0::Float64) where {TP} =
	((z0 != np.z0) ? z0xfrm(np, z0) : np) #Might require impedance transformation.


#==Indirect network parameter conversions
===============================================================================#
_npconv(args...) = npconv(args...) #Default: Use direct conversion

for dest in QuoteNode.([:ABCD, :Y, :Z]); for src in QuoteNode.([:ABCD, :Y, :Z]);
if src == dest; continue; end; @eval begin #CODEGEN
	_npconv(RT::NPType{$dest}, np::NetworkParameters{$src}) =
		npconv(RT, npconv(NPType(:S), np, default_z0))
end; end; end #CODEGEN----------------------------------------------------------
for dest in QuoteNode.([:ABCD, :Y, :Z]); for src in QuoteNode.([:T]); @eval begin #CODEGEN
	_npconv(RT::NPType{$dest}, np::NetworkParameters{$src}) =
		npconv(RT, npconv(NPType(:S), np)) #No z0 in T-> S xform
end; end; end #CODEGEN----------------------------------------------------------
for dest in QuoteNode.([:T]); for src in QuoteNode.([:ABCD, :Y, :Z]); @eval begin #CODEGEN
	_npconv(RT::NPType{$dest}, np::NetworkParameters{$src}, z0) =
		npconv(RT, npconv(NPType(:S), np, z0), z0)
end; end; end #CODEGEN----------------------------------------------------------

for dest in QuoteNode.([:G, :H]); for src in QuoteNode.([:ABCD, :Y, :Z]); @eval begin #CODEGEN
	_npconv(RT::NPType{$dest}, np::NetworkParameters{$src}) =
		npconv(RT, npconv(NPType(:Z), npconv(NPType(:S), np, default_z0)))
end; end; end #CODEGEN----------------------------------------------------------
for dest in QuoteNode.([:G, :H]); for src in QuoteNode.([:T, :S]); @eval begin #CODEGEN
	_npconv(RT::NPType{$dest}, np::NetworkParameters{$src}) =
		npconv(RT, npconv(NPType(:Z), npconv(NPType(:S), np))) #No z0 in T-> S xform
end; end; end #CODEGEN----------------------------------------------------------
for dest in QuoteNode.([:ABCD, :Y, :Z]); for src in QuoteNode.([:G, :H]); @eval begin #CODEGEN
	_npconv(RT::NPType{$dest}, np::NetworkParameters{$src}) =
		npconv(RT, npconv(NPType(:S), npconv(NPType(:Z), np), default_z0))
end; end; end #CODEGEN----------------------------------------------------------
for dest in QuoteNode.([:T, :S]); for src in QuoteNode.([:G, :H]); @eval begin #CODEGEN
	_npconv(RT::NPType{$dest}, np::NetworkParameters{$src}, z0) =
		npconv(RT, npconv(NPType(:S), npconv(NPType(:Z), np), z0))
end; end; end #CODEGEN----------------------------------------------------------


#==High-level interface (z0 optional parameter):
===============================================================================#
Network(RT::NPType, np::Network) = _npconv(RT, np)
#Default: maintain z0 between scattering parameters:
Network(RT::NPType{:S}, np::NetworkParametersRef) = _npconv(RT, np, np.z0) #Maintain z0.
Network(RT::NPType{:T}, np::NetworkParametersRef) = _npconv(RT, np, np.z0) #Maintain z0.
#Allow user overwrite/use default_z0 when converting to scattering parameters:
Network(RT::NPType{:S}, np::Network; z0::Real = default_z0) = _npconv(RT, np, Float64(z0))
Network(RT::NPType{:T}, np::Network; z0::Real = default_z0) = _npconv(RT, np, Float64(z0))
#TODO: Deal with complex z0??

#Last line
