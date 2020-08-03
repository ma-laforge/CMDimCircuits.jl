#demo_tr0_r.jl: tr0 read tests
#-------------------------------------------------------------------------------

using CMDimCircuits
CMDimCircuits.@using_CData()

try
import CppSimData #To access sample data ONLY!!!
catch e
	msg = "Demo requires sampled data stored in the \"CppSimData\" package."
	msg *= "\nTo execute demo, install with the following:"
	msg *= "\n\n    using Pkg; Pkg.add(PackageSpec(path=\"git://github.com/ma-laforge/CppSimData.jl\"))"

	@error msg
	rethrow(e)
end

#Get a demo display:
include(CMDimCircuits.demoplotcfgscript); pdisp = getdemodisplay()
#Normally use something like:
#CMDimData.@includepkg EasyPlotInspect; pdisp = EasyPlotInspect.PlotDisplay()


#==Constants
===============================================================================#
vvst = cons(:a, labels = set(yaxis="Amplitude (V)", xaxis="Time (s)"))
ratvst = cons(:a, labels = set(yaxis="Ratio (%)", xaxis="Time (s)"))
color1 = cons(:a, line = set(color=:red))
color2 = cons(:a, line = set(color=:blue))


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
plot1 = push!(cons(:plot, vvst, title="VCO"),
	cons(:wfrm, out, color2, label="Vout"),
	cons(:wfrm, vin, color1, label="Vcontrol"),
)
plot2 = push!(cons(:plot, ratvst, title="Divide Ratio"),
	cons(:wfrm, div_val, color1),
)

pcoll = push!(cons(:plot_collection, title="EDAData Tests: tr0 Format"), plot1, plot2)
	pcoll.displaylegend = true
	pcoll.ncolumns = 1


#==Display results in pcoll
===============================================================================#
display(pdisp, pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll #Will display pcoll a second time if executed from REPL
