#Demo 11: Measure frequency/period
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = paxes(ylabel="Amplitude (V)", xlabel="Time (s)")
Tpsvst = paxes(ylabel="Period (ps)", xlabel="Time (s)")
fvst = paxes(ylabel="Frequency (Hz)", xlabel="Time (s)")
solidline = line(style=:solid)


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


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Period & Frequency Measurements")
s = add(plot, vvst, title="Signal")
	add(s, y, id="y(t)")
s = add(plot, Tpsvst, title="Instantaneous Period")
	add(s, measperiod(y, xing=xrise, shiftx=true), solidline, glyph(shape=:+), id="shift")
	add(s, measperiod(y, xing=xrise, shiftx=false), solidline, glyph(shape=:x), id="no shift")
s = add(plot, fvst, title="Instantaneous Frequency")
	add(s, measfreq(y, xing=xrise, shiftx=true), solidline, glyph(shape=:+), id="shift")
	add(s, measfreq(y, xing=xrise, shiftx=false), solidline, glyph(shape=:x), id="no shift")


#==Return plot to user (call evalfile(...))
===============================================================================#
plot.ncolumns = 1
plot
