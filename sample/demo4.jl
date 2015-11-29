#Demo 4: Multi-dimensional datasets
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
nsamples = 20


#==Computations
===============================================================================#
seq = 1.0*prbs(reglen=5, seed=1, nsamples=nsamples)
tΠ = DataF1(0:(tbit/osr):(nbit_Π*tbit)) #Time of a single pulse

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("amp", [.8, 1, 1.2])
	PSweep("tau", (tbit/5).*[.5, 1, 2])
	PSweep("offset", [-1, 0, 1])
]

#Generate data:
Π = DataHR{DataF1}(sweeplist) #Create empty results
amp = DataHR{DataFloat}(sweeplist) #Create empty results
offset = DataHR{DataFloat}(sweeplist) #Create empty results
for coord in subscripts(Π)
	(_amp, tau, _offset) = parameter(Π, coord)
	_Π = pulse(tΠ, Pole(1/tau,:rad), tpw=tbit)
	Π.subsets[coord...] = _Π
	amp.subsets[coord...] = _amp
	offset.subsets[coord...] = _offset
end

pat = pattern(seq, Π, tbit=tbit)
pat = (pat-0.5)*amp + offset
t = xval(pat)

#Do some DataHR-level transformations:
result = pat
tmax = tbit*(nsamples+nbit_Π-1)
skew = DataF1([0, tmax],[0, 0.5])
result = result + result + 4 + skew
result += mean(result)


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Mulit-Dataset Tests", displaylegend=false)
s = add(plot, vvst, title="PRBS Pattern")
	add(s, result, id="pat")


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
