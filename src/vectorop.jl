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

#==timespace: Generates time vector (range) from sampling period & fundamental.
Automatically computes # of time steps, N.
Why? Computation of N can easily be off-by-1 - if specified directly...
NOTE:
  -First argument is targeted argument (will minimize amount of rounding).
  -Cannot represent tfund exactly (because maximum(timespace(...)) = tfund-ts).
   You would therefore need to define a new "range" type to represent tfund
   exactly. TODO??==#

timespace(primary::Symbol, v1, secondary::Symbol, v2; kwargs...) =
	timespace(DS{primary}(), DS{secondary}(), v1, v2; kwargs...)
timespace{T1, T2}(::DS{T1}, ::DS{T2}, args...; kwargs...) =
	throw(ArgumentError("timespace does not support combination (:$T1, :$T2)."))

#Sampling period (timestep), ts is most important parameter:
#Will throw error if "suggested" fundamental period does not land on the timestep:
function timespace(::DS{:ts}, ::DS{:tfund}, ts, tfund; tstart=0)
	const ABSTOL = .05
	ns = tfund/ts
	ins = round(Int, ns)
	if abs(ns-ins) > ABSTOL
		throw("tfund must be approx. an integer multiple of ts.")
	end
	return tstart+StepRangeLen{DataFloat}(0:ts:((ins-1)*ts))
end

#Fundamental period, tfund, is most important parameter.
#Will throw error if fundamental period does not land on the "suggested" timestep:
function timespace(::DS{:tfund}, ::DS{:ts}, tfund, ts; tstart=0)
	const ABSTOL = .05
	ns = tfund/ts
	ins = round(Int, ns)
	if abs(ns-ins) > ABSTOL
		throw("tfund must be approx. an integer multiple of ts.")
	end
	ts = tfund/ins #Re-compute most accurate possible version of timestep
	return tstart+StepRangeLen{DataFloat}(0:ts:((ins-1)*ts))
end

function timetofreq(t::StepRangeLen{DataFloat})
	n = length(t)
	Δt = step(t)
	tfund = Δt*n
	Δf = 1/tfund
	fmax = (floor(n/2)/n)/Δt
	return 0:Δf:fmax
end

function freqtotime(f::StepRangeLen{DataFloat}, teven::Bool)
	tfund = 1/step(f)
	n = 2*length(f) - 1
	if teven
		n -= 1
	end
	Δt = tfund/n
	return timespace(:ts, Δt, :tfund, tfund)
end

#Last line
