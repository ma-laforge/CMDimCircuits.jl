#SignalProcessing: Discrete-time-domain dataset generators
#-------------------------------------------------------------------------------

#==Constants
===============================================================================#

#Integer representation of polynomial x^p1 + x^p2 + x^p3 + x^p4 + 1
_poly(p1::Int) = one(UInt64)<<(p1-1)
_poly(p1::Int, p2::Int) = _poly(p1) + _poly(p2)
_poly(p1::Int, p2::Int, p3::Int, p4::Int) = _poly(p1) + _poly(p2) + _poly(p3) + _poly(p4)

#==Maximum-length LFSR polynomials/taps (XNOR form)
Ref: Alfke, Efficient Shift Registers, LFSR Counters, and Long Pseudo-Random
     Sequence Generators, Xilinx, XAPP 052, v1.1, 1996.==#
const MAXLFSR_POLYNOMIAL = [
	_poly(64,64) #1: not supported
	_poly(64,64) #2: not supported
	_poly(3,2) #3
	_poly(4,3) #4
	_poly(5,3) #5
	_poly(6,5) #6
	_poly(7,6) #7
	_poly(8,6,5,4) #8
	_poly(9,5) #9
	_poly(10,7) #10
	_poly(11,9) #11
	_poly(12,6,4,1) #12
	_poly(13,4,3,1) #13
	_poly(14,5,3,1) #14
	_poly(15,14) #15
	_poly(16,15,13,4) #16
	_poly(17,14) #17
	_poly(18,11) #18
	_poly(19,6,2,1) #19
	_poly(20,17) #20
	_poly(21,19) #21
	_poly(22,21) #22
	_poly(23,18) #23
	_poly(24,23,22,17) #24
	_poly(25,22) #25
	_poly(26,6,2,1) #26
	_poly(27,5,2,1) #27
	_poly(28,25) #28
	_poly(29,27) #29
	_poly(30,6,4,1) #30
	_poly(31,28) #31
	_poly(32,22,2,1) #32
]

#Creates step response, using time from ref.x:
#-------------------------------------------------------------------------------
function Base.step(::Type{DTDomain}, ref::DataF1; ndel::Index=Index(0), amp=1)
	ndel = value(ndel)
	@assert(ndel >= 0, "ndel must be non-negative")
	nstart = ndel+1
	y = zeros(ref.y)

	if nstart <= length(y)
		for i in nstart:length(y)
			y[i] = amp
		end
	end
	return DataF1(ref.x, y)
end

#Creates pulse response, using time from ref.x:
#-------------------------------------------------------------------------------
function pulse(D::Type{DTDomain}, ref::DataF1; ndel::Index=Index(0), amp=1,
		npw::Index=Index(0))
	@assert(value(npw) > 0, "npw must be positive")
	return (step(D, ref, ndel=ndel, amp=amp) -
		step(D, ref, ndel=ndel+npw, amp=amp))
end

#Creates pulse response of a single-pole system, using time from ref.x:
# tpw: pulse width
#-------------------------------------------------------------------------------
function pulse(D::Type{DTDomain}, ref::DataF1, p::Pole; ndel::Index=Index(0), amp=1,
		npw::Index=Index(0))
	ndel = value(ndel); npw = value(npw)
	@assert(npw > 0, "npw must be positive")
	tdel = ref.x[1+ndel]
	tpw = ref.x[1+ndel+npw]-tdel
	#Simple wrapper, for now:
	return pulse(CTDomain, ref, p::Pole, tdel=tdel, amp=amp, tpw=tpw)
end

#Creates PRBS sequence, using time from ref.x:
#TODO: should the vector by of type Bool?
#-------------------------------------------------------------------------------
function prbs(D::Type{BitDomain}; reglen::Int=32, seed::Integer=11, nsamples::Int=0)
	@assert(nsamples > 0, "nsamples must be positive")
	@assert(in(reglen, 3:32), "Invalid value: 3 <= reglen <= 32")

	lfsr = UInt64(seed)
	msb = UInt64(1)<<(reglen-1)
	pat = zeros(Bool, nsamples)
	poly = UInt64(MAXLFSR_POLYNOMIAL[reglen])
	mask = ~poly
	#==Since 1 XNOR A => A, we can ignore all taps that are not part of the
	polynomial, simply by forcing all non-tap bits to 1 (OR-ing with ~poly)
	==#

	for i in 1:length(pat)
		reg = lfsr | mask
		bit = msb
		for j in 1:reglen
			bit = ~(reg $ bit) #XNOR
			reg <<= 1
		end
		bit = Int((bit & msb) > 0) #Convert resultant MSB to an integer
		pat[i] = bit
		lfsr = (lfsr << 1) | bit
	end
	return DataF1(collect(1:length(pat)), pat)
end

#Creates a signal pattern from a sequence of data points, and a pulse response:
#NOTE: assumes constant x step-size... Is this the way to do it??
# seq: a binary data sequence
# p:Pulse response
function pattern(D::Type{DTDomain}, seq::DataF1, p::DataF1; npw::Index=Index(0))
	npw = value(npw)
	@assert(npw > 0, "npw must be positive")
	result = zeros(p)
	for i in 1:length(seq)
		result.y += seq.y[i]*shift(p.y, (i-1)*npw)
	end
	return result
end


#Last line
