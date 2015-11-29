#Demo 7: Eye diagrams
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = axes(ylabel="Amplitude (V)", xlabel="Time (s)")


#==Input data
===============================================================================#
tbit = 1e-9 #Bit period
osr = 20 #samples per bit
nbit_Π = 5 #Π-pulse length, in number of bits
nsamples = 127

#==Computations
===============================================================================#
seq = 1.0*prbs(reglen=7, seed=1, nsamples=nsamples)
tΠ = DataF1(0:(tbit/osr):(nbit_Π*tbit))

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("tau", tbit.*[1/5, 1/2.5, 1/1.5])
]

#Generate data:
Π = DataHR{DataF1}(sweeplist) #Create empty pattern
for coord in subscripts(Π)
	(tau,) = parameter(Π, coord)
	_Π = pulse(tΠ, Pole(1/tau,:rad), tpw=tbit)
	Π.subsets[coord...] = _Π
end
pat = (pattern(seq, Π, tbit=tbit)-0.5)*2 #Centered pattern


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
