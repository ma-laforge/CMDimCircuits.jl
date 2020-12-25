#Demo 8: Sampling
#-------------------------------------------------------------------------------

using CMDimCircuits
CMDimCircuits.@using_CData()

#Get a demo display:
include(CMDimCircuits.demoplotcfgscript)
#Normally use something like:
#CMDimData.@includepkg EasyPlotInspect


#==Constants
===============================================================================#
LBLAX_AMPV = "Amplitude (V)"
LBLAX_TIME = "Time (s)"
noline = cons(:a, line = set(style=:none))


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
plot = cons(:plot, nstrips=2,
	ystrip1 = set(axislabel=LBLAX_AMPV, striplabel="Pattern"),
	ystrip2 = set(axislabel=LBLAX_AMPV, striplabel="Oversampling"),
	xaxis = set(label=LBLAX_TIME),
)
push!(plot,
	cons(:wfrm, pat, label="pat", strip=1),
	cons(:wfrm, _spat_, noline, glyph=set(shape=:o, color=:red), label="over range", strip=1),
	cons(:wfrm, spat, noline, glyph=set(shape=:+, color=:black), label="full sample", strip=1),
	cons(:wfrm, _spat, noline, glyph=set(shape=:x, color=:blue), label="straddle low", strip=1),
	cons(:wfrm, spat_, noline, glyph=set(shape=:x, color=:green), label="straddle high", strip=1),

	cons(:wfrm, overspat, noline, glyph=set(shape=:x, color=:blue), strip=2),
)

pcoll = push!(cons(:plotcoll, title="Sampling tests"), plot)
	pcoll.ncolumns = 1


#==Display results in pcoll
===============================================================================#
EasyPlot.displaygui(pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
