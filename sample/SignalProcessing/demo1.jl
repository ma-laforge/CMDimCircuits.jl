#Demo 1: Pulse generation
#-------------------------------------------------------------------------------

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
color1 = cons(:a, line = set(color=:red))
color2 = cons(:a, line = set(color=:blue))


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
plot = cons(:plot, nstrips=3,
	ystrip1 = set(axislabel=LBLAX_AMPV, striplabel="Step Response"),
	ystrip2 = set(axislabel=LBLAX_AMPV, striplabel="Pulse Response"),
	ystrip3 = set(axislabel=LBLAX_AMPV, striplabel="Sine wave"),
	xaxis = set(label=LBLAX_TIME),
)
push!(plot,
	cons(:wfrm, DataF1(uideal), color1, label="DT", strip=1),
	cons(:wfrm, u, color2, label="CT", strip=1),
	cons(:wfrm, DataF1(Πideal), color1, label="DT", strip=2),
	cons(:wfrm, Π, color2, label="CT", strip=2),
	cons(:wfrm, sin(tCT*(pi*10/tmax)), color2, strip=3),
)

pcoll = push!(cons(:plotcoll, title="Generating Simple Responses"), plot)
	pcoll.ncolumns = 1


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


#==Display results in pcoll
===============================================================================#
EasyPlot.displaygui(pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
