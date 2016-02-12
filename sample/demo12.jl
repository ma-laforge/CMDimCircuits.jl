#Demo 12: Eye diagrams, shifting, multiple channels, etc
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vch_vs_t = axes(ylabel="Scaled Amp (V) @ Channel #", xlabel="Time (s)")
vch_vs_ui = axes(ylabel="Scaled Amp (V) @ Channel #", xlabel="Symbol Time (UI)")
eyech_v_ui = axes(ylabel="Scaled Amp (V) @ Channel #", xlabel="Symbol Time (UI)")


#==Input data
===============================================================================#
nchannels = 3
osr = 20 #samples per bit
nsamples = 127
skewmax = 100e-12 #+/- maximum skew a channel can exhibit
tbitVec = 1e-9*[1, 1/3, 1/5] #Bit periods to "simulate"
tau = 1e-9/8 #Circuit time constant
nbit_Π = 5 #Π-pulse length, in number of bits


#==Computations
===============================================================================#
#Generate a different PRBS sequenc for each channel:
seqVec = []
for seed in [11, 35, 2]
	push!(seqVec, 1.0*prbs(reglen=7, seed=seed, nsamples=nsamples))
end

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("tbit", tbitVec)
]

#Generate data (like a simulator would do):
#-------------------------------------------------------------------------------
Π = fill(DataHR, sweeplist) do tbit
	tΠ = DataF1(0:(tbit/osr):(nbit_Π*tbit))
	return pulse(tΠ, Pole(1/tau,:rad), tpw=tbit)
end

seq = DataHR[] #Broadcastable version of prbs sequence - include undefined @ start
pat = DataHR[]
tbit = parameter(Π, "tbit")
for i in 1:nchannels
	curseq = fill(DataHR{DataF1}, sweeplist) do tbit
		undefdata = rand(0:1.0, 5) #Each test/channel gets different undefined data
		_seq = vcat(undefdata, zeros(10), seqVec[i])
		return DataF1(collect(1:length(_seq)), _seq)
	end
	push!(seq, curseq)
	Δ = rand(-skewmax:1e-12:skewmax) #Each channel is skewed differently
	push!(pat, pattern(curseq, xshift(Π, Δ), tbit=tbit))
end

#Compute derived data:
#-------------------------------------------------------------------------------
tskipundef = 10*tbit #Starting point for skipping over undefined data
#Reference channel #1 for starting point:
tstart = xcross1(pat[1]-0.5, xstart=tskipundef, allow=CrossType(:rise))
#NOTE: tstart is not really necessary. tskipundef would be sufficient.

#Show that something happened
@show tskipundef 
@show tstart

#Pattern suitable for eye diagram (position start time @ t=0 & t-normalized)
eyepat = DataHR[]
for i in 1:nchannels
	curpat = xscale(xshift(pat[i], tbit/4-tstart), 1/tbit)
	push!(eyepat, curpat)
end

#Compute undefined data (normalized by tbit for readability)
#-------------------------------------------------------------------------------
undefdata = DataHR[]
for i in 1:nchannels
	curpat = xscale(clip(pat[i], xmax=20*tbit), 1/tbit)
	push!(undefdata, curpat)
end


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Normalized Eye Diagrams", displaylegend=false)
s = add(plot, vch_vs_ui, title="Initial Undefined Pattern")
for i in 1:nchannels
	add(s, (i-1)+(undefdata[i]-0.5)*.8, id="pat[$i]") #Re-center around channel number
end
s = add(plot, eyech_v_ui, title="Eye", eyeparam(1, teye=1.5))
for i in 1:nchannels
	add(s, (i-1)+(eyepat[i]-0.5)*.8, id="pat[$i]") #Re-center around channel number
end
s = add(plot, vch_vs_t, title="Pattern")
for i in 1:nchannels
	add(s, (i-1)+(pat[i]-.5)*.8, id="pat[$i]") #Re-center around channel number
end


#==Return plot to user (call evalfile(...))
===============================================================================#
ncols = 2
(plot, ncols)
