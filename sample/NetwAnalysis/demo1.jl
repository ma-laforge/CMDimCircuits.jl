#Demo 1: Transmission line test
#-------------------------------------------------------------------------------

using CMDimCircuits
CMDimCircuits.@using_CData()

#Get a demo display:
include(CMDimCircuits.demoplotcfgscript); pdisp = getdemodisplay()
#Normally use something like:
#CMDimData.@includepkg EasyPlotInspect; pdisp = EasyPlotInspect.PlotDisplay()


#==Constants
===============================================================================#
dbvsf = cons(:a, labels = set(yaxis="Amplitude (dB)", xaxis="Frequency (Hz)"))
color1 = cons(:a, line = set(color=:red, width=2))
color2 = cons(:a, line = set(color=:blue, width=2))
color3 = cons(:a, line = set(color=:green, width=2))


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
γ = α .+ im*β

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
p𝛤 = push!(cons(:plot, dbvsf, title="Reflection Coefficient (Γ)"),
	cons(:wfrm, dB20(s11), color1, label="s11"),
	cons(:wfrm, dB20(s22), color2, label="s22"),
)
p𝛵 = push!(cons(:plot, dbvsf, title="Transmission Coefficient (Τ)"),
	cons(:wfrm, dB20(s12), color1, label="s12"),
	cons(:wfrm, dB20(s21), color2, label="s21"),
)

pcoll = push!(cons(:plotcoll, title="Transmission Line Test"), p𝛤, p𝛵)
	pcoll.ncolumns = 1


#==Display results in pcoll
===============================================================================#
display(pdisp, pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll #Will display pcoll a second time if executed from REPL
