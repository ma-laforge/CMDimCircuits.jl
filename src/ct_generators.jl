#SignalProcessing: Discrete-time-domain dataset generators
#-------------------------------------------------------------------------------

import MDDatasets: broadcast1, broadcast2

#Creates step function of a single-pole system, using time from ref.x:
#-------------------------------------------------------------------------------
function Base.step(ref::DataF1, p::Pole; tdel=0, amp=1)
	#H(s) = 1/(s*tau+1)
	const npoints = length(ref)
	x = ref.x
	one_tau = value(:rad, p) #1/tau
	y = zeros(ref.y)

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
	@assert(tpw > 0, "tpw must be positive")
	return (step(ref, p, tdel=tdel, amp=amp) -
		step(ref, p, tdel=tdel+tpw, amp=amp))
end


#Creates a signal pattern from a sequence of data points, and a pulse response:
# seq: a binary data sequence
# Π: Pulse response
# tbit: bit period
function pattern{T<:Number}(seq::Vector{T}, Π::DataF1; tbit::Number=0)
	@assert(tbit > 0, "tbit must be positive")
	result = 0
	for i in 1:length(seq)
		result += seq[i]*xshift(Π, (i-1)*tbit)
	end
	return result
end
pattern(seq::DataF1, Π::DataF1; tbit::Number=0) = pattern(seq.y, Π, tbit = tbit)
pattern(d1, d2, args...; kwargs...) =
	broadcast2(DataF1, pattern, d1, d2, args...; kwargs...)


#==HACK: Find a way to register these functions differently.
Options:
	Move functions to MDDatsets
	Create broadcasting macro
	...
==#
const _custfn2 = [
]

#2-argument functions
for fn in vcat(_custfn2); @eval begin #CODEGEN------------------------

#fn(DataHR, DataHR):
$fn{T1, T2}(d1::DataHR{T1}, d2::DataHR{T2}, args...; kwargs...) =
	broadcast2(promote_type(T1,T2), $fn, d1, d2, args...; kwargs...)

#fn(DataHR, DataF1/Number):
$fn{T1,T2<:Union{DataF1,Number}}(d1::DataHR{T1}, d2::T2, args...; kwargs...) =
	broadcast2(promote_type(T1,T2), $fn, d1, d2, args...; kwargs...)

#fn(DataF1/Number, DataHR):
$fn{T1<:Union{DataF1,Number},T2}(d1::T1, d2::DataHR{T2}, args...; kwargs...) =
	broadcast2(promote_type(T1,T2), $fn, d1, d2, args...; kwargs...)

end; end #CODEGEN---------------------------------------------------------------


#Last line
