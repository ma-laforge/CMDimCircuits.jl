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
Π = pulse(t, Pole(3/tbit,:rad), npw=Index(osr))
pat = pattern(seq, Π, nbit=Index(osr))


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Generating Patterns")
s = add(plot, tvsbit, title="PRBS Sequence")
	add(s, DataF1(collect(1:length(seq)), seq), color2)
s = add(plot, vvst, title="PRBS Pattern")
	add(s, DataF1(Π), color1, id="Pulse")
	add(s, DataF1(pat), color2, id="Pattern")


#==Return plot to user (call evalfile(...))
===============================================================================#
plot.ncolumns = 1
plot
