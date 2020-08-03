#Demo 2: Data patterns
#-------------------------------------------------------------------------------

using CMDimCircuits
CMDimCircuits.@using_CData()

#Get a demo display:
include(CMDimCircuits.demoplotcfgscript); pdisp = getdemodisplay()
#Normally use something like:
#CMDimData.@includepkg EasyPlotInspect; pdisp = EasyPlotInspect.PlotDisplay()


#==Constants
===============================================================================#
tvsbit = cons(:a, labels = set(yaxis="Value", xaxis="Bit Position"))
vvst = cons(:a, labels = set(yaxis="Amplitude (V)", xaxis="Time (s)"))
color1 = cons(:a, line = set(color=:red))
color2 = cons(:a, line = set(color=:blue))


#==Input data
===============================================================================#
tbit = 1e-9 #Bit period
osr = 20 #samples per bit
nsamples = 20


#==Computations
===============================================================================#
seq = 1.0*prbs(reglen=5, seed=1, nsamples=nsamples)
#seq = [1,0,1,1,1,0,0,0]
nsamples = length(seq)
t = DataTime(0:(tbit/osr):(nsamples*tbit))
Π = pulse(t, Pole(3/tbit,:rad), npw=Index(osr))
pat = pattern(seq, Π, nbit=Index(osr))


#==Generate plot
===============================================================================#
p1 = push!(cons(:plot, tvsbit, title="PRBS Sequence"),
	cons(:wfrm, DataF1(collect(1:length(seq)), seq), color2),
)
p2 = push!(cons(:plot, vvst, title="PRBS Pattern"),
	cons(:wfrm, DataF1(Π), color1, label="Pulse"),
	cons(:wfrm, DataF1(pat), color2, label="Pattern"),
)

pcoll = push!(cons(:plotcoll, title="Generating Patterns"), p1, p2)
	pcoll.ncolumns = 1


#==Display results in pcoll
===============================================================================#
display(pdisp, pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll #Will display pcoll a second time if executed from REPL
