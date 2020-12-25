#Demo 3: Simple MDDatasets tests
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
plot = cons(:plot, nstrips=3,
	ystrip1 = set(axislabel=LBLAX_AMPV, striplabel="Adding arbitrary datasets"),
	ystrip2 = set(axislabel=LBLAX_AMPV, striplabel="Shifting datasets"),
	ystrip3 = set(axislabel=LBLAX_AMPV, striplabel="Clipping datasets"),
	xaxis = set(label=LBLAX_TIME),
)
push!(plot,
	cons(:wfrm, d1, dfltwattr, label="d1", strip=1),
	cons(:wfrm, d2, dfltwattr, label="d2", strip=1),
	cons(:wfrm, d3, dfltwattr, label="d3", strip=1),
	cons(:wfrm, d4, dfltwattr, label="d4", strip=1),
	cons(:wfrm, d1+d2, dfltwattr, label="d1+d2", strip=1),
	cons(:wfrm, d1+d3, dfltwattr, label="d1+d3", strip=1),
	cons(:wfrm, (d2+1)+d1, dfltwattr, label="(d2+1)+d1", strip=1),
	cons(:wfrm, max(d1,d4), dfltwattr, label="max(d1,d4)", strip=1),

	cons(:wfrm, d1, dfltwattr, label="d1", strip=2),
	cons(:wfrm, d10, dfltwattr, label="xshift(d1, 4)", strip=2),
	cons(:wfrm, d11, dfltwattr, label="xshift(d1, -2)", strip=2),

	cons(:wfrm, d1, dfltwattr, label="d1", strip=3),
	cons(:wfrm, d2, dfltwattr, label="d2", strip=3),
	cons(:wfrm, d3, dfltwattr, label="d3", strip=3),
	cons(:wfrm, clip(d1, 2.5:8.25), dfltwattr, label="clip(d1, 2.5:8.25)", strip=3),
	cons(:wfrm, clip(d2, xmax=10), dfltwattr, label="clip(d2, xmax=10)", strip=3),
	cons(:wfrm, clip(d3, xmin=5), dfltwattr, label="clip(d3, xmin=5)", strip=3),
)

pcoll = push!(cons(:plotcoll, title="Simple MDDatasets"), plot)
	pcoll.ncolumns = 1


#==Display results in pcoll
===============================================================================#
EasyPlot.displaygui(pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
