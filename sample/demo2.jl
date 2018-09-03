#Demo 2: Chaining ABCD matrices
#-------------------------------------------------------------------------------

using FileIO2
using MDDatasets
using CircuitAnalysis
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
_logspace(start, stop, n) = 10 .^ range(start, stop=stop, length=n)
C = capacitance(2e-12)
R = 20.0
#f = (1:10)*1e9
f = _logspace(log10(1e3), log10(20e9), 100)
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
#TC2 = shunt(:ABCD, impedance(2C, f=f)) #Add asymmetry #TODO: fix multiplication of C
TC2 = shunt(:ABCD, impedance(capacitance(2*C.v), f=f)) #Add asymmetry

#Compute Pi network:
T = TC1*TR*TC2

S = Network(:S, T)
(s11, s12, s21, s22) = mx2elem(S)

#Intermediate network parameters (verify conversion routines):
nplist = [:Y, :Z, :ABCD, :H, :G, :T]

#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Pi Network Cascade")
s_s11 = add(plot, axes_loglin, xrange, dbvsf, title="Reflection Coefficient, S11")
	add(s_s11, dB20(s11), color1, id="s11")
s_s22 = add(plot, axes_loglin, xrange, dbvsf, title="Reflection Coefficient, S22")
	add(s_s22, dB20(s22), color1, id="s22")
strans = add(plot, axes_loglin, xrange, dbvsf, title="Transmission Coefficient")
	add(strans, dB20(s12), color1, id="s12")
	add(strans, dB20(s21), color2, id="s21")

Sref = S

let S, s11, s12, s21, s22 #HIDEWARN_0.7
for np in nplist
	X = Network(np, Sref)
	S = Network(:S, X)
	(s11, s12, s21, s22) = mx2elem(S)
	add(s_s11, dB20(s11), color1, id="s11 ($np)")
	add(s_s22, dB20(s22), color1, id="s11 ($np)")
	add(strans, dB20(s12), color1, id="s12 ($np)")
	add(strans, dB20(s21), color2, id="s21 ($np)")
end
end



#==Return plot to user (call evalfile(...))
===============================================================================#
plot.ncolumns = 1
plot
