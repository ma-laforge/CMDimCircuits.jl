#Run sample code
#-------------------------------------------------------------------------------

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
