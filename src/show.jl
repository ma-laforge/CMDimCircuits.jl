#CircuitAnalysis show functions
#-------------------------------------------------------------------------------


#==Generate friendly show functions
===============================================================================#

Base.show{T}(io::IO, t::Type{TImpedance{T}}) = print(io, "TImpedance{$T}")
Base.show{T}(io::IO, t::Type{TAdmittance{T}}) = print(io, "TAdmittance{$T}")
Base.show{T}(io::IO, t::Type{TInductance{T}}) = print(io, "TInductance{$T}")
Base.show{T}(io::IO, t::Type{TCapacitance{T}}) = print(io, "TCapacitance{$T}")

#Last line
