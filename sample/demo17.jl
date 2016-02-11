#Demo 17: Rise/fall tests
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = axes(ylabel="Amplitude (V)", xlabel="Time (s)")
rfpsvst = axes(ylabel="Rise/Fall (ps)", xlabel="Time (s)")
ldelay = line(width=3)
gdelay = glyph(shape=:x, size=2)


#==Input data
===============================================================================#
tbit = 1e-9 #Bit period
osr = 20 #samples per bit
nsamples = 127
amp = 2


#==Computations
===============================================================================#
seq = 1.0*prbs(reglen=7, seed=1, nsamples=nsamples)
t = DataF1(0:(tbit/osr):(nsamples*tbit))
tmax = maximum(t)

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("tau", tbit.*[1/2.5])
]

#Generate data:
Π = fill(DataHR, sweeplist) do tau
	return pulse(t, Pole(1/tau,:rad), tpw=tbit)
end

pat = (pattern(seq, Π, tbit=tbit)-0.5)*amp #Center data pattern

lthresh = -1+amp*.2 #20%
hthresh = -1+amp*.8 #80%
trise = measrise(pat, lthresh=lthresh, hthresh=hthresh)
tfall = measfall(pat, lthresh=lthresh, hthresh=hthresh)


#==Generate plot
===============================================================================#
axrng = axes(xmax=tmax)
plot=EasyPlot.new(title="Rise/Fall Tests", displaylegend=false)
s = add(plot, axrng, vvst, title="Patterns")
	add(s, pat, id="pat")
s = add(plot, axrng, rfpsvst, title="20-80 Rise/Fall Times")
	add(s, trise/1e-12, id="", ldelay, gdelay)
	add(s, tfall/1e-12, id="", ldelay, gdelay)


#==Return plot to user (call evalfile(...))
===============================================================================#
ncols = 1
(plot, ncols)
