#Test code
#-------------------------------------------------------------------------------

#No real test code yet... just run demos:

using FileIO2
using EasyPlot

#==Obtain plot rendering display:
===============================================================================#

#NOTE: Modifies input display to improve appearance.
function getdemodisplay(d::EasyPlot.EasyPlotDisplay)
	getdisp(d::EasyPlot.EasyPlotDisplay) = d #Define symbol & default behaviour

	if isdefined(:EasyPlotGrace) #Only access
		function getdisp(d::EasyPlotGrace.PlotDisplay)
			d = deepcopy(d)
			plotdefaults = GracePlot.defaults(linewidth=2.5)
			d.args = tuple(plotdefaults, d.args...) #Improve appearance a bit
			return d
		end
	end

	#TODO: Make sure EasyPlotPlots "renderingtool" is imported
	return getdisp(d)
end

function getdemodisplay(d::EasyPlot.NullDisplay) #Use MPL as default
	eval(:(import EasyPlotMPL))
	return getdemodisplay(EasyPlotMPL.PlotDisplay())
end

function getdemodisplay(d::EasyPlot.UninitializedDisplay)
	if :Grace == d.dtype
		eval(:(import EasyPlotGrace))
		return getdemodisplay(EasyPlotGrace.PlotDisplay())
	elseif :MPL == d.dtype
		eval(:(import EasyPlotMPL))
		return getdemodisplay(EasyPlotMPL.PlotDisplay())
	elseif :Qwt == d.dtype
		eval(:(import EasyPlotQwt))
		return getdemodisplay(EasyPlotQwt.PlotDisplay())
	elseif :Plots == d.dtype
		eval(:(import EasyPlotPlots))
		return getdemodisplay(EasyPlotPlots.PlotDisplay())
	else
		return getdemodisplay(EasyPlot.NullDisplay())
	end
end


#==Show results
===============================================================================#
pdisp = getdemodisplay(EasyPlot.defaults.maindisplay)

#for i in 3
for i in 1:17
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
