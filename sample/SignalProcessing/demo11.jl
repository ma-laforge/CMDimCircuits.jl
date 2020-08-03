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
vvst = cons(:a, labels = set(yaxis="Amplitude (V)", xaxis="Time (s)"))
Tpsvst = cons(:a, labels = set(yaxis="Period (ns)", xaxis="Time (s)"))
fvst = cons(:a, labels = set(yaxis="Frequency (Hz)", xaxis="Time (s)"))
solidline = cons(:a, line = set(style=:solid))


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
p1 = push!(cons(:plot, vvst, title="Signal"),
	cons(:wfrm, y, label="y(t)"),
)
p2 = push!(cons(:plot, Tpsvst, title="Instantaneous Period"),
	cons(:wfrm, period_shift, solidline, glyph=set(shape=:+), label="shift"),
	cons(:wfrm, period_noshift, solidline, glyph=set(shape=:x), label="no shift"),
)
p3 = push!(cons(:plot, fvst, title="Instantaneous Frequency"),
	cons(:wfrm, freq_shift, solidline, glyph=set(shape=:+), label="shift"),
	cons(:wfrm, freq_noshift, solidline, glyph=set(shape=:x), label="no shift"),
)

pcoll = push!(cons(:plotcoll, title="Period & Frequency Measurements"), p1, p2, p3)
	pcoll.ncolumns = 1


#==Display results in pcoll
===============================================================================#
display(pdisp, pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll #Will display pcoll a second time if executed from REPL
