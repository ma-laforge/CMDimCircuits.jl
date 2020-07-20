#demo_tr0_r.jl: tr0 read tests
#-------------------------------------------------------------------------------

using CMDimCircuits
CMDimCircuits.@using_CData()

try
import CppSimData #To access sample data ONLY!!!
catch e
	@error "Demo requires package \"CppSimData\" for sample data."
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
color1 = line(color=:red, width=3)
color2 = line(color=:blue, width=3)


#==Input data
===============================================================================#
testfile = "test.tr0"
filepath = joinpath(CppSimData.rootpath, "core/data", testfile)

@info("Reading $filepath...")
EDAData.open_tr0(filepath) do data
	global vin, div_val, out
	@show data
	@show names(data)
	out = read(data, "out")
	vin = read(data, "vin")
	div_val = read(data, "div_val")
end


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="EDAData Tests: tr0 Format")
s = add(plot, vvst, title="VCO")
	add(s, out, color2, id="Vout")
	add(s, vin, color1, id="Vcontrol")
s = add(plot, ratvst, title="Divide Ratio")
	add(s, div_val, color1)
plot.ncolumns = 1


#==Display results as a plot
===============================================================================#
display(pdisp, plot)


#==Return plot to user (call evalfile(...))
===============================================================================#
plot #Will display a second time if executed from REPL
