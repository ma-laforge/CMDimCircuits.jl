#Base network analysis
#TODO: Is there not a way to force the dimension of an array?


#==Main data structures
===============================================================================#
#NP::Int: # of ports
abstract Network{NP};

abstract NetworkParameters{TP, NP} <: Network{NP}
typealias NetworkParameterMatrix{T} Array{T, 2}


#NPType: Mostly used to dispatch functions on a symbol:
immutable NPType{TP}; end; #Dispatchable symbol
NPType(s::Symbol) = NPType{s}()

#Network parameters defined with port reference impedances:
#TP::Symbol: Parameter type, NP::Int: # of ports, T: data type
type NetworkParametersRef{TP, NP, T} <: NetworkParameters{TP, NP}
	z0::Real #For now. In general: one z0 per port
	m::NetworkParameterMatrix{T}
end

#Network parameters defined *without* port reference impedances:
#TP::Symbol: Parameter type, NP::Int: # of ports, T: data type
type NetworkParametersNoRef{TP, NP, T} <: NetworkParameters{TP, NP}
	m::NetworkParameterMatrix{T}
end


#==Type aliases
===============================================================================#
#Not exported
typealias SParameters{NP, T} NetworkParametersRef{:S, NP, T}
typealias TParameters{T} NetworkParametersRef{:T, 2, T}

typealias ZParameters{NP, T} NetworkParametersNoRef{:Z, NP, T}
typealias YParameters{NP, T} NetworkParametersNoRef{:Y, NP, T}
typealias HParameters{NP, T} NetworkParametersNoRef{:H, NP, T}
typealias GParameters{NP, T} NetworkParametersNoRef{:G, NP, T}
typealias ABCDParameters{T} NetworkParametersNoRef{:ABCD, 2, T}


#==Useful validations/assertions
===============================================================================#
function validate_sameref(np1::NetworkParametersRef, np2::NetworkParametersRef)
	if np1.z0 != np2.z0
		throw(ArgumentError("Reference impedances do not match"))
	end
end


#==Constructor interfaces
===============================================================================#
Base.Symbol{TP}(::NPType{TP}) = TP

NPType{TP}(::NetworkParameters{TP}) = NPType(TP)

#Construct network parameter matrices of a specific type:
Network{TP}(::NPType{TP}, args...; kwargs...) =
	throw(ArgumentError("Unsupported call: Network($TP, ...)"))
Network{T}(::NPType{:S}, m::NetworkParameterMatrix{T}; z0 = 50) =
	NetworkParametersRef{:S, portcount(m), T}(z0, m)
Network{T}(::NPType{:T}, m::NetworkParameterMatrix{T}; z0 = 50) =
	NetworkParametersRef{:T, 2, T}(z0, m)
Network{T}(::NPType{:Z}, m::NetworkParameterMatrix{T}) =
	NetworkParametersNoRef{:Z, portcount(m), T}(m)
Network{T}(::NPType{:Y}, m::NetworkParameterMatrix{T}) =
	NetworkParametersNoRef{:Y, portcount(m), T}(m)
Network{T}(::NPType{:ABCD}, m::NetworkParameterMatrix{T}) =
	NetworkParametersNoRef{:ABCD, 2, T}(m)
Network{T}(::NPType{:G}, m::NetworkParameterMatrix{T}) =
	NetworkParametersNoRef{:G, 2, T}(m)
Network{T}(::NPType{:H}, m::NetworkParameterMatrix{T}) =
	NetworkParametersNoRef{:H, 2, T}(m)
Network(s::Symbol, args...; kwargs...) = Network(NPType(s), args...; kwargs...)


#==Helper functions
===============================================================================#


#==Traits (utility functions for instances and types)
===============================================================================#

function portcount(m::NetworkParameterMatrix)
	sz = size(m)
	if sz[1] != sz[2]
		throw(ArgumentError("NetworkParameterMatrix not square."))
	end
	return sz[1]
end
function portcount{TP, NP}(np::NetworkParameters{TP, NP})
	if NP != portcount(np.m)
		throw(ArgumentError("NetworkParameters: Inconsistent # of ports."))
	end
	return NP
end

#Returns 2-port matrix elements as a tuple of elements in intuitive order:
mx2elem{TP}(np::NetworkParameters{TP, 2}) = (np.m[1,1], np.m[1,2], np.m[2,1], np.m[2,2])

Base.eltype{TP, NP, T}(::Type{NetworkParametersRef{TP, NP, T}}) = T
Base.eltype{TP, NP, T}(::Type{NetworkParametersNoRef{TP, NP, T}}) = T
Base.eltype{NT<:NetworkParameters}(np::NT) = eltype(NT)
Base.size(np::NetworkParameters, args...) = size(np.m, args...)
Base.getindex(np::NetworkParameters, r::Integer, c::Integer) = np.m[r,c]




#==Implement apply interface (simplify how functions are applied)
===============================================================================#

function apply{TP}(fn::Function, d1::NetworkParametersRef{TP}, d2::NetworkParametersRef{TP})
	validate_sameref(d1, d2)
	return Network(TP, fn(d1.m, d2.m), z0=d1.z0)
end
apply{TP}(fn::Function, d1::NetworkParametersNoRef{TP}, d2::NetworkParametersNoRef{TP}) =
	Network(TP, fn(d1.m, d2.m))

apply{TP}(fn::Function, d1::NetworkParametersRef{TP}, d2::TNetIop) =
	Network(TP, fn(d1.m, d2), z0=d1.z0)
apply{TP}(fn::Function, d1::NetworkParametersNoRef{TP}, d2::TNetIop) = Network(TP, fn(d1.m, d2))

apply{TP}(fn::Function, d1::TNetIop, d2::NetworkParametersRef{TP}) =
	Network(TP, fn(d1, d2.m), z0=d2.z0)
apply{TP}(fn::Function, d1::TNetIop, d2::NetworkParametersNoRef{TP}) = Network(TP, fn(d1, d2.m))


#==Register base operations
===============================================================================#
fnlist = Symbol[:*, :/, :+, :-, :(.*), :(./), :(.+), :(.-)]
for fn in fnlist; @eval begin #CODEGEN------------------------------------------

Base.$fn(d1::NetworkParameters, d2::NetworkParameters) = apply($fn, d1, d2)
Base.$fn(d1::NetworkParameters, d2::TNetIop) = apply($fn, d1, d2)
Base.$fn(d1::TNetIop, d2::NetworkParameters) = apply($fn, d1, d2)

end; end #CODEGEN---------------------------------------------------------------


#==Hacks
===============================================================================#
#TODO: Move to MDDatasets
#Make *dot* operations work ond DataMD
_dotop(x)=Symbol(".$x")
_operators2 = [:*, :/, :+, :-]
for op in _operators2; @eval begin #CODEGEN-------------------------------------

Base.$(_dotop(op))(d1::DataMD, d2::Number) = Base.$op(d1, d2)
Base.$(_dotop(op))(d1::Number, d2::DataMD) = Base.$op(d1, d2)

end; end #CODEGEN---------------------------------------------------------------


#Last line
