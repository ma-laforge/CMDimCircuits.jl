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
include(CMDimCircuits.demoplotcfgscript); pdisp = getdemodisplay()
#Normally use something like:
#CMDimData.@includepkg EasyPlotInspect; pdisp = EasyPlotInspect.PlotDisplay()


#==Constants
===============================================================================#
vvst = paxes(ylabel="Amplitude (V)", xlabel="Time (s)")
ratvst = paxes(ylabel="Ratio (%)", xlabel="Time (s)")
color1 = line(color=:red)
color2 = line(color=:blue)
color3 = line(color=:green)


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
plot=EasyPlot.new(title="EDAData Tests: psf Format")
s = add(plot, vvst, title="VCO")
	add(s, inp, color1, id="Vinp")
	add(s, outp0, color2, id="Voutp<0>")
	add(s, outp1, color3, id="Voutp<1>")
plot.ncolumns = 1


#==Display results as a plot
===============================================================================#
display(pdisp, plot)


#==Return plot to user (call evalfile(...))
===============================================================================#
plot #Will display a second time if executed from REPL
