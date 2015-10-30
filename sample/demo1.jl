#Test code
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot

#No real test code yet... just run demos:

#==Constants
===============================================================================#
const tvst = axes(xlabel="Time (s)", ylabel="Time (s)")
const vvst = axes(xlabel="Time (s)", ylabel="Amplitude (V)")
const color1 = line(color=2)
const color2 = line(color=3)

tstart = 0
tstep = .01
tstop = 10

#==Input data
===============================================================================#
DT = Domain{:DT}
CT = Domain{:CT}
t = Data2D(tstart:tstep:tstop)
tmax = maximum(t.x)
@show len = length(t)
u = step(DT, t, ndel=Index(len/4))
p = pulse(DT, t, ndel=Index(len/7), npw=Index(len/16))
pulsewidth = tmax/16
u1p = step(CT, t, Pole(3/pulsewidth,:rad), tdel=tmax/4)
p1p = pulse(CT, t, Pole(3/pulsewidth,:rad), tdel=tmax/7, tpw=pulsewidth)
_sin = sin(t*(pi*10/tmax))

#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Test SignalProcessing")
s = add(plot, tvst, title="Time Vector")
	add(s, t, color1)
s = add(plot, vvst, title="step response")
	add(s, u, color1, id="DT")
	add(s, u1p, color2, id="CT")
s = add(plot, vvst, title="pulse response")
	add(s, p, color1, id="DT")
	add(s, p1p, color2, id="CT")
s = add(plot, vvst, title="pulse response")
	add(s, _sin, color2)

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
if true; eval(quote
	import EasyPlotGrace
	const plotdefaults = GracePlot.defaults(linewidth=2.5)
	gplot = GracePlot.new()
		GracePlot.set(gplot, plotdefaults)
	render(gplot, plot, ncols=2); display(gplot)
	#render(gplot, plot, ncols=1); display(gplot)
end); end
if false; eval(quote
	import EasyPlotMPL
	display(Backend{:MPL}, plot, ncols=2);
end); end

@show t
@show u

:Test_Complete

