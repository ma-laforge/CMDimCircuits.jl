#Demo 14: Ck2Q vs Delay tests
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = axes(ylabel="Amplitude (V)", xlabel="Time (s)")
dpsvst = axes(ylabel="Delay (ps)", xlabel="Time (s)")
dpsvsx = axes(ylabel="Delay (ps)", xlabel="Crossing")
ldelay = line(width=3)
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

Δ = measdelay(patref, pat, xing1=CrossType(:risefall), xing2=CrossType(:risefall))
ck2q = measck2q(ck, pat, xing_ck=CrossType(:rise), xing_q=CrossType(:risefall))


#==Generate plot
===============================================================================#
axrange = axes(xmax=maximum(t)+3*tbit)
plot=EasyPlot.new(title="Compare measdelay & measck2q", displaylegend=false)
s = add(plot, vvst, title="Clock signal", axrange)
	add(s, ck, id="clock")
s = add(plot, vvst, title="Patterns", axrange)
	add(s, patref, id="ref")
	add(s, pat, id="pat")
s = add(plot, dpsvst, title="Delays", axrange)
	add(s, Δ/1e-12, id="measdelay", ldelay, gdelay)
	add(s, ck2q/1e-12, id="measck2q", ldelay, gdelay)
s = add(plot, dpsvst, title="Difference", axrange)
	add(s, (Δ-ck2q)/1e-12, id="measdelay-measck2q", ldelay, gdelay)


#==Return plot to user (call evalfile(...))
===============================================================================#
ncols = 1
(plot, ncols)
