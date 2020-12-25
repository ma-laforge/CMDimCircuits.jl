#Demo 10: Delay tests
#-------------------------------------------------------------------------------

using CMDimCircuits
CMDimCircuits.@using_CData()

#Get a demo display:
include(CMDimCircuits.demoplotcfgscript)
#Normally use something like:
#CMDimData.@includepkg EasyPlotInspect


#==Constants
===============================================================================#
vvst = cons(:a, labels = set(yaxis="Amplitude (V)", xaxis="Time (s)"))
dpsvst = cons(:a, labels = set(yaxis="Delay (ps)", xaxis="Time (s)"))
dpsvsx = cons(:a, labels = set(yaxis="Delay (ps)", xaxis="Crossing"))
ldelay = cons(:a, line = set(width=3, style=:solid))
gdelay = cons(:a, glyph = set(shape=:x, size=2))


#==Input data
===============================================================================#
tbit = 1e-9 #Bit period
osr = 20 #samples per bit
nsamples = 127


#==Computations
===============================================================================#
seq = 1.0*prbs(reglen=7, seed=1, nsamples=nsamples)
t = DataF1(0:(tbit/osr):(nsamples*tbit))
tmax = maximum(t)

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("L", [1]) #Add extra level to test more code
	PSweep("tau", tbit.*[1/5, 1/2.5, 1/1.5])
]

#Generate data:
Π = fill(DataHR, sweeplist) do EL, tau
	return pulse(t, Pole(1/tau,:rad), tpw=tbit)
end

pat = (pattern(seq, Π, tbit=tbit)-0.5)*2 #Center data pattern
refpat = pat.elem[1]
Δ = measdelay(refpat, pat, xing_ref=CrossType(:risefall), xing_main=CrossType(:risefall))
Δxn = measdelay(Event, refpat, pat, xing_ref=CrossType(:risefall), xing_main=CrossType(:risefall))
Δ = DataRS(Δ) #Test support for DataRS objects


#==Generate plot
===============================================================================#
p1 = push!(cons(:plot, vvst, title="Patterns"),
	cons(:wfrm, refpat, line=set(width=5, color=:black), label="Ref"),
	cons(:wfrm, pat, label="pat"),
)
p2 = push!(cons(:plot, dpsvst, title="Delays"),
	cons(:wfrm, Δ/1e-12, ldelay, gdelay, label="D"),
)
p3 = push!(cons(:plot, dpsvsx, title="Delays vs Crossing Number"),
	cons(:wfrm, Δxn/1e-12, ldelay, gdelay, label="D"),
)

pcoll = push!(cons(:plotcoll, title="Signal Delay Tests"), p1, p2, p3)
	pcoll.ncolumns = 1


#==Display results in pcoll
===============================================================================#
EasyPlot.displaygui(pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
