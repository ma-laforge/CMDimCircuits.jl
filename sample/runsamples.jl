#Run sample code
#-------------------------------------------------------------------------------

using FileIO2
using EasyPlot


#==Obtain plot rendering display:
===============================================================================#

#getdemodisplay: Potentially overwrite defaults:
#-------------------------------------------------------------------------------
#Default behaviour, just use provided display:
getdemodisplay(d::EasyPlot.EasyPlotDisplay) = d

#Must initialize display before defining specialized "getdemodisplay":
EasyPlot.initbackend()

if isdefined(:EasyPlotGrace)
#Improve display appearance a bit:
function getdemodisplay(d::EasyPlotGrace.PlotDisplay)
	d = EasyPlotGrace.PlotDisplay()
	plotdefaults = GracePlot.defaults(linewidth=2.5)
	d.args = tuple(plotdefaults, d.args...) #Improve appearance a bit
	return d
end
end


#==Show results
===============================================================================#
pdisp = getdemodisplay(EasyPlot.defaults.maindisplay)

for i in 1:2
	file = "./demo$i.jl"
	sepline = "---------------------------------------------------------------------"
	outfile = File(:png, joinpath("./", splitext(basename(file))[1] * ".png"))
	println("\nExecuting $file...")
	println(sepline)
	plot = evalfile(file)
	nosave=true
	if nosave
		display(pdisp, plot)
	elseif isdefined(:EasyPlotInspect) &&
			isa(pdisp, EasyPlotInspect.PlotDisplay) #InspectDR only
		rplot = EasyPlot.render(pdisp, plot)
		rplot.hplot*=.7 #Looks better with wider aspect ratio
		InspectDR.write_png(outfile.path, rplot)
	else
		EasyPlot._write(outfile, plot, pdisp)
	end
end

:SampleCode_Executed
