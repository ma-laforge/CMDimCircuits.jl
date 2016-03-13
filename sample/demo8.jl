#Demo 8: Sampling
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = axes(ylabel="Amplitude (V)", xlabel="Time (s)")
noline = line(style=:none)


#==Input data
===============================================================================#
tbit = 1e-9 #Bit period
osr = 20 #samples per bit
nsamples = 10
tau = tbit/5


#==Computations
===============================================================================#
seq = 1.0*prbs(reglen=5, seed=1, nsamples=nsamples)
t = DataF1(0:(tbit/osr):(nsamples*tbit))
Π = pulse(t, Pole(1/tau,:rad), tpw=tbit)
pat = pattern(seq, Π, tbit=tbit)
spat = sample(pat, 0:(tbit/2):maximum(t))
_spat_ = sample(pat, -tbit:(tbit/2):(tbit+maximum(t)))
_spat = sample(pat, -2*tbit:(tbit/2):(maximum(t)/2))
spat_ = sample(pat, (maximum(t)/2):(tbit/2):(maximum(t)+2*tbit))
overspat = sample(pat, 0:(tbit/osr/4):maximum(t))


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Sampling tests")
s = add(plot, vvst, title="Pattern")
	add(s, pat, id="pat")
	add(s, _spat_, id="over range", noline, glyph(shape=:o, color=:red))
	add(s, spat, id="full sample", noline, glyph(shape=:+, color=:black))
	add(s, _spat, id="straddle low", noline, glyph(shape=:x, color=:blue))
	add(s, spat_, id="straddle high", noline, glyph(shape=:x, color=:green))
s = add(plot, vvst, title="Oversampling")
	add(s, overspat, noline, glyph(shape=:x, color=:blue))


#==Return plot to user (call evalfile(...))
===============================================================================#
plot.ncolumns = 1
plot
