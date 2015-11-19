#Demo 4: Multi-dimensional datasets
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
nsamples = 20


#==Computations
===============================================================================#
seq = 1.0*prbs(BT, reglen=5, seed=1, nsamples=nsamples)
t = DataF1(0:(tbit/osr):(nsamples*tbit))
tmax = maximum(t)

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("amp", [.8, 1, 1.2])
	PSweep("tau", (tbit/5).*[.5, 1, 2])
	PSweep("offset", [-1, 0, 1])
]

#Generate data:
results = DataHR{DataF1}(sweeplist) #Create empty results
for coord in subscripts(results)
	(amp, tau, offset) = parameter(results, coord)
	p = pulse(DT, t, Pole(1/tau,:rad), npw=Index(osr))
	pat = pattern(DT, seq, p, npw=Index(osr))
	pat = (pat-0.5)*amp + offset
	results.subsets[coord...] = pat
end

#Do some DataHR-level transformations:
skew = DataF1([0, tmax],[0, 0.5])
results = results + results + 4 + skew
results += mean(results)


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Mulit-Dataset Tests", displaylegend=false)
s = add(plot, vvst, title="PRBS Pattern")
	add(s, results, id="pat")

#==You could manually add individual datasets:
sweepnames = names(sweeps(results))
colorlist = [color1, color2, color3]
for coord in subscripts(results)
	values = parameter(results, coord)
	id=join(["$k=$v" for (k,v) in zip(sweepnames,values)], " / ")
	add(s, subsets(results)[coord...], colorlist[coord[1]], id=id)
end
==#


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
