#Demo 13: Broadcast test: Slicing a Paraboloid
#-------------------------------------------------------------------------------

using CMDimCircuits
CMDimCircuits.@using_CData()

#Get a demo display:
include(CMDimCircuits.demoplotcfgscript); pdisp = getdemodisplay()
#Normally use something like:
#CMDimData.@includepkg EasyPlotInspect; pdisp = EasyPlotInspect.PlotDisplay()


#==Constants
===============================================================================#
a_yvsx = paxes(ylabel="Y", xlabel="X")


#==Input data
===============================================================================#
nsteps = 100 #Number of steps to sample x/y values of paraboloid
pext = 10 #sample paraboloid up to x/y = +/-pext

#Paraboloid coefficients
a = 1
b = 2
c = 1

#Axis ranges based on input data:
axrange = paxes(xmin=-pext, xmax=pext, ymin=-pext, ymax=pext)


#==Computations
===============================================================================#
paraboloid(x,y) = ((x/a)^2 + (y/b)^2) * c

#Generate parameter sweeps:
#NOTE: x is outermost sweep (because outermost sweep plots on x-axis)
sweeplist = PSweep[
	PSweep("y", collect(-pext:(2pext/nsteps):pext))
	PSweep("x", collect(-pext:(2pext/nsteps):pext))
]

para = DataHR{DataFloat}(sweeplist) #Create empty pattern
plane1 = DataHR{DataFloat}(sweeplist) #Create empty pattern
plane2 = DataHR{DataFloat}(sweeplist) #Create empty pattern
for inds in subscripts(para)
	(y,x) = coordinates(para, inds)
	para.elem[inds...] = paraboloid(x,y)
	plane1.elem[inds...] = 3x+y/4+2
	plane2.elem[inds...] = -5(x+10)+5y+50
end

slice_z3 = xcross(para-3) #Cross @ z=3: (x-values@x-coord)
slice_z60 = xcross(para-60) #Cross @ z=60
slice_p1 = xcross(para-plane1) #Cross @ plane1
slice_p2 = xcross(para-plane2) #Cross @ plane1

#Keep x-coordinate, but translate up by y-coordinate:
for dsym in (:slice_z3, :slice_z60, :slice_p1, :slice_p2)
@eval begin
_y = parameter($dsym, "y") #Really only needs to be computed once
$dsym = $dsym*0+_y #Keep x-coord, but translate up by y-coordinate of $dsym
end
end


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Sliced Paraboloid", displaylegend=false)
s = add(plot, a_yvsx, axrange, title="Slice with planes z=3 & z=60")
	add(s, slice_z3, id="z=3", line(style=:none, width=2), glyph(shape=:o))
	add(s, slice_z60, id="z=60", line(style=:none, width=2), glyph(shape=:o))
s = add(plot, a_yvsx, axrange, title="Slice with planes 1 & 2")
	add(s, slice_p1, id="plane 1", line(style=:none, width=2), glyph(shape=:o))
	add(s, slice_p2, id="plane 1", line(style=:none, width=2), glyph(shape=:o))
#Change color scheme:
plot.theme.colorscheme = EasyPlot.ColorScheme(EasyPlot.colormap("Blues", 12))
plot.ncolumns = 1


#==Display results as a plot
===============================================================================#
display(pdisp, plot)


#==Return plot to user (call evalfile(...))
===============================================================================#
plot
