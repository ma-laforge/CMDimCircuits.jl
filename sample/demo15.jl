#Demo 15: Skew tests
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = axes(ylabel="Amplitude (V)", xlabel="Time (s)")
dpsvst = axes(ylabel="Delay (ps)", xlabel="Time (s)")
dpsvsx = axes(ylabel="Delay (ps)", xlabel="Crossing")
ldelay = line(style=:solid, width=3)
gdelay = glyph(shape=:x, size=2)


#==Input data
===============================================================================#
tbit = 1e-9 #Bit period
osr = 20 #samples per bit
nsamples = 127
reglen = 7


#==Computations
===============================================================================#
#NOTE: Not a very computationnaly efficient/stable algorithm
seq = 1.0*prbs(reglen=reglen, seed=1, nsamples=nsamples)
t = DataF1(0:(tbit/osr):((nsamples)*tbit))
tmax = maximum(t)

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("del", tbit.*[-.05, 0, .1])
]

tauref = tbit/5
taupat = tbit/2.5
Πref = pulse(t, Pole(1/tauref,:rad), tpw=tbit)

#Step functions:
Ur = step(t, Pole(1/taupat,:rad), tdel=0)
Uf = -step(t, Pole(1/taupat,:rad), tdel=0*tbit)

#intvec(v) = [val>0?1:(val<0)?-1:0 for val in v]

#Rise/fall sequences
diffseq = diff(vcat(0,seq)) #Assumes starts @ 0.
seqr = 1.0*(diffseq.>0)
seqf = 1.0*(diffseq.<0)

#Rise/fall patterns:
patr = pattern(seqr, Ur, tbit=tbit)
patf = pattern(seqf, Uf, tbit=tbit)

#Complete pattern:
pat = fill(DataHR, sweeplist) do del
	return patr + xshift(patf, del)
end

pat = (pat-0.5)*2 #Center data pattern
pat = clip(pat, xmax=tmax)
patref = (pattern(seq, Πref, tbit=tbit)-0.5)*2 #Center data pattern
pat = xshift(pat, 4.5*tbit)
skew = measskew(patref, pat)
#skew=()
for (k, v) in skew
	println("\n", k, "/1p: ", v/1e-12)
end
del = parameter(pat, "del")
println("\n", "fall delay/1p: ", del/1e-12)


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Signal Skew Tests", displaylegend=true)
s = add(plot, vvst, title="Reference Pattern")
	add(s, patref)
#	add(s, Π)
s = add(plot, vvst, title="Patterns")
	add(s, pat, id="pat")
s = add(plot, vvst, title="Eye", eyeparam(tbit, teye=1.5*tbit, tstart=4.5*tbit))
	add(s, pat, id="patterns")
s = add(plot, dpsvst, title="Rise Delays")
	add(s, skew[:mean_delrise]/1e-12, id="mean", ldelay, gdelay)
	add(s, skew[:min_delrise]/1e-12, id="min", ldelay, gdelay)
	add(s, skew[:max_delrise]/1e-12, id="max", ldelay, gdelay)
s = add(plot, dpsvst, title="Fall Delays")
	add(s, skew[:mean_delfall]/1e-12, id="mean", ldelay, gdelay)
	add(s, skew[:min_delfall]/1e-12, id="min", ldelay, gdelay)
	add(s, skew[:max_delfall]/1e-12, id="max", ldelay, gdelay)


#==Return plot to user (call evalfile(...))
===============================================================================#
ncols = 1
(plot, ncols)
