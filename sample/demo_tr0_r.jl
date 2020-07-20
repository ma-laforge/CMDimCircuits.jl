#Demo 1: tr0 read tests
#-------------------------------------------------------------------------------

using FileIO2
using EDAData
using EasyPlot
import CppSimData #For sample data


#==Constants
===============================================================================#
vvst = paxes(ylabel="Amplitude (V)", xlabel="Time (s)")
ratvst = paxes(ylabel="Ratio (%)", xlabel="Time (s)")
color1 = line(color=:red)
color2 = line(color=:blue)


#==Input data
===============================================================================#
testfile = "test.tr0"
file = File(:tr0, joinpath(CppSimData.rootpath, "core/data", testfile))

#open(file) do data #Generic open interface.
EDAData._open(file) do data #Ensure EDAData opens file.
	global vin, div_val, out
	@show data
	@show names(data)
	out = read(data, "out")
	vin = read(data, "vin")
	div_val = read(data, "div_val")
end


#==Computations
===============================================================================#


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="EDAData Tests: tr0 Format")
s = add(plot, vvst, title="VCO")
	add(s, out, color2, id="Vout")
	add(s, vin, color1, id="Vcontrol")
s = add(plot, ratvst, title="Divide Ratio")
	add(s, div_val, color1)


#==Return plot to user (call evalfile(...))
===============================================================================#
plot.ncolumns = 1
plot
