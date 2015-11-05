#Demo 3: Simple MDDatasets tests
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = axes(xlabel="Time (s)", ylabel="Amplitude (V)")
dfltglyph = glyph(shape=:o)
#color1 = line(color=2)
#color2 = line(color=3)


#==Input data
===============================================================================#
d1 = Data2D(1:10.0)
d2 = shift(d1, 4.5) + 12
d3 = d1 + 12
d4 = Data2D(d1.x, d1.y[end:-1:1])
d9 = shift(d1, 100)

r1 = d1+d2
r2 = d1+d3
r3 = (d2+1)+d1
r4 = max(d1,d4)
#r3 = d1+d9

d10 = shift(d1, 4)
d11 = shift(d1, -2)

#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Simple MDDatasets")
s = add(plot, vvst, title="Adding arbitrary datasets")
	add(s, d1, dfltglyph, id = "d1")
	add(s, d2, dfltglyph, id = "d2")
	add(s, d3, dfltglyph, id = "d3")
	add(s, d4, dfltglyph, id = "d4")
	add(s, r1, dfltglyph, id = "d1+d2")
	add(s, r2, dfltglyph, id = "d1+d3")
	add(s, r3, dfltglyph, id = "(d2+1)+d1")
	add(s, r4, dfltglyph, id = "max(d1,d4)")
s = add(plot, vvst, title="Shifting datasets")
	add(s, d1, dfltglyph, id = "d1")
	add(s, d10, dfltglyph, id = "shift(d1, 4)")
	add(s, d11, dfltglyph, id = "shift(d1, -2)")


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
	display(Backend{:MPL}, plot, ncols=ncols);
end

:Test_Complete
