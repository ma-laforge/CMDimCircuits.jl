#Demo 3: sNp (Touchstone) file tests
#-------------------------------------------------------------------------------

using FileIO2
using MDDatasets
using EDAData
using EasyPlot


#==Constants
===============================================================================#
dbvsf = axes(ylabel="Amplitude (dB)", xlabel="Frequency (Hz)")
color1 = line(color=:red)
color2 = line(color=:blue)
color3 = line(color=:green)


#==Input data
===============================================================================#
#reader = EDAData._open(File(:sNp, "samplefile.s2p"), numports=2)
#data = readall(reader)
#close(reader)
#@show parameter_type(data)
f = collect(1:1:10)*1e9
s11 = f.*0.+0.0001
s11 = DataF1(f, s11)
s11 = 20*log10(s11)


#==Computations
===============================================================================#


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="EDAData Tests: sNp (Touchstone) Format")
s = add(plot, dbvsf, title="Reflection Coefficient")
	add(s, s11, color1, id="S11")


#==Return plot to user (call evalfile(...))
===============================================================================#
ncols = 1
(plot, ncols)
