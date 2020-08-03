#Demo 8: Sampling
#-------------------------------------------------------------------------------

using CMDimCircuits
CMDimCircuits.@using_CData()

#Get a demo display:
include(CMDimCircuits.demoplotcfgscript); pdisp = getdemodisplay()
#Normally use something like:
#CMDimData.@includepkg EasyPlotInspect; pdisp = EasyPlotInspect.PlotDisplay()


#==Constants
===============================================================================#
vvst = cons(:a, labels = set(yaxis="Amplitude (V)", xaxis="Time (s)"))
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
p1 = push!(cons(:plot, vvst, title="Pattern"),
	cons(:wfrm, pat, label="pat"),
	cons(:wfrm, _spat_, noline, glyph=set(shape=:o, color=:red), label="over range"),
	cons(:wfrm, spat, noline, glyph=set(shape=:+, color=:black), label="full sample"),
	cons(:wfrm, _spat, noline, glyph=set(shape=:x, color=:blue), label="straddle low"),
	cons(:wfrm, spat_, noline, glyph=set(shape=:x, color=:green), label="straddle high"),
)
p2 = push!(cons(:plot, vvst, title="Oversampling"),
	cons(:wfrm, overspat, noline, glyph=set(shape=:x, color=:blue)),
)

pcoll = push!(cons(:plotcoll, title="Sampling tests"), p1, p2)
	pcoll.ncolumns = 1


#==Display results in pcoll
===============================================================================#
display(pdisp, pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll #Will display pcoll a second time if executed from REPL
