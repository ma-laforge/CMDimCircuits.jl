#Demo 14: Ck2Q vs Delay tests
#-------------------------------------------------------------------------------

using Colors
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
LBLAX_DELPS = "Delay (ps)"
LBLAX_ΔDELPS = "𝛥Delay (ps)"
delayattr = cons(:a,
	line = set(style=:solid, width=3, color=1),
	glyph = set(shape=:x, size=2),
)
color_ck2q = cons(:a, line = set(color=2))
color_ck2qI = cons(:a, line = set(color=3))


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
LBLAX_AMPV = "Amplitude (V)"
LBLAX_TIME = "Time (s)"
LBLAX_DELPS = "Delay (ps)"

plot = cons(:plot, nstrips=3,
	ystrip1 = set(axislabel=LBLAX_AMPV, striplabel="Patterns"),
	ystrip2 = set(axislabel=LBLAX_DELPS, striplabel="Delays (measdelay, measck2q)"),
	ystrip3 = set(axislabel=LBLAX_ΔDELPS, striplabel="Delay Differences (wrt ck2q & ideal ck2q)"),
	xaxis = set(label=LBLAX_TIME, max=maximum(t)+3*tbit),
)
push!(plot,
	cons(:wfrm, ck, line=set(width=1, color=RGB24(.5, .5, .5)), label="clock", strip=1),
	cons(:wfrm, patref, line=set(width=2), label="ref", strip=1),
	cons(:wfrm, pat, label="pat", strip=1),

	cons(:wfrm, Δ/1e-12, delayattr, label="delay", strip=2),
	cons(:wfrm, ck2q/1e-12, delayattr, color_ck2q, label="ck2q", strip=2),
	cons(:wfrm, ck2q_ideal/1e-12, delayattr, color_ck2qI, label="ck2qI (ideal)", strip=2),

	cons(:wfrm, (Δ-ck2q)/1e-12, delayattr, color_ck2q, label="del-ck2q", strip=3),
	cons(:wfrm, (Δ-ck2q_ideal)/1e-12, delayattr, color_ck2qI, label="del-ck2qI", strip=3),
)

pcoll = push!(cons(:plotcoll, title="Compare measdelay & measck2q"), plot)
	pcoll.ncolumns = 1


#==Display results in pcoll
===============================================================================#
EasyPlot.displaygui(pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
