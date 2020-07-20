#Save sample plots to .png files using InspectDR
#-------------------------------------------------------------------------------

using CMDimCircuits
CMDimCircuits.@using_CData()
using InspectDR

#Select specific plotting backend to save plots:
CMDimData.@includepkg EasyPlotInspect
pdisp = EasyPlotInspect.PlotDisplay()

function printheader(title)
	println("\n", title, "\n", repeat("-", 80))
end

for i in 1:17
	filename = "demo$i.jl"
	outfile = joinpath(splitext(basename(filename))[1] * ".png")

	printheader("Executing $filename...")
	plot = evalfile(filename)

	rplot = EasyPlot.render(pdisp, plot)
		#Looks better with wider aspect ratio:
		rplot.layout[:valloc_plot] = rplot.layout[:halloc_plot] * .3
		InspectDR.write_png(outfile, rplot)
end

:SampleCode_Executed
