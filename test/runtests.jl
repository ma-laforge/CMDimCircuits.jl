#Test code
#-------------------------------------------------------------------------------

#No real test code yet... just run demos:

using FileIO2
using EasyPlot


#==Obtain plot rendering display:
===============================================================================#

function getdemodisplay(d::EasyPlot.NullDisplay) #Use InspectDR as default
	eval(:(import EasyPlotInspect))
	return EasyPlotInspect.PlotDisplay()
end

function getdemodisplay(d::EasyPlot.UninitializedDisplay)
	if :Grace == d.dtype
		eval(:(import EasyPlotGrace))
		d = EasyPlotGrace.PlotDisplay()
		plotdefaults = GracePlot.defaults(linewidth=2.5)
		d.args = tuple(plotdefaults, d.args...) #Improve appearance a bit
		return d
	elseif :MPL == d.dtype
		eval(:(import EasyPlotMPL))
		return EasyPlotMPL.PlotDisplay()
	elseif :Qwt == d.dtype
		eval(:(import EasyPlotQwt))
		return EasyPlotQwt.PlotDisplay()
	elseif :Plots == d.dtype
		eval(:(import EasyPlotPlots))
		return EasyPlotPlots.PlotDisplay()
	elseif :Inspect == d.dtype
		eval(:(import EasyPlotInspect))
		return EasyPlotInspect.PlotDisplay()
	else #Don't recognize requested display... use default:
		return getdemodisplay(EasyPlot.NullDisplay())
	end
end


#==Show results
===============================================================================#
pdisp = getdemodisplay(EasyPlot.defaults.maindisplay)

for i in 1:3
	file = "../sample/demo$i.jl"
	sepline = "---------------------------------------------------------------------"
	outfile = File(:png, joinpath("./", splitext(basename(file))[1] * ".png"))
	println("\nExecuting $file...")
	println(sepline)
	plot = evalfile(file)
	rplot = EasyPlot.render(pdisp, plot)
	#write(outfile, rplot)
	EasyPlot._display(rplot)
end

:Test_Complete
