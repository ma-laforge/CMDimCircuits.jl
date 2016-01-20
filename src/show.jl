#NetwAnalysis show functions
#-------------------------------------------------------------------------------


#==Generate friendly show functions
===============================================================================#

Base.show{NP}(io::IO, t::Type{NPType{NP}}) =	print(io, "NPType{:$NP}")

Base.show{T}(io::IO, t::Type{TImpedance{T}}) = print(io, "TImpedance{$T}")
Base.show{T}(io::IO, t::Type{TAdmittance{T}}) = print(io, "TAdmittance{$T}")
Base.show{T}(io::IO, t::Type{TInductance{T}}) = print(io, "TInductance{$T}")
Base.show{T}(io::IO, t::Type{TCapacitance{T}}) = print(io, "TCapacitance{$T}")

function Base.show(io::IO, np::SParameters)
	println(io, "SParameters{$(portcount(np))-port, z0=$(np.z0)}[")
	println(io, np.m)
	println(io, "]")
end

function Base.show(io::IO, np::ZParameters)
	println(io, "ZParameters{$(portcount(np))-port}[")
	println(io, np.m)
	println(io, "]")
end

function Base.show(io::IO, np::YParameters)
	println(io, "YParameters{$(portcount(np))-port}[")
	println(io, np.m)
	println(io, "]")
end

function Base.show(io::IO, np::ABCDParameters)
	println(io, "ABCDParameters[")
	println(io, np.m)
	println(io, "]")
end

#Last line
