#SignalProcessing: Vector operations
#-------------------------------------------------------------------------------


#==Helper functions
===============================================================================#
evenlength(v::AbstractArray) = (0 == (length(v) % 2))


#==Obtain a data vector (TODO: move to MDDatatsets?)
===============================================================================#

datavec(s::Symbol, args...; kwargs...) = datavec(DS{s}(), args...; kwargs...)
datavec{T<:Symbol}(::DS{T}, args...; kwargs...) = throw(ArgumentError("Unknown vector type: $T"))


#==Range generators
===============================================================================#

#Creates a range practical for doing signal analyses correctly:
#NOTE: first argument is targeted argument (will not get rounded)
timespace(primary::Symbol, v1, secondary::Symbol, v2; kwargs...) =
	timespace(DS{primary}(), DS{secondary}(), v1, v2; kwargs...)
timespace{T1, T2}(::DS{T1}, ::DS{T2}, args...; kwargs...) =
	throw(ArgumentError("timespace does not support combination (:$T1, :$T2)."))
function timespace(::DS{:ts}, ::DS{:tfund}, ts, tfund; tstart=0)
	const ABSTOL = .05
	ns = tfund/ts
	ins = round(Int, ns)
	if abs(ns-ins) > ABSTOL
		throw("tfund must be approx. an integer multiple of ts.")
	end
	return tstart+FloatRange{DataFloat}(0:ts:((ins-1)*ts))
end

function timetofreq(t::FloatRange{DataFloat})
	n = length(t)
	Δt = step(t)
	tfund = Δt*(n+1)
	Δf = 1/tfund
	fmax = (floor(n/2)/n)/Δt
	return 0:Δf:fmax
end

function freqtotime(f::FloatRange{DataFloat}, teven::Bool)
	tfund = 1/step(f)
	n = 2*length(f) - 1
	if teven
		n -= 1
	end
	Δt = tfund/n
	return timespace(:ts, Δt, :tfund, tfund)
end

#Last line
