#NetwAnalysis: Network parameter conversion tools
#-------------------------------------------------------------------------------


#==Helper functions
===============================================================================#


#==Data type re-structuring
===============================================================================#

#Convert Vector{NwPar{Number}} => NwPar{Vector{Number}}
function vector_push{T<:Number}(m::Vector{NetworkParameterMatrix{T}})
	nports = portcount(m[1])
	vlen = length(m)
	result = Array(NetworkParameterMatrix{Vector{T}}, nports, nports)

	for i in 1:vlen
		if nports(m[i]) != vlen
			throw(ArgumentError("Inconsistent vector lengths."))
		end

		result[row, col] = Array(T, vlen)
		for row = 1:nports, col = 1:nports
			result[row, col][i] = m[i][row, col]
		end
	end
	return result
end
vector_push{TP, NP, T}(np::NetworkParametersRef{TP, NP, T}) = Network(TP, vector_push(np.m), z0=np.z0)
vector_push{TP, NP, T}(np::NetworkParametersNoRef{TP, NP, T}) = Network(TP, vector_push(np.m))

#Convert NwPar{Vector{Number}} => Vector{NwPar{Number}}
function vector_pull{T<:Number}(m::NetworkParameterMatrix{Vector{T}})
	nports = portcount(m)
	vlen = length(m[1,1])
	result = Array(NetworkParameterMatrix{T}, vlen)

	for row = 1:nports, col = 1:nports
		if length(m[row, col]) != vlen
			throw(ArgumentError("Inconsistent vector lengths."))
		end

		for i in 1:vlen
			result[i][row, col] = m[row, col][i]
		end
	end
	return result
end

vector_pull{TP, NP, T}(np::NetworkParametersRef{TP, NP, T}) = Network(TP, vector_pull(np.m), z0=np.z0)
vector_pull{TP, NP, T}(np::NetworkParametersNoRef{TP, NP, T}) = Network(TP, vector_pull(np.m))




function Base.sub{T, PT<:Integer}(np::NetworkParameters{T}, ports::Vector{PT}=Int[])
	if T !elem(set([:S, :Z, Y]))
		throw(ArgumentError("Can only compute subset of S, Z, or Y matrices"))
	end
end

#==Network parameter conversions
===============================================================================#

function Network(::NPType{:S}, ABCD::ABCDParameters; z0::Real = 50.0)
	(A, B, C, D) = mx2elem(ABCD)
	B_z0 = B / z0; Cxz0 = C * z0
	denom = A + B_z0 + Cxz0 + D
	s11 = (A + B_z0 - Cxz0 - D) / denom
	s12 = (2(A*D - B*C)) / denom
	s21 = 2 / denom
	s22 = (-A + B_z0 - Cxz0 + D) / denom
	return Network(:S, [s11 s12; s21 s22], z0=z0)
end

#Convert 2-port s-parameters to ABCD:
function Network(::NPType{:ABCD}, S::SParameters{2})
	(s11, s12, s21, s22) = mx2elem(S)
	z0 = S.z0
	s12_2 = s12 / 2
	s21x2 = 2*s21
	A = ((1+s11)*(1-s22)) / s21x2 + s12_2
	B = z0*( ((1+s11)*(1+s22)) / s21x2 - s12_2)
	C = ( ((1-s11)*(1-s22)) / s21x2 - s12_2) / z0
	D = ((1-s11)*(1+s22)) / s21x2 + s12_2
	return Network(:ABCD, [A B; C D])
end
#Last line
