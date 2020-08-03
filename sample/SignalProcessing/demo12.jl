#Demo 12: Eye diagrams, shifting, multiple channels, etc
#-------------------------------------------------------------------------------

using CMDimCircuits
CMDimCircuits.@using_CData()

#Get a demo display:
include(CMDimCircuits.demoplotcfgscript); pdisp = getdemodisplay()
#Normally use something like:
#CMDimData.@includepkg EasyPlotInspect; pdisp = EasyPlotInspect.PlotDisplay()


#==Constants
===============================================================================#
vch_vs_t = cons(:a, labels = set(yaxis="Centered @ ch#", xaxis="Time (s)"))
vch_vs_ui = cons(:a, labels = set(yaxis="Centered @ ch#", xaxis="Symbol Time (UI)"))


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


#==Helper functions
===============================================================================#
#Scale/shift data to center by channel number:
_scaleshift(data, chnum) = (chnum-1)+(data-0.5)*.8

#TODO: supply eyeparam() as a FoldedAxis or Plot constructor???
eyeparam(tbit; teye=1.5*tbit, tstart=0) = cons(:a,
	xfolded = set(tbit, xstart=tstart, xmax=teye),
	xaxis = set(min=0, max=teye), #Force limits on exact data range.
)


#==Generate plot
===============================================================================#
p1 = cons(:plot, vch_vs_ui, title="Initial Undefined Pattern")
for i in 1:nchannels
	push!(p1, cons(:wfrm, _scaleshift(undefdata[i], i), label="pat[$i]"))
end
p2 = cons(:plot, vch_vs_ui, eyeparam(1.0, teye=1.5), title="Eye")
for i in 1:nchannels
	push!(p2, cons(:wfrm, _scaleshift(eyepat[i], i), label="pat[$i]"))
end
p3 = cons(:plot, vch_vs_t, title="Pattern")
for i in 1:nchannels
	push!(p3, cons(:wfrm, _scaleshift(pat[i], i), label="pat[$i]"))
end

pcoll = push!(cons(:plotcoll, title="Normalized Eye Diagrams (shifted around channel #)"), p1, p2, p3)
	pcoll.displaylegend = false
	pcoll.ncolumns = 2


#==Display results in pcoll
===============================================================================#
display(pdisp, pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll #Will display pcoll a second time if executed from REPL
