#Demo 9: Integration/differentiation
#-------------------------------------------------------------------------------

using CMDimCircuits
CMDimCircuits.@using_CData()

#Get a demo display:
include(CMDimCircuits.demoplotcfgscript); pdisp = getdemodisplay()
#Normally use something like:
#CMDimData.@includepkg EasyPlotInspect; pdisp = EasyPlotInspect.PlotDisplay()


#==Constants
===============================================================================#
vvst = paxes(ylabel="Amplitude (V)", xlabel="Time (s)")
vvsf = paxes(ylabel="Amplitude (V)", xlabel="Frequency (Hz)")


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

ϕ = parameter(DataHR, sweeplist, "phi")
ydel = cos(t+ϕ)
yref = y

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
plot.ncolumns = 1


#==Display results as a plot
===============================================================================#
display(pdisp, plot)


#==Return plot to user (call evalfile(...))
===============================================================================#
plot
