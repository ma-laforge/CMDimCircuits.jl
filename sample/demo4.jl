#Demo 4: Multi-dimensional datasets
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = axes(xlabel="Time (s)", ylabel="Amplitude (V)")
color1 = line(color=2)
color2 = line(color=3)
color3 = line(color=4)
BT = Domain{:bit}
DT = Domain{:DT}
CT = Domain{:CT}


#==Input data
===============================================================================#
nbit = 20 #samples per bit
tbit = 1e-9 #Bit period
nsamples = 20


#==Computations
===============================================================================#
seq = 1.0*prbs(BT, reglen=5, seed=1, nsamples=nsamples)
t = Data2D(0:(tbit/nbit):(nsamples*tbit))
tmax = maximum(t)

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("amp", [.8, 1, 1.2])
	PSweep("tau", (tbit/5).*[.5, 1, 2])
	PSweep("offset", [-1, 0, 1])
]

#Generate data:
results = DataHR{Data2D}(sweeplist) #Create empty results
for coord in subscripts(results)
	(amp, tau, offset) = parameter(results, coord)
	p = pulse(DT, t, Pole(1/tau,:rad), npw=Index(nbit))
	pat = pattern(DT, seq, p, npw=Index(nbit))
	pat = (pat-0.5)*amp + offset
	results.subsets[coord...] = pat
end

#Do some DataHR-level transformations:
skew = Data2D([0, tmax],[0, 0.5])
results = results + results + 4 + skew
results += mean(results)

#mean(results)

#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Mulit-Dataset Tests")
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
	display(Backend{:MPL}, plot, ncols=ncols);
end


:Test_Complete
