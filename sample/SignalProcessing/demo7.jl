#Demo 7: Eye diagrams
#-------------------------------------------------------------------------------

using CMDimCircuits
CMDimCircuits.@using_CData()

#Get a demo display:
include(CMDimCircuits.demoplotcfgscript); pdisp = getdemodisplay()
#Normally use something like:
#CMDimData.@includepkg EasyPlotInspect; pdisp = EasyPlotInspect.PlotDisplay()


#==Constants
===============================================================================#
vvst = cons(:a, labels = set(yaxis="Amplitude (V)", xaxis="Time (s)"))


#==Input data
===============================================================================#
tbit = 1e-9 #Bit period
osr = 20 #samples per bit
nbit_Π = 5 #Π-pulse length, in number of bits
nsamples = 127


#==Computations
===============================================================================#
seq = 1.0*prbs(reglen=7, seed=1, nsamples=nsamples)
tΠ = DataF1(0:(tbit/osr):(nbit_Π*tbit))

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("EXTRALVL", [1]) #Add extra level to test more code
	PSweep("tau", tbit.*[1/5, 1/2.5, 1/1.5])
]

#Generate data:
Π = fill(DataHR, sweeplist) do EL, tau
	return pulse(tΠ, Pole(1/tau,:rad), tpw=tbit)
end
pat = (pattern(seq, Π, tbit=tbit)-0.5)*2 #Center data pattern
patRS = DataRS(pat)


#==Generate plot
===============================================================================#
#TODO: supply eyeparam() as a FoldedAxis or Plot constructor???
eyeparam(tbit; teye=1.5*tbit, tstart=0) = cons(:a,
	xfolded = set(tbit, xstart=tstart, xmax=teye),
	xaxis = set(min=0, max=teye), #Force limits on exact data range.
)
eyeaxis = eyeparam(tbit, teye=1.5*tbit, tstart=-.15*tbit)

p1 = push!(cons(:plot, vvst, eyeaxis, title="Eye (DataHR)"),
	cons(:wfrm, pat, label="eye"),
)
p2 = push!(cons(:plot, vvst, title="Pattern"),
	cons(:wfrm, pat, label="pat"),
)
p3 = push!(cons(:plot, vvst, eyeaxis, title="Eye (DataRS)"),
	cons(:wfrm, patRS, label="eye"),
)

pcoll = push!(cons(:plotcoll, title="Eye Diagram Tests"), p1, p2, p3)
	pcoll.displaylegend = false
	pcoll.ncolumns = 2


#==Display results in pcoll
===============================================================================#
display(pdisp, pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll #Will display pcoll a second time if executed from REPL
