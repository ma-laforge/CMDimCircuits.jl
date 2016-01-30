#Demo 10: Delay tests
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = axes(ylabel="Amplitude (V)", xlabel="Time (s)")
dpsvst = axes(ylabel="Delay (ps)", xlabel="Time (s)")
dpsvsx = axes(ylabel="Delay (ps)", xlabel="Crossing")
ldelay = line(width=3)
gdelay = glyph(shape=:x, size=2)


#==Input data
===============================================================================#
tbit = 1e-9 #Bit period
osr = 20 #samples per bit
nsamples = 127


#==Computations
===============================================================================#
seq = 1.0*prbs(reglen=7, seed=1, nsamples=nsamples)
t = DataF1(0:(tbit/osr):(nsamples*tbit))
tmax = maximum(t)

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("tau", tbit.*[1/5, 1/2.5, 1/1.5])
]

#Generate data:
Π = DataHR{DataF1}(sweeplist) #Create empty pattern
for inds in subscripts(Π)
	(tau,) = coordinates(Π, inds)
	_Π = pulse(t, Pole(1/tau,:rad), tpw=tbit)
	Π.elem[inds...] = _Π
end

pat = (pattern(seq, Π, tbit=tbit)-0.5)*2 #Centered pattern
refpat = pat.elem[1]
Δ = measdelay(refpat, pat, xing1=CrossType(:risefall), xing2=CrossType(:risefall))
Δxn = measdelay(Event, refpat, pat, xing1=CrossType(:risefall), xing2=CrossType(:risefall))


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Signal Delay Tests", displaylegend=false)
s = add(plot, vvst, title="Reference Pattern")
	add(s, refpat)
s = add(plot, vvst, title="Patterns")
	add(s, pat, id="pat")
s = add(plot, dpsvst, title="Delays")
	add(s, Δ/1e-12, id="delays", ldelay, gdelay)
s = add(plot, dpsvsx, title="Delays vs Crossing Number")
	add(s, Δxn/1e-12, id="delays", ldelay, gdelay)


#==Return plot to user (call evalfile(...))
===============================================================================#
ncols = 1
(plot, ncols)
