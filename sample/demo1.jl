#Demo 1: Pulse generation
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = paxes(ylabel="Amplitude (V)", xlabel="Time (s)")
color1 = line(color=:red)
color2 = line(color=:blue)

#==Input data
===============================================================================#
tstart = 0
tstep = .01
tstop = 10

#==Computations
===============================================================================#
t = tstart:tstep:tstop
@show len = length(t)
tmax = maximum(t)

#Discrete-time data, ideal response:
tDT = DataTime(t) #Discrete-time time dataset
uideal = step(tDT, ndel=Index(len/4))
Πideal = pulse(tDT, ndel=Index(len/7), npw=Index(len/16))

#Continuous-time data, single-pole response:
tCT = DataF1(t) #Continuous-time time dataset
pulsewidth = tmax/16
u = step(tCT, Pole(3/pulsewidth,:rad), tdel=tmax/4)
Π = pulse(tCT, Pole(3/pulsewidth,:rad), tdel=tmax/7, tpw=pulsewidth)

#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Generating Simple Responses")
s = add(plot, vvst, title="Step Response")
	add(s, DataF1(uideal), color1, id="DT")
	add(s, u, color2, id="CT")
s = add(plot, vvst, title="Pulse Response")
	add(s, DataF1(Πideal), color1, id="DT")
	add(s, Π, color2, id="CT")
s = add(plot, vvst, title="Sine wave")
	add(s, sin(tCT*(pi*10/tmax)), color2)

#==Show results
===============================================================================#
PoleRad = SignalProcessing.PoleRad
f(x::Pole) = "Generic pole"
f(x::PoleRad{T}) where {T<:Number} = "Pole: $(value(x)) rad!"
phz=Pole(1,:Hz)
prad=Pole(1,:rad)
@show phz, prad
@show value(phz), value(prad)
@show value(:rad,phz), value(:Hz,prad)
@show f(phz), f(prad)


#==Return plot to user (call evalfile(...))
===============================================================================#
plot.ncolumns = 1
plot
