#Demo 7: Eye diagrams
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = paxes(ylabel="Amplitude (V)", xlabel="Time (s)")


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
	PSweep("EXTRALVL", [1]) #Add extra level to test more code
	PSweep("tau", tbit.*[1/5, 1/2.5, 1/1.5])
]

#Generate data:
Π = fill(DataHR, sweeplist) do EL, tau
	return pulse(tΠ, Pole(1/tau,:rad), tpw=tbit)
end
pat = (pattern(seq, Π, tbit=tbit)-0.5)*2 #Center data pattern
patRS = DataRS(pat)


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Eye Diagram Tests", displaylegend=false)
s = add(plot, vvst, title="Eye (DataHR)", eyeparam(tbit, teye=1.5*tbit, tstart=-.15*tbit))
set(s, paxes(xmin=0, xmax=1.5*tbit)) #Force limits on exact data range.
	add(s, pat, id="eye")
s = add(plot, vvst, title="Pattern")
	add(s, pat, id="pat")
s = add(plot, vvst, title="Eye (DataRS)", eyeparam(tbit, teye=1.5*tbit, tstart=-.15*tbit))
set(s, paxes(xmin=0, xmax=1.5*tbit)) #Force limits on exact data range.
	add(s, patRS, id="eye")


#==Return plot to user (call evalfile(...))
===============================================================================#
plot.ncolumns = 2
plot
