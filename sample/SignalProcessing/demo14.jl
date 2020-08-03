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
vvst = cons(:a, labels = set(yaxis="Amplitude (V)", xaxis="Time (s)"))
dpsvst = cons(:a, labels = set(yaxis="Delay (ps)", xaxis="Time (s)"))
delayattr = cons(:a,
	line = set(width=3, style=:solid),
	glyph = set(shape=:x, size=2),
)


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
#Relative to ideal reference clock:
ck2q_ideal = measck2q(pat, tbit, tstart_ck=tstart_ck, xing_q=CrossType(:risefall))


#==Generate plot
===============================================================================#
axrange = cons(:a, xyaxes=set(xmax=maximum(t)+3*tbit))
p1 = push!(cons(:plot, vvst, axrange, title="Patterns"),
	cons(:wfrm, ck, line=set(width=1, color=RGB24(.5, .5, .5)), label="clock"),
	cons(:wfrm, patref, line=set(width=2), label="ref"),
	cons(:wfrm, pat, label="pat"),
)
p2 = push!(cons(:plot, dpsvst, axrange, title="Delays (measdelay, measck2q)"),
	cons(:wfrm, Δ/1e-12, delayattr, label="delay"),
	cons(:wfrm, ck2q/1e-12, delayattr, label="ck2q"),
	cons(:wfrm, ck2q_ideal/1e-12, delayattr, label="ck2qI (ideal)"),
)
p3 = push!(cons(:plot, dpsvst, axrange, title="Delay Differences (wrt ck2q & ideal ck2q)"),
	cons(:wfrm, (Δ-ck2q)/1e-12, delayattr, label="del-ck2q"),
	cons(:wfrm, (Δ-ck2q_ideal)/1e-12, delayattr, label="del-ck2qI"),
)

pcoll = push!(cons(:plotcoll, title="Compare measdelay & measck2q"), p1, p2, p3)
	pcoll.ncolumns = 1


#==Display results in pcoll
===============================================================================#
display(pdisp, pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll #Will display pcoll a second time if executed from REPL
