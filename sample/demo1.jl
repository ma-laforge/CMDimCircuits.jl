#Test code
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot
import EasyPlotGrace

#No real test code yet... just run demos:

#==Constants
===============================================================================#
const tvst = axes(xlabel="Time (s)", ylabel="Time (s)")
const vvst = axes(xlabel="Time (s)", ylabel="Amplitude (V)")
const plotdefaults = GracePlot.defaults(linewidth=2.5)
const color1 = line(color=2)
const color2 = line(color=3)

tstart = .1
tstep = .01
tstop = 10

#==Input data
===============================================================================#
CT = Domain{:CT}
t = Data2D(tstart:tstep:tstop)
tmax = maximum(t.x)
@show len = length(t)
u = step(CT, t, DataIndex(len/4))
p = pulse(CT, t, DataIndex(len/7), DataIndex(len/16))
pulsewidth = tmax/16
u1p = step(CT, t, tmax/4, 1, Pole(3/pulsewidth,:rad))
p1p = pulse(CT, t, tmax/7, 1, Pole(3/pulsewidth,:rad), pulsewidth)

#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Test SignalProcessing")
s = add(plot, tvst, title="Time Vector")
	add(s, t, color1, id="time vector")
s = add(plot, vvst, title="step response")
	add(s, u, color1, id="step response")
	add(s, u1p, color2, id="step response")
s = add(plot, vvst, title="pulse response")
	add(s, p, color1, id="pulse response")
	add(s, p1p, color2, id="pulse response")


#==Show results
===============================================================================#
PoleRad = SignalProcessing.PoleRad
f(x::Pole) = "Generic pole"
f{T<:Number}(x::PoleRad{T}) = "Pole: $(value(x)) rad!"
phz=Pole(1,:Hz)
prad=Pole(1,:rad)
@show phz, prad
@show value(phz), value(prad)
@show value(:rad,phz), value(:Hz,prad)
@show f(phz), f(prad)

#==Show results
===============================================================================#
if true
gplot = GracePlot.new()
	GracePlot.set(gplot, plotdefaults)
render(gplot, plot, ncols=2); display(gplot)
#render(gplot, plot, ncols=1); display(gplot)
end

@show t
@show u

:Test_Complete

