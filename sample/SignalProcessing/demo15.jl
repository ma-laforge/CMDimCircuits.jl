#Demo 15: Skew tests
#-------------------------------------------------------------------------------

using CMDimCircuits
CMDimCircuits.@using_CData()

#Get a demo display:
include(CMDimCircuits.demoplotcfgscript)
#Normally use something like:
#CMDimData.@includepkg EasyPlotInspect


#==Constants
===============================================================================#
vvst = cons(:a, labels = set(yaxis="Amplitude (V)", xaxis="Time (s)"))
dnsvst = cons(:a, labels = set(yaxis="Delay wrt Ref (ns)", xaxis="Inserted Delay (s)"))
delayattr = cons(:a,
	line = set(style=:solid, width=3),
	glyph = set(shape=:x, size=2),
)


#==Input data
===============================================================================#
tbit = 1e-9 #Bit period
osr = 20 #samples per bit
nsamples = 127
reglen = 7


#==Computations
===============================================================================#
#NOTE: Not a very computationnaly efficient/stable algorithm
seq = 1.0*prbs(reglen=reglen, seed=1, nsamples=nsamples)
t = DataF1(0:(tbit/osr):((nsamples)*tbit))
tmax = maximum(t)

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("del", tbit.*[-.05, 0, .1])
]

tauref = tbit/5
taupat = tbit/2.5
Πref = pulse(t, Pole(1/tauref,:rad), tpw=tbit)

#Step functions:
Ur = step(t, Pole(1/taupat,:rad), tdel=0)
Uf = -step(t, Pole(1/taupat,:rad), tdel=0*tbit)

#intvec(v) = [val>0?1:(val<0)?-1:0 for val in v]

#Rise/fall sequences
diffseq = diff(vcat(0,seq)) #Assumes starts @ 0.
seqr = 1.0*(diffseq.>0)
seqf = 1.0*(diffseq.<0)

#Rise/fall patterns:
patr = pattern(seqr, Ur, tbit=tbit)
patf = pattern(seqf, Uf, tbit=tbit)

#Complete pattern:
pat = fill(DataHR, sweeplist) do del
	return patr + xshift(patf, del)
end

pat = (pat-0.5)*2 #Center data pattern
pat = clip(pat, xmax=tmax)
patref = (pattern(seq, Πref, tbit=tbit)-0.5)*2 #Center data pattern
pat = xshift(pat, 4.5*tbit)
skew = measskew(patref, pat)
#skew=()
for (k, v) in skew
	println("\n", k, "/1p: ", v/1e-12)
end
del = parameter(pat, "del")
println("\n", "fall delay/1p: ", del/1e-12)


#==Helper functions
===============================================================================#
#TODO: supply eyeparam() as a FoldedAxis or Plot constructor???
eyeparam(tbit; teye=1.5*tbit, tstart=0) = cons(:a,
	xfolded = set(tbit, xstart=tstart, xmax=teye),
	xaxis = set(min=0, max=teye), #Force limits on exact data range.
)


#==Generate plot
===============================================================================#
p1 = push!(cons(:plot, xyaxes=set(xmax=tmax), vvst, title="Patterns"),
	cons(:wfrm, patref+2, line=set(width=1, color=:black), label="ref+2"),
#	cons(:wfrm, Π),
	cons(:wfrm, pat, label="pat"),
)
p2 = push!(cons(:plot, dnsvst, title="Rise Delays"),
	cons(:wfrm, skew[:mean_delrise]/1e-9, delayattr, label="mean"),
	cons(:wfrm, skew[:min_delrise]/1e-9, delayattr, label="min"),
	cons(:wfrm, skew[:max_delrise]/1e-9, delayattr, label="max"),
)
p3 = push!(cons(:plot, vvst, eyeparam(tbit, teye=1.5*tbit, tstart=4.5*tbit), title="Eye"),
	cons(:wfrm, pat, label=""), #No label to see params
)
p4 = push!(cons(:plot, dnsvst, title="Fall Delays"),
	cons(:wfrm, skew[:mean_delfall]/1e-9, delayattr, label="mean"),
	cons(:wfrm, skew[:min_delfall]/1e-9, delayattr, label="min"),
	cons(:wfrm, skew[:max_delfall]/1e-9, delayattr, label="max"),
)

pcoll = push!(cons(:plotcoll, title="Signal Skew Tests"), p1, p2, p3, p4)
	pcoll.ncolumns = 2


#==Display results in pcoll
===============================================================================#
EasyPlot.displaygui(pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
