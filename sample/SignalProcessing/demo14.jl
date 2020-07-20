#Demo 14: Ck2Q vs Delay tests
#-------------------------------------------------------------------------------

using Colors
using CMDimCircuits
CMDimCircuits.@using_CData()

#Get a demo display:
include(CMDimCircuits.demoplotcfgscript); pdisp = getdemodisplay()
#Normally use something like:
#CMDimData.@includepkg EasyPlotInspect; pdisp = EasyPlotInspect.PlotDisplay()


#==Constants
===============================================================================#
vvst = paxes(ylabel="Amplitude (V)", xlabel="Time (s)")
dpsvst = paxes(ylabel="Delay (ps)", xlabel="Time (s)")
dpsvsx = paxes(ylabel="Delay (ps)", xlabel="Crossing")
ldelay = line(width=3, style=:solid)
gdelay = glyph(shape=:x, size=2)


#==Input data
===============================================================================#
tbit = 1e-9 #Bit period
osr = 20 #samples per bit
nsamples = 127


#==Computations
===============================================================================#
seq = 1.0*prbs(reglen=7, seed=1, nsamples=nsamples)
t = DataF1(0:(tbit/osr):(nsamples*tbit))
τref = tbit/5
τ = tbit/1.5
ck = sin(2pi*t/tbit)

#Generate data:
Πref = pulse(t, Pole(1/τref,:rad), tpw=tbit)
Π = pulse(t, Pole(1/τ,:rad), tpw=tbit)

patref = (pattern(seq, Πref, tbit=tbit)-0.5)*2 #Center data pattern
pat = (pattern(seq, Π, tbit=tbit)-0.5)*2 #Center data pattern

Δ = measdelay(patref, pat, xing_ref=CrossType(:risefall), xing_main=CrossType(:risefall))
ck2q = measck2q(ck, pat, xing_ck=CrossType(:rise), xing_q=CrossType(:risefall))
@show tstart_ck = xcross1(patref)-50e-12
ck2q_ideal = measck2q(pat, tbit, tstart_ck=tstart_ck, xing_q=CrossType(:risefall))


#==Generate plot
===============================================================================#
axrange = paxes(xmax=maximum(t)+3*tbit)
plot=EasyPlot.new(title="Compare measdelay & measck2q", displaylegend=true)
s = add(plot, vvst, title="Patterns", axrange)
	wfrm = add(s, ck, id="clock")
		set(wfrm, line(width=1, color=RGB24(.5, .5, .5)))
	add(s, patref, id="ref", line(width=2))
	add(s, pat, id="pat")
s = add(plot, dpsvst, title="Delays", axrange)
	add(s, Δ/1e-12, id="del=measdelay(ref,pat)", ldelay, gdelay)
	add(s, ck2q/1e-12, id="ck2q=measck2q(ck,pat)", ldelay, gdelay)
	add(s, ck2q_ideal/1e-12, id="ck2qI=measck2q(ideal,pat)", ldelay, gdelay)
s = add(plot, dpsvst, title="Delay Differences", axrange)
	add(s, (Δ-ck2q)/1e-12, id="del-ck2q", ldelay, gdelay)
	add(s, (Δ-ck2q_ideal)/1e-12, id="del-ck2qI", ldelay, gdelay)
plot.ncolumns = 1


#==Display results as a plot
===============================================================================#
display(pdisp, plot)


#==Return plot to user (call evalfile(...))
===============================================================================#
plot
