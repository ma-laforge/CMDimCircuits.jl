#Demo 9: Integration/differentiation
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = axes(ylabel="Amplitude (V)", xlabel="Time (s)")
vvsf = axes(ylabel="Amplitude (V)", xlabel="Frequency (Hz)")
color1 = line(color=2)
color2 = line(color=3)


#==Input data
===============================================================================#
osr = 50 #(fundamental) oversampling ratio
ncycles = 5


#==Computations
===============================================================================#
t = DataF1(0:(2pi/osr):(ncycles*(2pi)))
y = cos(t)

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
	add(s, deriv(y), id="dy/dt")
	add(s, iinteg(y), id="integ(y)dt")
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
