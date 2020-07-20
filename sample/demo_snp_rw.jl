#demo_snp_rw.jl: sNp (Touchstone) file tests
#-------------------------------------------------------------------------------

using CMDimCircuits
CMDimCircuits.@using_CData()

#Get a demo display:
include(CMDimCircuits.demoplotcfgscript); pdisp = getdemodisplay()
#Normally use something like:
#CMDimData.@includepkg EasyPlotInspect; pdisp = EasyPlotInspect.PlotDisplay()


#==Constants
===============================================================================#
dbvsf = paxes(ylabel="Amplitude (dB)", xlabel="Frequency (Hz)")
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
len_mm = ℓ/1e-3
filepath_S = "lineS_$(len_mm)m.s2p"
filepath_Z = "lineZ_$(len_mm)m.s2p"

ω = 2pi*f
α = 0
β = ω*sqrt(μ0*ϵ0)
γ = α .+ im*β

#Convert γ type to DataF1 (function of 1 argument):
γ = DataF1(f, γ)

#ABCD matrix:
A = cosh(γ*ℓ)      ;B = sinh(γ*ℓ)*Zc;
C = sinh(γ*ℓ)/Zc   ;D = cosh(γ*ℓ);
T = Network(:ABCD, [A B; C D])

#Convert to S-paramters:
data = Network(:S, T)

#Save data to .s2p file:
EDAData.write_snp(filepath_S, data)
EDAData.write_snp(filepath_Z, Network(:Z, data))

#Re-load data:
data = EDAData.read_snp(filepath_S, numports=2)
(s11, s12, s21, s22) = mx2elem(data)
@show Symbol(NPType(data))


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="EDAData Tests: sNp (Touchstone) Format")
srefl = add(plot, dbvsf, title="Reflection Coefficient")
	add(srefl, dB20(s11), color1, id="s11")
	add(srefl, dB20(s22), color2, id="s11")
strans = add(plot, dbvsf, title="Transmission Coefficient")
	add(strans, dB20(s12), color1, id="s12")
	add(strans, dB20(s21), color2, id="s21")

#Overlay result of reading/writing Z-parameters:
data = EDAData.read_snp(filepath_Z, numports=2)
@show s = Symbol(NPType(data))
(s11, s12, s21, s22) = mx2elem(Network(:S, data))
	add(srefl, dB20(s11), color1, id="s11 ($(s)P)")
	add(srefl, dB20(s22), color2, id="s11 ($(s)P)")
	add(strans, dB20(s12), color1, id="s12 ($(s)P)")
	add(strans, dB20(s21), color2, id="s21 ($(s)P)")
plot.ncolumns = 1


#==Display results as a plot
===============================================================================#
display(pdisp, plot)


#==Return plot to user (call evalfile(...))
===============================================================================#
plot #Will display a second time if executed from REPL
