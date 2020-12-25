#demo_psf_r.jl: psf read tests
#-------------------------------------------------------------------------------

using CMDimCircuits
CMDimCircuits.@using_CData()

try
import LibPSFC #To access sample data ONLY!!!
catch e
	msg = "Demo requires sampled data stored in the \"LibPSFC\" package."
	msg *= "\nTo execute demo, install with the following:"
	msg *= "\n\n    using Pkg; Pkg.add(PackageSpec(path=\"git://github.com/ma-laforge/LibPSFC.jl\"))"

	@error msg
	rethrow(e)
end

#Get a demo display:
include(CMDimCircuits.demoplotcfgscript)
#Normally use something like:
#CMDimData.@includepkg EasyPlotInspect


#==Constants
===============================================================================#
vvst = cons(:a, labels = set(yaxis="Amplitude (V)", xaxis="Time (s)"))
color1 = cons(:a, line = set(color=:red))
color2 = cons(:a, line = set(color=:blue))
color3 = cons(:a, line = set(color=:green))


#==Input data
===============================================================================#
testfile = "timeSweep"
filepath = joinpath(LibPSFC.rootpath, "core/data", testfile)

@info("Reading $filepath...")
EDAData.open_psf(filepath) do data
	global inp, outp0, outp1
	@show data
#	@show names(data) #Too many
	inp = read(data, "INP")
	outp0 = read(data, "OUTP<0>")
	outp1 = read(data, "OUTP<1>")
end


#==Generate plot
===============================================================================#
plot1 = push!(cons(:plot, vvst, title="VCO"),
	cons(:wfrm, inp, color1, label="Vinp"),
	cons(:wfrm, outp0, color2, label="Voutp<0>"),
	cons(:wfrm, outp1, color3, label="Voutp<1>"),
)

pcoll = push!(cons(:plot_collection, title="EDAData Tests: psf Format"), plot1)
	pcoll.ncolumns = 1



#==Display results as a plot
===============================================================================#
EasyPlot.displaygui(pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
