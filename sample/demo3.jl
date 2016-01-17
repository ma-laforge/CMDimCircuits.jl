#Demo 3: sNp (Touchstone) file tests
#-------------------------------------------------------------------------------

using FileIO2
using MDDatasets
using EDAData
using EasyPlot


#==Constants
===============================================================================#
dbvsf = axes(ylabel="Amplitude (dB)", xlabel="Frequency (Hz)")
color1 = line(color=:red, width=2)
color2 = line(color=:blue, width=2)
color3 = line(color=:green, width=2)


#==Input data
===============================================================================#
Z0 = 50 #Ohms (reference impedance)
ℓ = 5e-3 #Meters
Zc = 200 #Ohms (line impedance)
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
A = cosh(γ*ℓ)      ;B = sinh(γ*ℓ)*Zc;
C = sinh(γ*ℓ)/Zc   ;D = cosh(γ*ℓ);

denom = A + B/Z0 + C*Z0 + D
s11 = (A + B/Z0 - C*Z0 - D) / denom
s12 = (2(A*D - B*C)) / denom
s21 = 2 / denom
s22 = (-A + B/Z0 - C*Z0 + D) / denom

data = EDAData.NetworkParameterMatrix{DataF1, :S}(2, ref=Z0)
data.d = [s11 s12; s21 s22]

#Save data to .s2p file:
len_mm = ℓ/1e-3
filepath = "line_$(len_mm)m.s2p"
EDAData._write(File(:sNp, filepath), data)

#Re-load data:
data = EDAData._read(File(:sNp, filepath), numports=2)
@show parameter_type(data)


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="EDAData Tests: sNp (Touchstone) Format")
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
