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

#Creates an ideal step response, using time from ref:
#-------------------------------------------------------------------------------
function Base.step(ref::DataTime; ndel::Index=Index(0), amp=1)
	ndel = value(ndel)
	#ASSERT INCREASING
	t = ref.data.t
	xt = zeros(t)
	istart = ceil(Int, 1-(t[1]/step(t))) #succeptible to round-offs?
	istart += ndel
	istart = max(istart, 1)

	for i in istart:length(xt)
		xt[i] = amp
	end
	return DataTime(t, xt)
end

#Creates an ideal pulse response, using time from ref:
#-------------------------------------------------------------------------------
function pulse(ref::DataTime; ndel::Index=Index(0), amp=1, npw::Index=Index(0))
	ensure(value(npw) > 0, ArgumentError("npw must be positive"))
	t = ref.data.t
	xt = (step(ref, ndel=ndel, amp=amp).data.xt .-
		step(ref, ndel=ndel+npw, amp=amp).data.xt)
	return DataTime(t, xt)
end

#Creates pulse response of a single-pole system, using time from ref.x:
# tpw: pulse width
#-------------------------------------------------------------------------------
function pulse(ref::DataTime, p::Pole; ndel::Index=Index(0), amp=1, npw::Index=Index(0))
	ndel = value(ndel); npw = value(npw)
	ensure(npw > 0, ArgumentError("npw must be positive"))
	t = ref.data.t
	#Simple wrapper using continuous-time algoritm, for now:
	tdel = step(t)*ndel
	tpw = step(t)*npw
	Π = pulse(DataF1(t), p, tdel=tdel, amp=amp, tpw=tpw)
	return DataTime(ref.data, Π.y)
end

#Creates PRBS sequence, using time from ref.x:
#TODO: should the vector by of type Bool?
#-------------------------------------------------------------------------------
function prbs(; reglen::Int=32, seed::Integer=11, nsamples::Int=0)
	ensure(nsamples > 0, ArgumentError("nsamples must be positive"))
	ensure(in(reglen, 3:32), ArgumentError("Invalid value: 3 <= reglen <= 32"))

	lfsr = UInt64(seed)
	msb = UInt64(1)<<(reglen-1)
	seq = zeros(Bool, nsamples)
	poly = UInt64(MAXLFSR_POLYNOMIAL[reglen])
	mask = ~poly
	#==Since 1 XNOR A => A, we can ignore all taps that are not part of the
	polynomial, simply by forcing all non-tap bits to 1 (OR-ing with ~poly)
	==#

	for i in 1:length(seq)
		reg = lfsr | mask
		bit = msb
		for j in 1:reglen
			bit = ~(reg $ bit) #XNOR
			reg <<= 1
		end
		bit = Int((bit & msb) > 0) #Convert resultant MSB to an integer
		seq[i] = bit
		lfsr = (lfsr << 1) | bit
	end
	return seq
end

#Creates a signal pattern from a sequence of data points, and a pulse response:
# seq: a binary data sequence
# p:Pulse response
# nbit: Number of sampling steps in a bit period.
#TODO: shift x instead of y???
#TODO: Add DataTime vectors directly once implemented
function pattern{T<:Number}(seq::Vector{T}, p::DataTime; nbit::Index=Index(0))
	nbit = value(nbit)
	ensure(nbit > 0, ArgumentError("nbit must be positive"))
	result = zeros(p.data.xt)
	for i in 1:length(seq)
		result += seq[i]*yshift(p, Index((i-1)*nbit)).data.xt
	end
	return DataTime(p.data, result)
end


#Last line
