#Demo 2: Chaining ABCD matrices
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
axes_loglin = cons(:a, xyaxes = set(xscale = :log, yscale = :lin))
color1 = cons(:a, line = set(color=:red, width=2))
color2 = cons(:a, line = set(color=:blue, width=2))
color3 = cons(:a, line = set(color=:green, width=2))


#==Input data
===============================================================================#
_logspace(start, stop, n) = 10 .^ range(start, stop=stop, length=n)
C = capacitance(2e-12)
R = 20.0
#f = (1:10)*1e9
f = _logspace(log10(1e3), log10(20e9), 100)
xrange = cons(:a, xyaxes = set(xmin=1e6, xmax=100e9))


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
p_s11 = push!(cons(:plot, axes_loglin, xrange, dbvsf, title="Reflection Coefficient, S11"),
	cons(:wfrm, dB20(s11), color1, label="s11"),
)
p_s22 = push!(cons(:plot, axes_loglin, xrange, dbvsf, title="Reflection Coefficient, S22"),
	cons(:wfrm, dB20(s22), color1, label="s22"),
)
p𝛵 = push!(cons(:plot, axes_loglin, xrange, dbvsf, title="Transmission Coefficients"),
	cons(:wfrm, dB20(s12), color1, label="s12"),
	cons(:wfrm, dB20(s21), color2, label="s21"),
)

Sref = S

let S, s11, s12, s21, s22 #HIDEWARN_0.7
for np in nplist
	X = Network(np, Sref)
	S = Network(:S, X)
	(s11, s12, s21, s22) = mx2elem(S)
	push!(p_s11, cons(:wfrm, dB20(s11), color1, label="s11 ($np)"))
	push!(p_s22, cons(:wfrm, dB20(s22), color1, label="s22 ($np)"))
	push!(p𝛵, cons(:wfrm, dB20(s12), color1, label="s12 ($np)"))
	push!(p𝛵, cons(:wfrm, dB20(s21), color2, label="s21 ($np)"))
end
end

pcoll = push!(cons(:plotcoll, title="Pi Network Cascade + Param Conversion"), p_s11, p_s22, p𝛵)
	pcoll.ncolumns = 1


#==Display results in pcoll
===============================================================================#
display(pdisp, pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll #Will display pcoll a second time if executed from REPL
