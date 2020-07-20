#CircuitAnalysis show functions
#-------------------------------------------------------------------------------


#==Generate friendly show functions
===============================================================================#

_showcompact(io::IO, t::Type{<:TImpedance}) = print(io, "TImpedance")
_showcompact(io::IO, t::Type{<:TAdmittance}) = print(io, "TAdmittance")
_showcompact(io::IO, t::Type{<:TInductance}) = print(io, "TInductance")
_showcompact(io::IO, t::Type{<:TCapacitance}) = print(io, "TCapacitance")

Base.show(io::IO, t::Type{TImpedance{T}}) where T = print(io, "TImpedance{$T}")
Base.show(io::IO, t::Type{TAdmittance{T}}) where T = print(io, "TAdmittance{$T}")
Base.show(io::IO, t::Type{TInductance{T}}) where T = print(io, "TInductance{$T}")
Base.show(io::IO, t::Type{TCapacitance{T}}) where T = print(io, "TCapacitance{$T}")

function Base.show(io::IO, x::DataTag{ID,T}) where {ID,T}
	_showcompact(io, DataTag{ID,T})
	print(io, "(", x.v, ")")
end

#Last line
