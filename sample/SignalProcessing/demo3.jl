#Demo 3: Simple MDDatasets tests
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
dfltwattr = cons(:a,
	line = set(style=:solid),
	glyph = set(shape=:o),
)


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
p1 = push!(cons(:plot, vvst, title="Adding arbitrary datasets"),
	cons(:wfrm, d1, dfltwattr, label="d1"),
	cons(:wfrm, d2, dfltwattr, label="d2"),
	cons(:wfrm, d3, dfltwattr, label="d3"),
	cons(:wfrm, d4, dfltwattr, label="d4"),
	cons(:wfrm, d1+d2, dfltwattr, label="d1+d2"),
	cons(:wfrm, d1+d3, dfltwattr, label="d1+d3"),
	cons(:wfrm, (d2+1)+d1, dfltwattr, label="(d2+1)+d1"),
	cons(:wfrm, max(d1,d4), dfltwattr, label="max(d1,d4)"),
)
p2 = push!(cons(:plot, vvst, title="Shifting datasets"),
	cons(:wfrm, d1, dfltwattr, label="d1"),
	cons(:wfrm, d10, dfltwattr, label="xshift(d1, 4)"),
	cons(:wfrm, d11, dfltwattr, label="xshift(d1, -2)"),
)
p3 = push!(cons(:plot, vvst, title="Clipping datasets"),
	cons(:wfrm, d1, dfltwattr, label="d1"),
	cons(:wfrm, d2, dfltwattr, label="d2"),
	cons(:wfrm, d3, dfltwattr, label="d3"),
	cons(:wfrm, clip(d1, 2.5:8.25), dfltwattr, label="clip(d1, 2.5:8.25)"),
	cons(:wfrm, clip(d2, xmax=10), dfltwattr, label="clip(d2, xmax=10)"),
	cons(:wfrm, clip(d3, xmin=5), dfltwattr, label="clip(d3, xmin=5)"),
)

pcoll = push!(cons(:plotcoll, title="Simple MDDatasets"), p1, p2, p3)
	pcoll.ncolumns = 1


#==Display results in pcoll
===============================================================================#
display(pdisp, pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll #Will display pcoll a second time if executed from REPL
