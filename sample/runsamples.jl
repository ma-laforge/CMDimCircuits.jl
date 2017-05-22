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

for i in 1:3
	file = "./demo$i.jl"
	sepline = "---------------------------------------------------------------------"
	outfile = File(:png, joinpath("./", splitext(basename(file))[1] * ".png"))
	println("\nExecuting $file...")
	println(sepline)
	plot = evalfile(file)
	rplot = EasyPlot.render(pdisp, plot)
	#write(outfile, rplot)
	EasyPlot._display(rplot)
end

:SampleCode_Executed
