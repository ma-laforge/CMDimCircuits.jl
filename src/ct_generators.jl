#SignalProcessing: Discrete-time-domain dataset generators
#-------------------------------------------------------------------------------

#Creats step function of a single-pole system, using time from ref.x:
#-------------------------------------------------------------------------------
function Base.step(::Type{CTDomain}, ref::Data2D, p::Pole; tdel=0, amp=1)
	#H(s) = 1/(s*tau+1)
	const npoints = length(ref)
	t = ref.x
	one_tau = value(:rad, p) #1/tau
	y = zeros(ref.y)

	#Find first point where t>=tdel:
	istart = npoints+1
	for i in 1:npoints
		if t[i] >= tdel; istart=i; break; end
	end
	for i in istart:npoints
		y[i]=amp*(1-e^(-(t[i]-tdel)*one_tau))
	end
	return Data2D(t, y)
end

#Creates pulse response of a single-pole system, using time from ref.x:
# tpw: pulse width
#-------------------------------------------------------------------------------
function pulse(D::Type{CTDomain}, ref::Data2D, p::Pole; tdel=0, amp=1, tpw::Number=0)
	@assert(tpw > 0, "tpw must be positive")
	return (step(D, ref, p, tdel=tdel, amp=amp) -
		step(D, ref, p, tdel=tdel+tpw, amp=amp))
end

#Last line
