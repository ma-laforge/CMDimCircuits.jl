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
LBLAX_MAGDB = "Magnitude (dB)"
LBLAX_FREQ = "Frequency (Hz)"
color1 = cons(:a, line = set(color=:red, width=2))
color2 = cons(:a, line = set(color=:blue, width=2))


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
i𝛤 = 1; i𝛵 = 2; #Strip indices

plot = cons(:plot, nstrips=2,
	ystrip1 = set(axislabel=LBLAX_MAGDB, striplabel="Reflection Coefficients (𝛤)"),
	ystrip2 = set(axislabel=LBLAX_MAGDB, striplabel="Transmission Coefficients (𝛵)"),
	xaxis = set(label=LBLAX_FREQ),
)
push!(plot,
	cons(:wfrm, dB20(s11), color1, label="s11", strip=i𝛤),
	cons(:wfrm, dB20(s22), color2, label="s22", strip=i𝛤),
	cons(:wfrm, dB20(s12), color1, label="s12", strip=i𝛵),
	cons(:wfrm, dB20(s21), color2, label="s21", strip=i𝛵),
)

#Overlay result of reading/writing Z-parameters:
data = EDAData.read_snp(filepath_Z, numports=2)
@show s = Symbol(NPType(data))
(s11, s12, s21, s22) = mx2elem(Network(:S, data))
push!(plot,
	cons(:wfrm, dB20(s11), color1, label="s11 ($(s)P)", strip=i𝛤),
	cons(:wfrm, dB20(s22), color2, label="s22 ($(s)P)", strip=i𝛤),
	cons(:wfrm, dB20(s12), color1, label="s12 ($(s)P)", strip=i𝛵),
	cons(:wfrm, dB20(s21), color2, label="s21 ($(s)P)", strip=i𝛵),
)

pcoll = push!(cons(:plotcoll, title="EDAData Tests: sNp (Touchstone) Format"), plot)
	pcoll.ncolumns = 1


#==Display results as a plot
===============================================================================#
display(pdisp, pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll #Will display pcoll a second time if executed from REPL
