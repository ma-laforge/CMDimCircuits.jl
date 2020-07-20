#Demo 3: Simple MDDatasets tests
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = paxes(ylabel="Amplitude (V)", xlabel="Time (s)")
dfltglyph = glyph(shape=:o)
dfltline = line(style=:solid)


#==Input data
===============================================================================#
d1 = DataF1(1:10.0)
d2 = xshift(d1, 4.5) + 12
d3 = d1 + 12
d4 = DataF1(d1.x, d1.y[end:-1:1])
d9 = xshift(d1, 100)

d10 = xshift(d1, 4)
d11 = xshift(d1, -2)

#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Simple MDDatasets")
s = add(plot, vvst, title="Adding arbitrary datasets")
	add(s, d1, dfltline, dfltglyph, id = "d1")
	add(s, d2, dfltline, dfltglyph, id = "d2")
	add(s, d3, dfltline, dfltglyph, id = "d3")
	add(s, d4, dfltline, dfltglyph, id = "d4")
	add(s, d1+d2, dfltline, dfltglyph, id = "d1+d2")
	add(s, d1+d3, dfltline, dfltglyph, id = "d1+d3")
	add(s, (d2+1)+d1, dfltline, dfltglyph, id = "(d2+1)+d1")
	add(s, max(d1,d4), dfltline, dfltglyph, id = "max(d1,d4)")
s = add(plot, vvst, title="Shifting datasets")
	add(s, d1, dfltline, dfltglyph, id = "d1")
	add(s, d10, dfltline, dfltglyph, id = "xshift(d1, 4)")
	add(s, d11, dfltline, dfltglyph, id = "xshift(d1, -2)")
s = add(plot, vvst, title="Clipping datasets")
	add(s, d1, dfltline, dfltglyph, id = "d1")
	add(s, d2, dfltline, dfltglyph, id = "d2")
	add(s, d3, dfltline, dfltglyph, id = "d3")
	add(s, clip(d1, 2.5:8.25), dfltline, dfltglyph, id = "clip(d1, 2.5:8.25)")
	add(s, clip(d2, xmax=10), dfltline, dfltglyph, id = "clip(d2, xmax=10)")
	add(s, clip(d3, xmin=5), dfltline, dfltglyph, id = "clip(d3, xmin=5)")


#==Return plot to user (call evalfile(...))
===============================================================================#
plot.ncolumns = 1
plot
