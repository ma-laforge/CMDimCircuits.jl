#Demo 9: Integration/differentiation
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = axes(ylabel="Amplitude (V)", xlabel="Time (s)")
vvsf = axes(ylabel="Amplitude (V)", xlabel="Frequency (Hz)")


#==Input data
===============================================================================#
osr = 50 #(fundamental) oversampling ratio
ncycles = 5


#==Computations
===============================================================================#
t = DataF1(0:(2pi/osr):(ncycles*(2pi)))
y = cos(t)
dydt = deriv(y)
∫ydt = iinteg(y)
x2x=xcross1(y - ∫ydt, n=2)
x2y=ycross1(y, ∫ydt, n=2)
println("crossing#2: ($x2x, $x2y)")

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("phi", pi*[0, .25, .5, .75])
]

#Generate data:
yref = DataHR{DataF1}(sweeplist) #Create empty pattern
ydel = DataHR{DataF1}(sweeplist) #Create empty pattern
for coord in subscripts(ydel)
	(ϕ,) = parameter(ydel, coord)
	_y = cos(t+ϕ)
	ydel.subsets[coord...] = _y
	yref.subsets[coord...] = y
end


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Integration/Differentiation/yvsx")
s = add(plot, vvst, title="Integration/Differentiation")
	add(s, y, id="sig")
	add(s, dydt, id="dy/dt")
	add(s, ∫ydt, id="integ(y)dt")
	add(s, ycross(y, dydt), line(style=:none), glyph(shape=:o, color=:red), id="crossings")
s = add(plot, vvst, title="Lissajous Curves")
	add(s, yvsx(ydel,yref))

#==Show results
===============================================================================#
ncols = 1
if !isdefined(:plotlist); plotlist = Set([:grace]); end
if in(:grace, plotlist)
	import EasyPlotGrace
	plotdefaults = GracePlot.defaults(linewidth=2.5)
	gplot = GracePlot.new()
		GracePlot.set(gplot, plotdefaults)
	render(gplot, plot, ncols=ncols); display(gplot)
end
if in(:MPL, plotlist)
	import EasyPlotMPL
	display(:MPL, plot, ncols=ncols);
end


:Test_Complete
