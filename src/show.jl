#SignalProcessing show functions
#-------------------------------------------------------------------------------

#==Generate friendly show functions
===============================================================================#

function Base.show{T,U}(io::IO, p::Pole{T, AbastractFrequency{U}})
	print(io, "Pole{$T,$U}($(p.v))")
end

function Base.show{T}(io::IO, ::Type{DS{T}})
	print(io, "DS{:$T}")
end

function Base.show{T}(io::IO, ::DS{T})
	print(io, "DispatchableSymbol:$T")
end

function Base.show(io::IO, d::DataTime)
	strtype = d.data.tperiodic?"Periodic":"Finite"
	print(io, "DataTime($strtype, t=", d.data.t, ", x(t)=", d.data.xt, ")")
end

function Base.show(io::IO, d::DataFreq)
	strtype = d.data.tperiodic?"Series":"Spectrum"
	print(io, "DataFreq($strtype, f=", d.data.f, ", X(f)=", d.data.Xf, ")")
end

#Last line
