#Demo 17: Rise/fall tests
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
rfpsvst = cons(:a, labels = set(yaxis="Rise/Fall (ps)", xaxis="Time (s)"))
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
trise = measrise(pat, lthresh=lthresh, hthresh=hthresh)
tfall = measfall(pat, lthresh=lthresh, hthresh=hthresh)


#==Generate plot
===============================================================================#
axrng = cons(:a, xyaxes=set(xmax=tmax))
p1 = push!(cons(:plot, axrng, vvst, title="Patterns"),
	cons(:wfrm, pat, label="pat"),
)
p2 = push!(cons(:plot, axrng, rfpsvst, title="20-80 Rise/Fall Times"),
	cons(:wfrm, trise/1e-12, delayattr, line=set(color=:blue)),
	cons(:wfrm, tfall/1e-12, delayattr, line=set(color=:red)),
)

pcoll = push!(cons(:plotcoll, title="Rise/Fall Tests"), p1, p2)
	pcoll.displaylegend = false
	pcoll.ncolumns = 1


#==Display results in pcoll
===============================================================================#
display(pdisp, pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll #Will display pcoll a second time if executed from REPL
