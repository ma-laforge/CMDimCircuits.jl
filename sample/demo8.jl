#Demo 8: Sampling
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = axes(xlabel="Time (s)", ylabel="Amplitude (V)")
noline = line(style=:none)
BT = Domain{:bit}
DT = Domain{:DT}
CT = Domain{:CT}


#==Input data
===============================================================================#
tbit = 1e-9 #Bit period
osr = 20 #samples per bit
nsamples = 10
tau = tbit/5


#==Computations
===============================================================================#
seq = 1.0*prbs(BT, reglen=5, seed=1, nsamples=nsamples)
t = DataF1(0:(tbit/osr):(nsamples*tbit))
Π = pulse(DT, t, Pole(1/tau,:rad), npw=Index(osr))
pat = pattern(DT, seq, Π, npw=Index(osr))
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
