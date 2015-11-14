#Demo 7: Eye diagrams
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
nsamples = 127


#==Computations
===============================================================================#
seq = 1.0*prbs(BT, reglen=7, seed=1, nsamples=nsamples)
t = DataF1(0:(tbit/nbit):(nsamples*tbit))
tmax = maximum(t)

tau = (tbit/1.5)
p = pulse(DT, t, Pole(1/tau,:rad), npw=Index(nbit))
pat = pattern(DT, seq, p, npw=Index(nbit))
pat = (pat-0.5)*2 #Center pattern


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Eye Diagram Tests", displaylegend=false)
s = add(plot, vvst, title="Pattern")
	add(s, pat, id="pat")
s = add(plot, vvst, title="Eye", eyeparam(tbit, teye=1.5*tbit))
	add(s, pat, id="eye", line(color=2))


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
