#CircuitAnalysis: Base tools
import MDDatasets: DataMD


#==Main data structures
===============================================================================#

#Object used to provide type information to something:
struct DataTag{ID, T}
	v::T
end
#=TODO: Figure out how to broadcast operations on DataTag (ex: make 5 .* ycap
work)... but not ycap .* ycap.
=#


#==Type aliases
===============================================================================#

#Tags:
const TImpedance = DataTag{:Z}
const TAdmittance = DataTag{:Y}
const TInductance = DataTag{:L}
const TCapacitance = DataTag{:C}


#Base.size(x::DataTag) = size(x.v)
#Base.length(x::DataTag) = length(x.v)
#Base.eltype(x::DataTag{ID, T}) where {ID, T} = T


#==Useful validations/assertions
===============================================================================#


#==Constructor interfaces
===============================================================================#

(::Type{DataTag{ID}})(v::T) where {ID, T} = DataTag{ID, T}(v)


#==Helper functions
===============================================================================#
#multMD: disambiguate multiplication to use
multMD(a, b) = a .* b
divMD(a, b) = a ./ b

#DataMD values don't work with .* (should this be changed?):
multMD(a::DataMD, b::DataMD) = a*b
multMD(a::DataMD, b) = a*b
multMD(a, b::DataMD) = a*b
divMD(a::DataMD, b::DataMD) = a/b
divMD(a::DataMD, b) = a/b
divMD(a, b::DataMD) = a/b


#==Operations
===============================================================================#
#Mostly for unit testing:
Base.:(≈)(a::DataTag, b::DataTag; kwargs...) = false
Base.:(≈)(a::DataTag{ID}, b::DataTag{ID}; kwargs...) where ID =
	Base.:(≈)(a.v, b.v; kwargs...)

Base.:(==)(a::DataTag, b::DataTag) = false
Base.:(==)(a::DataTag{ID}, b::DataTag{ID}) where ID = (a.v == b.v)

#_dotop(x)=Symbol(".$x")
_operators1 = [:+, :-] #Unary operator on a tagged object
_operators2 = [:+, :-, :*, :/]

for op in _operators1; @eval begin #CODEGEN-------------------------------------

Base.$op(d1::DataTag{ID}) where ID = DataTag{ID}(Base.$op(d1.v))

end; end #CODEGEN---------------------------------------------------------------

#=

for op in _operators2; @eval begin #CODEGEN--------------------------------

Base.$op(d1::DataTag{ID}, d2::Number) where ID =
	DataTag{ID}(Base.$op(d1.v, d2))

Base.$op(d1::Number, d2::DataTag{ID}) where ID =
	DataTag{ID}(Base.$op(d1, d2.v))

Base.$op(d1::DataTag{ID}, d2::DataTag{ID}) where ID =
	DataTag{ID}(Base.$op(d1.v, d2.v))

end; end #CODEGEN---------------------------------------------------------------

=#
#==Main functions
===============================================================================#
impedance(v) = TImpedance(v)
admittance(v) = TAdmittance(v)
capacitance(v) = TCapacitance(v)
inductance(v) = TInductance(v)

impedance(y::TAdmittance) = impedance(divMD(1, y.v))
admittance(z::TImpedance) = admittance(divMD(1, z.v))

#Capacitor values:
_Y(c::TCapacitance, f) = admittance(multMD((2*pi*c.v)im, f))
_Y(c::TCapacitance, ::Nothing) = throw(ArgumentError("Missing kwarg :f"))
admittance(c::TCapacitance; f = nothing) = _Y(c, f)
impedance(c::TCapacitance, args...; kwargs...) = impedance(admittance(c, args...; kwargs...))
#TODO: create admittance(:L, value, f=x)??

#Inductor values:
_Z(l::TInductance, f) = impedance(multMD((2*pi*l.v)im, f))
_Z(l::TInductance, ::Nothing) = throw(ArgumentError("Missing kwarg :f"))
impedance(l::TInductance; f = nothing) = _Z(l, f)
admittance(l::TInductance, args...; kwargs...) = admittance(impedance(l, args...; kwargs...))


#==Helper functions
===============================================================================#


#==Traits (utility functions for instances and types)
===============================================================================#

#Last line
