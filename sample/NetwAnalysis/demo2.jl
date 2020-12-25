#Demo 2: Chaining ABCD matrices
#-------------------------------------------------------------------------------

using CMDimCircuits
CMDimCircuits.@using_CData()

#Get a demo display:
include(CMDimCircuits.demoplotcfgscript)
#Normally use something like:
#CMDimData.@includepkg EasyPlotInspect


#==Constants
===============================================================================#
LBLAX_MAGDB = "Magnitude (dB)"
LBLAX_FREQ = "Frequency (Hz)"
color1 = cons(:a, line = set(color=:red, width=2))
color2 = cons(:a, line = set(color=:blue, width=2))


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
is11 = 1; is22 = 2; i𝛵 = 3; #Strip indices

plot = cons(:plot, nstrips=3,
	ystrip1 = set(axislabel=LBLAX_MAGDB, striplabel="Input Reflection (s11)"),
	ystrip2 = set(axislabel=LBLAX_MAGDB, striplabel="Output Reflection (s22)"),
	ystrip3 = set(axislabel=LBLAX_MAGDB, striplabel="Transmission Coefficients (𝛵)"),
	xaxis = set(scale=:log, label=LBLAX_FREQ),
)
push!(plot,
	cons(:wfrm, dB20(s11), color1, label="s11", strip=is11),
	cons(:wfrm, dB20(s22), color1, label="s22", strip=is22),
	cons(:wfrm, dB20(s12), color1, label="s12", strip=i𝛵),
	cons(:wfrm, dB20(s21), color2, label="s21", strip=i𝛵),
)

Sref = S

let S, s11, s12, s21, s22 #HIDEWARN_0.7
for np in nplist
	X = Network(np, Sref)
	S = Network(:S, X)
	(s11, s12, s21, s22) = mx2elem(S)
	push!(plot,
		cons(:wfrm, dB20(s11), color1, label="s11 ($np)", strip=is11),
		cons(:wfrm, dB20(s22), color1, label="s22 ($np)", strip=is22),
		cons(:wfrm, dB20(s12), color1, label="s12 ($np)", strip=i𝛵),
		cons(:wfrm, dB20(s21), color2, label="s21 ($np)", strip=i𝛵),
	)
end
end

pcoll = push!(cons(:plotcoll, title="Pi Network Cascade + Param Conversion"), plot)
	pcoll.ncolumns = 1


#==Display results in pcoll
===============================================================================#
EasyPlot.displaygui(pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
