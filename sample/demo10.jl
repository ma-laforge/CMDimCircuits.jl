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
ldelay = line(width=3, style=:solid)
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
	PSweep("L", [1]) #Add extra level to test more code
	PSweep("tau", tbit.*[1/5, 1/2.5, 1/1.5])
]

#Generate data:
Π = fill(DataHR, sweeplist) do EL, tau
	return pulse(t, Pole(1/tau,:rad), tpw=tbit)
end

pat = (pattern(seq, Π, tbit=tbit)-0.5)*2 #Center data pattern
refpat = pat.elem[1]
Δ = measdelay(refpat, pat, xing_ref=CrossType(:risefall), xing_main=CrossType(:risefall))
Δxn = measdelay(Event, refpat, pat, xing_ref=CrossType(:risefall), xing_main=CrossType(:risefall))
Δ = DataRS(Δ) #Test support for DataRS objects


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Signal Delay Tests", displaylegend=true)
s = add(plot, vvst, title="Patterns")
	wfrm = add(s, refpat, id="Ref")
		set(wfrm, line(width=5, color=:black))
	add(s, pat, id="pat")
s = add(plot, dpsvst, title="Delays")
	add(s, Δ/1e-12, id="D", ldelay, gdelay)
s = add(plot, dpsvsx, title="Delays vs Crossing Number")
	add(s, Δxn/1e-12, id="D", ldelay, gdelay)


#==Return plot to user (call evalfile(...))
===============================================================================#
plot.ncolumns = 1
plot
