#SignalProcessing: Discrete-time-domain dataset generators
#-------------------------------------------------------------------------------

#Creates step response, using time from ref.x:
#-------------------------------------------------------------------------------
function Base.step(::Type{DTDomain}, ref::Data2D; ndel::Index=Index(0), amp=1)
	ndel = value(ndel)
	@assert(ndel > 0, "ndel must be positive")
	y = zeros(ref.y)

	if ndel <= length(y)
		for i in ndel:length(y)
			y[i] = amp
		end
	end
	return Data2D(ref.x, y)
end

#Creates pulse response, using time from ref.x:
#-------------------------------------------------------------------------------
function pulse(D::Type{DTDomain}, ref::Data2D; ndel::Index=Index(0), amp=1,
		npw::Index=Index(0)) #Must provide npw
	@assert(value(npw) > 0, "npw must be positive")
	return (step(D, ref, ndel=ndel, amp=amp) -
		step(D, ref, ndel=ndel+npw, amp=amp))
end

#Last line
