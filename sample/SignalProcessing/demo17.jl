#Demo 17: Rise/fall tests
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
LBLAX_RFTIMEPS = "Rise/Fall (ps)"
LBLAX_TIME = "Time (s)"
delayattr = cons(:a,
	line = set(style=:solid, width=3),
	glyph = set(shape=:x, size=2),
)


#==Input data
===============================================================================#
tbit = 1e-9 #Bit period
osr = 20 #samples per bit
nsamples = 127
amp = 2


#==Computations
===============================================================================#
seq = 1.0*prbs(reglen=7, seed=1, nsamples=nsamples)
t = DataF1(0:(tbit/osr):(nsamples*tbit))
tmax = maximum(t)

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("tau", tbit.*[1/2.5])
]

#Generate data:
Π = fill(DataHR, sweeplist) do tau
	return pulse(t, Pole(1/tau,:rad), tpw=tbit)
end

pat = (pattern(seq, Π, tbit=tbit)-0.5)*amp #Center data pattern

lthresh = -1+amp*.2 #20%
hthresh = -1+amp*.8 #80%
@show lthresh, hthresh
trise = measrise(pat, lthresh=lthresh, hthresh=hthresh)
tfall = measfall(pat, lthresh=lthresh, hthresh=hthresh)


#==Generate plot
===============================================================================#
plot = cons(:plot, nstrips=2, legend=false,
	ystrip1 = set(axislabel=LBLAX_AMPV, striplabel="Patterns"),
	ystrip2 = set(axislabel=LBLAX_RFTIMEPS, striplabel="20-80 Rise/Fall Times"),
	xaxis = set(label=LBLAX_TIME, max=tmax),
)
push!(plot,
	cons(:wfrm, pat, label="pat", strip=1),

	cons(:wfrm, trise/1e-12, delayattr, line=set(color=:blue), label="rise", strip=2),
	cons(:wfrm, tfall/1e-12, delayattr, line=set(color=:red), label="fall", strip=2),
)

pcoll = push!(cons(:plotcoll, title="Rise/Fall Tests"), plot)
	pcoll.ncolumns = 1


#==Display results in pcoll
===============================================================================#
EasyPlot.displaygui(pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
