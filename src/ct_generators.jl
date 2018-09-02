#SignalProcessing: Discrete-time-domain dataset generators
#-------------------------------------------------------------------------------

#Creates step function of a single-pole system, using time from ref.x:
#-------------------------------------------------------------------------------
function Base.step(ref::DataF1, p::Pole; tdel=0, amp=1)
	#H(s) = 1/(s*tau+1)
	npoints = length(ref) #WANTCONST
	e = Base.MathConstants.e
	x = ref.x
	one_tau = value(:rad, p) #1/tau
	y = zero(ref.y)

	#Find first point where x>=tdel:
	istart = npoints+1
	for i in 1:npoints
		if x[i] >= tdel; istart=i; break; end
	end
	for i in istart:npoints
		y[i]=amp*(1-e^(-(x[i]-tdel)*one_tau))
	end
	return DataF1(x, y)
end

#Creates pulse response of a single-pole system, using time from ref.x:
# tpw: pulse width
#-------------------------------------------------------------------------------
function pulse(ref::DataF1, p::Pole; tdel=0, amp=1, tpw::Number=0)
	ensure(tpw > 0, ArgumentError("tpw must be positive"))
	return (step(ref, p, tdel=tdel, amp=amp) -
		step(ref, p, tdel=tdel+tpw, amp=amp))
end


#Creates a signal pattern from a sequence of data points, and a pulse response:
# seq: a binary data sequence
# Π: Pulse response
# tbit: bit period
function pattern(seq::Vector{T}, Π::DataF1; tbit::Number=0) where {T<:Number}
	ensure(tbit > 0, ArgumentError("tbit must be positive"))
	result = 0
	for i in 1:length(seq)
		result += seq[i]*xshift(Π, (i-1)*tbit)
	end
	return result
end
pattern(seq::DataF1, Π::DataF1; tbit::Number=0) = pattern(seq.y, Π, tbit = tbit)

#Broadcast 1-arguent function with reference DataF1 @ 2nd arg.
pattern(d1, d2::DataMD, args...; kwargs...) =
	broadcastMD(CastType(DataF1,2), pattern, d1, d2, args...; kwargs...)


#==HACK: Find a way to register these functions differently.
Options:
	Move functions to MDDatsets
	Create broadcasting macro
	...
==#


#Last line
