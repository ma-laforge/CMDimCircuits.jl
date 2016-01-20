#Demo 1: Transmission line test
#-------------------------------------------------------------------------------

using FileIO2
using MDDatasets
using NetwAnalysis
using EasyPlot


#==Constants
===============================================================================#
dbvsf = axes(ylabel="Amplitude (dB)", xlabel="Frequency (Hz)")
color1 = line(color=:red, width=2)
color2 = line(color=:blue, width=2)
color3 = line(color=:green, width=2)


#==Input data
===============================================================================#
z0 = 50 #Ohms (reference impedance)
ℓ = 5e-3 #Meters
zC = 200 #Ohms (line impedance)
μ0 = 4pi*1e-7 #F/m
ϵ0 = 8.854e-12 #H/m
f = collect(1:.1:100)*1e9


#==Computations
===============================================================================#
ω = 2pi*f
α = 0
β = ω*sqrt(μ0*ϵ0)
γ = α+im*β

#Convert γ type to DataF1, function of 1 argument (leverage C-Data toolkit):
γ = DataF1(f, γ)

#ABCD matrix:
A = cosh(γ*ℓ)      ;B = sinh(γ*ℓ)*zC;
C = sinh(γ*ℓ)/zC   ;D = cosh(γ*ℓ);

T = Network(:ABCD, [A B; C D])
S = Network(:S, T, z0=z0)
(s11, s12, s21, s22) = mx2elem(S)

#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Transmission Line Test")
s = add(plot, dbvsf, title="Reflection Coefficient")
	add(s, dB20(s11), color1, id="s11")
	add(s, dB20(s22), color2, id="s11")
s = add(plot, dbvsf, title="Transmission Coefficient")
	add(s, dB20(s12), color1, id="s12")
	add(s, dB20(s21), color2, id="s21")


#==Return plot to user (call evalfile(...))
===============================================================================#
ncols = 1
(plot, ncols)
