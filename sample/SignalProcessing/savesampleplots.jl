#Save sample plots to .png files using InspectDR
#-------------------------------------------------------------------------------

using CMDimCircuits
CMDimCircuits.@using_CData()
#Select specific plotting backend to save plots:
CMDimData.@includepkg EasyPlotInspect

#Looks better with wider aspect ratio:
WIDTH_PLOT = 900
HEIGHT_PLOT = round(Int, WIDTH_PLOT/2)

function printheader(title)
	println("\n", title, "\n", repeat("-", 80))
end

for i in 1:17
	filename = "demo$i.jl"
	outfile = joinpath(splitext(basename(filename))[1] * ".png")

	printheader("Executing $filename...")
	plot = evalfile(filename)

	EasyPlot._write(:png, outfile, :InspectDR, plot, plotdim=set(w=WIDTH_PLOT, h=HEIGHT_PLOT))
end

:SampleCode_Executed
