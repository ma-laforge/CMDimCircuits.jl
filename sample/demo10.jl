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
BT = Domain{:bit}
DT = Domain{:DT}
CT = Domain{:CT}


#==Input data
===============================================================================#
tbit = 1e-9 #Bit period
osr = 20 #samples per bit
nsamples = 127


#==Computations
===============================================================================#
seq = 1.0*prbs(BT, reglen=7, seed=1, nsamples=nsamples)
t = DataF1(0:(tbit/osr):(nsamples*tbit))
tmax = maximum(t)

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("tau", tbit.*[1/5, 1/2.5, 1/1.5])
]

#Generate data:
pat = DataHR{DataF1}(sweeplist) #Create empty pattern
for coord in subscripts(pat)
	(tau,) = parameter(pat, coord)
	Π = pulse(DT, t, Pole(1/tau,:rad), npw=Index(osr))
	_pat = pattern(DT, seq, Π, npw=Index(osr))
	pat.subsets[coord...] = (_pat-0.5)*2 #Center pattern
end

refpat = pat.subsets[1]
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

#==Show results
===============================================================================#
ncols = 1
if !isdefined(:plotlist); plotlist = Set([:grace]); end
if in(:grace, plotlist)
	import EasyPlotGrace
	plotdefaults = GracePlot.defaults(linewidth=2.5)
	gplot = GracePlot.new()
		GracePlot.set(gplot, plotdefaults)
	render(gplot, plot, ncols=ncols); display(gplot)
end
if in(:MPL, plotlist)
	import EasyPlotMPL
	display(:MPL, plot, ncols=ncols);
end


:Test_Complete
