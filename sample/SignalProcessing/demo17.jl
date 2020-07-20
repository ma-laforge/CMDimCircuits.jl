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
vvst = paxes(ylabel="Amplitude (V)", xlabel="Time (s)")
rfpsvst = paxes(ylabel="Rise/Fall (ps)", xlabel="Time (s)")
ldelay = line(style=:solid, width=3)
gdelay = glyph(shape=:x, size=2)


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
axrng = paxes(xmax=tmax)
plot=EasyPlot.new(title="Rise/Fall Tests", displaylegend=false)
s = add(plot, axrng, vvst, title="Patterns")
	add(s, pat, id="pat")
s = add(plot, axrng, rfpsvst, title="20-80 Rise/Fall Times")
	add(s, trise/1e-12, id="", ldelay, gdelay, line(color=:blue))
	add(s, tfall/1e-12, id="", ldelay, gdelay, line(color=:red))
plot.ncolumns = 1


#==Display results as a plot
===============================================================================#
display(pdisp, plot)


#==Return plot to user (call evalfile(...))
===============================================================================#
plot
