#Test code
#-------------------------------------------------------------------------------

#No real test code yet... just run demos:

using MDDatasets
import MDDatasets: DS
using EasyPlot

#Set plot backend to Grace, if not already specified by user:
if !isdefined(:plotlist); plotlist = Set([:Grace]); end

#==Define plot rendering function:
===============================================================================#

#Only import EasyPlotGrace if desired: 
if in(:Grace, plotlist)
	import EasyPlotGrace

	function DisplayDemoPlot(::DS{:Grace}, plot::EasyPlot.Plot, ncols::Int)
		plotdefaults = GracePlot.defaults(linewidth=2.5)
		gplot = GracePlot.new()
			GracePlot.set(gplot, plotdefaults)
		render(gplot, plot, ncols=ncols); display(gplot)
		return gplot
	end
end

#Only import EasyPlotMPL (long load time) if desired: 
if in(:MPL, plotlist)
	import EasyPlotMPL

	function DisplayDemoPlot(::DS{:MPL}, plot::EasyPlot.Plot, ncols::Int)
		display(:MPL, plot, ncols=ncols);
	end
end

function DisplayDemoPlot(plotlist::Set, plot::EasyPlot.Plot, ncols::Int)
	for plottype in plotlist
		DisplayDemoPlot(DS(plottype), plot, ncols)
	end
end


#==Show results
===============================================================================#
for i in 1:12
	file = "../sample/demo$i.jl"
	println("\nExecuting $file...")
	(plot, ncols) = evalfile(file)
	DisplayDemoPlot(plotlist, plot, ncols)
end


:Test_Complete
