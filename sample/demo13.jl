#Demo 13: Broadcast test: Slicing a Paraboloid
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
a_yvsx = axes(ylabel="Y", xlabel="X")


#==Input data
===============================================================================#
nsteps = 100 #Number of steps to sample x/y values of paraboloid
pext = 10 #sample paraboloid up to x/y = +/-pext

#Paraboloid coefficients
a = 1
b = 2
c = 1

#Axis ranges based on input data:
axrange = axes(xmin=-pext, xmax=pext, ymin=-pext, ymax=pext)


#==Computations
===============================================================================#
paraboloid(x,y) = ((x/a)^2 + (y/b)^2) * c

#Generate parameter sweeps:
#NOTE: x is outermost sweep (because outermost sweep plots on x-axis)
sweeplist = PSweep[
	PSweep("y", collect(-pext:(2pext/nsteps):pext))
	PSweep("x", collect(-pext:(2pext/nsteps):pext))
]

_x = values(sweeplist, "x")
_y = values(sweeplist, "y")

para = DataHR{DataFloat}(sweeplist) #Create empty pattern
plane1 = DataHR{DataFloat}(sweeplist) #Create empty pattern
plane2 = DataHR{DataFloat}(sweeplist) #Create empty pattern
for coord in subscripts(para)
	(y,x) = parameter(para, coord)
	para.subsets[coord...] = paraboloid(x,y)
	plane1.subsets[coord...] = 3x+y/4+2
	plane2.subsets[coord...] = -5(x+10)+5y+50
end

slice_z3 = xcross(para-3) #Cross @ z=3: (x-values@x-coord)
slice_z60 = xcross(para-60) #Cross @ z=60
slice_p1 = xcross(para-plane1) #Cross @ plane1
slice_p2 = xcross(para-plane2) #Cross @ plane1

#Keep x-coordinate, but translate up by y-coordinate:
for dsym in (:slice_z3, :slice_z60, :slice_p1, :slice_p2)
@eval begin
_y = values($dsym.sweeps, "y") #Really only needs to be computed once
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


#==Return plot to user (call evalfile(...))
===============================================================================#
ncols = 1
(plot, ncols)
