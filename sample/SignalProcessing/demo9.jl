#Demo 9: Integration/differentiation
#-------------------------------------------------------------------------------

using CMDimCircuits
CMDimCircuits.@using_CData()

#Get a demo display:
include(CMDimCircuits.demoplotcfgscript)
#Normally use something like:
#CMDimData.@includepkg EasyPlotInspect


#==Constants
===============================================================================#
vvst = cons(:a, labels = set(yaxis="Amplitude (V)", xaxis="Time (s)"))
sigvscosref = cons(:a, labels = set(yaxis="Signal Amplitude (V)", xaxis="Ref cos(t) Value"))
noline = cons(:a, line = set(style=:none))


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

𝜙 = parameter(DataHR, sweeplist, "phi")
ydel = cos(t+𝜙)
yref = y

#==Generate plot
===============================================================================#
plot1 = push!(cons(:plot, vvst, title="Integration/Differentiation"),
	cons(:wfrm, y, label="sig"),
	cons(:wfrm, dydt, label="dy/dt"),
	cons(:wfrm, ∫ydt, label="integ(y)dt"),
	cons(:wfrm, ycross(y, dydt), noline, glyph=set(shape=:o, color=:red), label="crossings"),
)
plot2 = push!(cons(:plot, sigvscosref, title="Lissajous Curves: yvsx(cos(t+ϕ), cos(t))"),
	cons(:wfrm, yvsx(ydel,yref)),
)

pcoll = push!(cons(:plotcoll, title="Integration/Differentiation/yvsx"), plot1, plot2)
	pcoll.ncolumns = 1


#==Display results in pcoll
===============================================================================#
EasyPlot.displaygui(pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
