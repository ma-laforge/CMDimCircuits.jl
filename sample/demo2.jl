#Test code
#-------------------------------------------------------------------------------

#No real test code yet... just run demos:

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
tvsbit = axes(xlabel="Bit Position", ylabel="Value")
tvst = axes(xlabel="Time (s)", ylabel="Time (s)")
vvst = axes(xlabel="Time (s)", ylabel="Amplitude (V)")
color1 = line(color=2)
color2 = line(color=3)
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
bseq = 1.0*prbs(BT, reglen=5, seed=1, nsamples=nsamples)
#bseq = [1,0,1,1,1,0,0,0]; bseq = Data2D(collect(1:length(bseq)),bseq)
nsamples = length(bseq)
t = Data2D(0:(tbit/nbit):(nsamples*tbit))
p = pulse(DT, t, Pole(3/tbit,:rad), npw=Index(nbit))
seq = pattern(DT, bseq, p, npw=Index(nbit))


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Test SignalProcessing")
s = add(plot, tvsbit, title="PRBS sequence")
	add(s, bseq, color1)
s = add(plot, vvst, title="Sequence")
	add(s, p, color1, id="Pulse")
	add(s, seq, color2, id="Pattern")


#==Show results
===============================================================================#
if true; eval(quote
	import EasyPlotGrace
	const plotdefaults = GracePlot.defaults(linewidth=2.5)
	gplot = GracePlot.new()
		GracePlot.set(gplot, plotdefaults)
	render(gplot, plot, ncols=2); display(gplot)
	#render(gplot, plot, ncols=1); display(gplot)
end); end
if false; eval(quote
	import EasyPlotMPL
	display(Backend{:MPL}, plot, ncols=2);
end); end


:Test_Complete

