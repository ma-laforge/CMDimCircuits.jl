#Demo 7: Eye diagrams
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = axes(xlabel="Time (s)", ylabel="Amplitude (V)")
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


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Eye Diagram Tests", displaylegend=false)
s = add(plot, vvst, title="Pattern")
	add(s, pat, id="pat")
s = add(plot, vvst, title="Eye", eyeparam(tbit, teye=1.5*tbit, tstart=-.15*tbit))
	add(s, pat, id="eye")


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
