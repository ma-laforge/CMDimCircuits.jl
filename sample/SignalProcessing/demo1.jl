#Demo 1: Pulse generation
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
p1 = push!(cons(:plot, vvst, title="Step Response"),
	cons(:wfrm, DataF1(uideal), color1, label="DT"),
	cons(:wfrm, u, color2, label="CT"),
)
p2 = push!(cons(:plot, vvst, title="Pulse Response"),
	cons(:wfrm, DataF1(Πideal), color1, label="DT"),
	cons(:wfrm, Π, color2, label="CT"),
)
p3 = push!(cons(:plot, vvst, title="Sine wave"),
	cons(:wfrm, sin(tCT*(pi*10/tmax)), color2),
)

pcoll = push!(cons(:plotcoll, title="Generating Simple Responses"), p1, p2, p3)
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
display(pdisp, pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll #Will display pcoll a second time if executed from REPL
