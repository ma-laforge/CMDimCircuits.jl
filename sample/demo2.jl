#Demo 2: Data patterns
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
tvsbit = axes(ylabel="Value", xlabel="Bit Position")
vvst = axes(ylabel="Amplitude (V)", xlabel="Time (s)")
color1 = line(color=:red)
color2 = line(color=:blue)


#==Input data
===============================================================================#
tbit = 1e-9 #Bit period
osr = 20 #samples per bit
nsamples = 20


#==Computations
===============================================================================#
seq = 1.0*prbs(reglen=5, seed=1, nsamples=nsamples)
#seq = [1,0,1,1,1,0,0,0]
nsamples = length(seq)
t = DataTime(0:(tbit/osr):(nsamples*tbit))
p = pulse(t, Pole(3/tbit,:rad), npw=Index(osr))
pat = pattern(seq, p, nbit=Index(osr))


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Generating Patterns")
s = add(plot, tvsbit, title="PRBS Sequence")
	add(s, DataF1(collect(1:length(seq)), seq), color2)
s = add(plot, vvst, title="PRBS Pattern")
	add(s, DataF1(p), color1, id="Pulse")
	add(s, DataF1(pat), color2, id="Pattern")


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

