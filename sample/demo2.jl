#Demo 1: Read tests
#-------------------------------------------------------------------------------

using FileIO2
using EDAData
using EasyPlot
import LibPSF


#==Constants
===============================================================================#
vvst = axes(ylabel="Amplitude (V)", xlabel="Time (s)")
ratvst = axes(ylabel="Ratio (%)", xlabel="Time (s)")
color1 = line(color=:red)
color2 = line(color=:blue)
color3 = line(color=:green)


#==Input data
===============================================================================#
testfile = "timeSweep"
file = File(:psf, joinpath(LibPSF.rootpath, "core/data", testfile))

#open(file) do data #Generic open interface.
EDAData._open(file) do data #Ensure EDAData opens file.
	global inp, outp0, outp1
	@show data
#	@show names(data) #Too many
	inp = read(data, "INP")
	outp0 = read(data, "OUTP<0>")
	outp1 = read(data, "OUTP<1>")
end


#==Computations
===============================================================================#


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="EDAData Tests: psf Format")
s = add(plot, vvst, title="VCO")
	add(s, inp, color1, id="Vinp")
	add(s, outp0, color2, id="Voutp<0>")
	add(s, outp1, color3, id="Voutp<1>")


#==Return plot to user (call evalfile(...))
===============================================================================#
ncols = 1
(plot, ncols)
