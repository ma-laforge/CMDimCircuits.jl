#Demo 3: simple MDDatasets tests
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
const tvst = axes(xlabel="Time (s)", ylabel="Time (s)")
const vvst = axes(xlabel="Time (s)", ylabel="Amplitude (V)")
const dfltglyph = glyph(shape=:o)
#const color1 = line(color=2)
#const color2 = line(color=3)


#==Input data
===============================================================================#
d1 = Data2D(1:10.0)
d2 = Data2D(d1.x .+ 4.5, d1.y .+ 12)
d3 = Data2D(d1.x, d1.y .+ 12)
d4 = Data2D(d1.x .+100, d1.y)

r1 = d1+d2
r2 = d1+d3
#r3 = d1+d4

#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Test SignalProcessing")
s = add(plot, tvst, title="Input signals")
	add(s, d1, dfltglyph, id = "d1")
	add(s, d2, dfltglyph, id = "d2")
	add(s, d3, dfltglyph, id = "d3")
	add(s, r1, dfltglyph, id = "d1+d2")
	add(s, r2, dfltglyph, id = "d1+d3")


#==Show results
===============================================================================#
ncols = 1
if !isdefined(:plotlist); plotlist = Set([:grace]); end
if in(:grace, plotlist)
	import EasyPlotGrace
	const plotdefaults = GracePlot.defaults(linewidth=2.5)
	gplot = GracePlot.new()
		GracePlot.set(gplot, plotdefaults)
	render(gplot, plot, ncols=ncols); display(gplot)
end
if in(:MPL, plotlist)
	import EasyPlotMPL
	display(Backend{:MPL}, plot, ncols=ncols);
end

:Test_Complete
