#Demo 2: Chaining ABCD matrices
#-------------------------------------------------------------------------------

using FileIO2
using MDDatasets
using NetwAnalysis
using EasyPlot


#==Constants
===============================================================================#
dbvsf = axes(ylabel="Amplitude (dB)", xlabel="Frequency (Hz)")
axes_loglin = axes(xscale = :log, yscale = :lin)
color1 = line(color=:red, width=2)
color2 = line(color=:blue, width=2)
color3 = line(color=:green, width=2)

#==Input data
===============================================================================#
C = capacitance(2e-12)
R = 20.0
#f = (1:10)*1e9
f = logspace(log10(1e3), log10(20e9), 100)
xrange = axes(xmin=1e6, xmax=100e9)


#==Computations
===============================================================================#
#Use DataF1 (function of 1 argument) to augment expressivity:
f = DataF1(f, f)
_1 = ones(f)

#Compute ABCD matrix of series R:
sng = true #Compute using single ABCD matrix?
if sng
	#Compute single ABCD matrix:
	@show TR = series(:ABCD, impedance(R))
else
	#Compute ABCD{DataF1}:
	TR = series(:ABCD, impedance(R*_1))
end

#Compute ABCD matrix of shunt capacitors:
TC1 = shunt(:ABCD, admittance(C, f=f))
TC2 = shunt(:ABCD, impedance(C, f=f))

#Compute Pi network:
T = TC1*TR*TC2

S = Network(:S, T)
(s11, s12, s21, s22) = mx2elem(S)


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Pi Network Cascade")
s = add(plot, axes_loglin, xrange, dbvsf, title="Reflection Coefficient")
	add(s, dB20(s11), color1, id="s11")
	add(s, dB20(s22), color2, id="s11")
s = add(plot, axes_loglin, xrange, dbvsf, title="Transmission Coefficient")
	add(s, dB20(s12), color1, id="s12")
	add(s, dB20(s21), color2, id="s21")


#==Return plot to user (call evalfile(...))
===============================================================================#
ncols = 1
(plot, ncols)
