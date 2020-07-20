#Demo 4: Multi-dimensional datasets
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot
import Statistics


#==Constants
===============================================================================#
vvst = paxes(ylabel="Amplitude (V)", xlabel="Time (s)")


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
#-------------------------------------------------------------------------------
#NOTE: verbose... trying to test DataHR & "parameter" operations.

#Generate single pulse for all parametric corners:
Π = fill(DataHR, sweeplist) do amp, tau, offset
	return pulse(tΠ, Pole(1/tau,:rad), tpw=tbit)
end
amp = parameter(Π, "amp")
offset = parameter(Π, "offset")
pat = (pattern(seq, Π, tbit=tbit)-0.5)*amp + offset #Center data pattern
t = xval(pat)

#Do some DataHR-level transformations:
result = pat
tmax = tbit*(nsamples+nbit_Π-1)
skew = DataF1([0, tmax],[0, 0.5])
result = result + result + 4 + skew
result += Statistics.mean(result)


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Mulit-Dataset Tests", displaylegend=false)
s = add(plot, vvst, title="PRBS Pattern")
	add(s, result, id="pat")


#==Return plot to user (call evalfile(...))
===============================================================================#
plot.ncolumns = 1
plot
