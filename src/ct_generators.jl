#SignalProcessing: Time-domain dataset generators
#-------------------------------------------------------------------------------
#Creates a CT-step response, using time from ref.x:
#-------------------------------------------------------------------------------
function Base.step(::Type{CTDomain}, ref::Data2D, pos::DataIndex)
	pos = value(pos)
	@assert(pos > 0, "pos must be positive")
	y = zeros(ref.y)

	_one = one(typeof(y[1]))
	if pos <= length(y)
		for i in pos:length(y)
			y[i] = _one
		end
	end
	return Data2D(ref.x, y)
end

#Transient step function of a single-pole system, using time from ref.x:
#-------------------------------------------------------------------------------
function Base.step(::Type{CTDomain}, ref::Data2D, tdelay, A0, p::Pole)
	#H(s) = 1/(s*tau+1)
	const npoints = length(ref)
	t = ref.x
	one_tau = value(:rad, p) #1/tau
	y = zeros(ref.y)

	#Find first point where t>=tdelay:
	istart = npoints+1
	for i in 1:npoints
		if t[i] >= tdelay; istart=i; break; end
	end
	for i in istart:npoints
		y[i]=A0*(1-e^(-(t[i]-tdelay)*one_tau))
	end
	return Data2D(t, y)
end

#Creates pulse response, using time from ref.x:
#-------------------------------------------------------------------------------
function pulse(D::Type{CTDomain}, ref::Data2D, pos::DataIndex, pulsewidth::DataIndex)
	@assert(value(pulsewidth) > 0, "pulsewidth must be positive")
	return(step(D, ref, pos)-step(D, ref, pos+pulsewidth))
end

#Creates pulse response of a single-pole system, using time from ref.x:
#-------------------------------------------------------------------------------
function pulse(D::Type{CTDomain}, ref::Data2D, tdelay, A0, p::Pole, pulsewidth::Number)
	@assert(pulsewidth > 0, "pulsewidth must be positive")
	return(step(D, ref, tdelay, A0, p)-step(D, ref, tdelay+pulsewidth, A0, p))
end

#Last line
