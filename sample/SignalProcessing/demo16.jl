#Demo 16: Clock tests
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
Tnsvst = cons(:a, labels = set(yaxis="Period (ns)", xaxis="Time (s)"))
dutyvst = cons(:a, labels = set(yaxis="Duty Cycle (%)", xaxis="Time (s)"))
dutyoutvsmaxphi = cons(:a, labels = set(yaxis="Duty Cycle (%)", xaxis="Maximum Phase Shift"))
delayattr = cons(:a,
	line = set(style=:solid, width=3),
	glyph = set(shape=:x, size=2),
)


#==Input data
===============================================================================#
tbit = 1e-9 #Bit period
osr = 20 #samples per bit
ncycles = 100
noiseamp = 100e-3
ϕmax=2pi*.1


#==Computations
===============================================================================#
#Warning: Base functions not yet robust in the presence of noise.
tck = 2*tbit
t = DataF1(0:(tbit/osr):((ncycles)*tck))

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("phimax", 2pi*[-.05, 0, .1])
]

#Generate data:
ϕ = fill(DataHR, sweeplist) do ϕmax
	return ϕmax*cos(2pi*t/tck)
end
#ϕ = ϕmax*cos(2pi*t/tck)

noise = (rand(length(t)) .- 0.5)*(2*noiseamp)
noise = DataF1(t.x, noise)
ck = sin(2pi*t/tck+ϕ)+noise

#cycle-to-cycle period:
Tc2c = delta(xcross(ck, allow=CrossType(:rise)))

#Duty:
duty = measduty(ck)

stats = measckstats(ck, tck=tck)
kv = sort(collect(keys(stats)))
for i in 1:length(stats)
	k, v = (kv[i], stats[kv[i]])
	if maximum(v) < 10e-9
		println("\n", k, "/1p: ", v/1e-12)
	else
		println("\n", k, ": ", v)
	end
end

ϕmax = parameter(ϕ, "phimax")
println("\n", "maximum duty-cycle phase shift: ", ϕmax)


#==Helper functions
===============================================================================#
#TODO: supply eyeparam() as a FoldedAxis or Plot constructor???
eyeparam(tbit; teye=1.5*tbit, tstart=0) = cons(:a,
	xfolded = set(tbit, xstart=tstart, xmax=teye),
	xaxis = set(min=0, max=teye), #Force limits on exact data range.
)


#==Generate plot
===============================================================================#
p1 = push!(cons(:plot, vvst, title="Clock"),
	cons(:wfrm, ck),
)
p2 = push!(cons(:plot, Tnsvst, title="Period (cycle-to-cycle)"),
	cons(:wfrm, Tc2c/1e-9),
)
p3 = push!(cons(:plot, eyeparam(tck, teye=1*tck), vvst, title="Clock Eye"),
	cons(:wfrm, ck),
)
p4 = push!(cons(:plot, dutyvst, title="Duty"),
	cons(:wfrm, duty*100),
)
p5 = push!(cons(:plot, dutyoutvsmaxphi, title="Duty"),
	cons(:wfrm, stats[:mean_duty]*100, delayattr, label="mean"),
	cons(:wfrm, stats[:min_duty]*100, delayattr, label="min"),
	cons(:wfrm, stats[:max_duty]*100, delayattr, label="max"),
)

pcoll = push!(cons(:plotcoll, title="Clock Stats Tests"), p1, p2, p3, p4, p5)
	pcoll.ncolumns = 2


#==Display results in pcoll
===============================================================================#
EasyPlot.displaygui(pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
