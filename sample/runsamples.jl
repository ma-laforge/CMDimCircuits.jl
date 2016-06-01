#Run sample code
#-------------------------------------------------------------------------------

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
	eval(:(import EasyPlotInspect))
	return getdemodisplay(EasyPlotInspect.PlotDisplay())
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
	elseif :Inspect == d.dtype
		eval(:(import EasyPlotInspect))
		return getdemodisplay(EasyPlotInspect.PlotDisplay())
	else
		return getdemodisplay(EasyPlot.NullDisplay())
	end
end


#==Show results
===============================================================================#
pdisp = getdemodisplay(EasyPlot.defaults.maindisplay)

#tic()
for i in 1:17
#if 13==i; continue; end #Some plot engines fail here (has 0-length data).
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
#toc()

:SampleCode_Executed
