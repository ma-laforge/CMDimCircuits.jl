#Demo 11: Measure frequency/period
#-------------------------------------------------------------------------------

using CMDimCircuits
CMDimCircuits.@using_CData()

#Get a demo display:
include(CMDimCircuits.demoplotcfgscript); pdisp = getdemodisplay()
#Normally use something like:
#CMDimData.@includepkg EasyPlotInspect; pdisp = EasyPlotInspect.PlotDisplay()


#==Constants
===============================================================================#
LBLAX_AMPV = "Amplitude (V)"
LBLAX_PERNS = "Period (ns)"
LBLAX_FREQ = "Frequency (Hz)"
LBLAX_TIME = "Time (s)"
line1 = cons(:a, line = set(style=:solid))
lshiftattr = cons(:a,
	line = set(style=:solid, color=2), glyph = set(shape=:+),
)
lnoshiftattr = cons(:a,
	line = set(style=:solid, color=3), glyph = set(shape=:x),
)


#==Input data
===============================================================================#
fnom = 1e9
osr = 50 #(fundamental) oversampling ratio
ncycles = 20
fshift=0.1 #ratio
fmod = fnom/ncycles #Frequency of modulation
xrise = CrossType(:rise)


#==Computations
===============================================================================#
T = 1/fnom
t = DataF1(0:(T/osr):(ncycles*T))
finst = fnom*(1+fshift*cos(2pi*fmod*t)) #instantaneous frequency
y = cos(2pi*finst*t)

period_shift = measperiod(y, xing=xrise, shiftx=true)/1e-9
period_noshift = measperiod(y, xing=xrise, shiftx=false)/1e-9
freq_shift = measfreq(y, xing=xrise, shiftx=true)
freq_noshift = measfreq(y, xing=xrise, shiftx=false)


#==Generate plot
===============================================================================#
plot = cons(:plot, nstrips=3,
	ystrip1 = set(axislabel=LBLAX_AMPV, striplabel="Signal"),
	ystrip2 = set(axislabel=LBLAX_PERNS, striplabel="Instantaneous Period"),
	ystrip3 = set(axislabel=LBLAX_FREQ, striplabel="Instantaneous Frequency"),
	xaxis = set(label=LBLAX_TIME),
)
push!(plot,
	cons(:wfrm, y, label="y(t)", strip=1),
	cons(:wfrm, period_shift, lshiftattr, label="shift", strip=2),
	cons(:wfrm, period_noshift, lnoshiftattr, label="no shift", strip=2),
	cons(:wfrm, freq_shift, lshiftattr, label="shift", strip=3),
	cons(:wfrm, freq_noshift, lnoshiftattr, label="no shift", strip=3),
)

pcoll = push!(cons(:plotcoll, title="Period & Frequency Measurements"), plot)
	pcoll.ncolumns = 1


#==Display results in pcoll
===============================================================================#
display(pdisp, pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll #Will display pcoll a second time if executed from REPL
