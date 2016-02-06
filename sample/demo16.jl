#Demo 16: Clock tests
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = axes(ylabel="Amplitude (V)", xlabel="Time (s)")
Tnsvst = axes(ylabel="Period (ns)", xlabel="Time (s)")
dutyvst = axes(ylabel="Duty Cycle (%)", xlabel="Time (s)")
dutyoutvsmaxphi = axes(ylabel="Duty Cycle (%)", xlabel="Maximum Phase Shift")
dpsvst = axes(ylabel="Delay (ps)", xlabel="Time (s)")
dpsvsx = axes(ylabel="Delay (ps)", xlabel="Crossing")
ldelay = line(width=3)
gdelay = glyph(shape=:x, size=2)


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

noise = (rand(length(t))-0.5)*(2*noiseamp)
noise = DataF1(t.x, noise)
ck = sin(2pi*t/tck+ϕ)+noise

#cycle-to-cycle period:
Tc2c = delta(xcross(ck, allow=CrossType(:rise)))

#Duty:
duty = measduty(ck)

stats = measckstats(ck, tck=tck)
kv = sort(collect(keys(stats)))
#stats()
for i in 1:length(stats)
	k, v = (kv[i], stats[kv[i]])
#TODO: maximum() is broken!
#	if maximum(v) < 10e-9
#		println("\n", k, "/1p: ", v/1e-12)
#	else
		println("\n", k, ": ", v)
#	end
end

ϕmax = parameter(ϕ, "phimax")
println("\n", "maximum duty-cycle phase shift: ", ϕmax)


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Clock Stats Tests", displaylegend=true)
s = add(plot, vvst, title="Clock")
	add(s, ck)
s = add(plot, Tnsvst, title="Period (cycle-to-cycle)")
	add(s, Tc2c/1e-9, id="")
s = add(plot, vvst, title="Clock Eye", eyeparam(tck, teye=1*tck))
	add(s, ck, id="")
s = add(plot, dutyvst, title="Duty")
	add(s, duty*100, id="")
s = add(plot, dutyoutvsmaxphi, title="Duty cycle")
	add(s, stats[:mean_duty]*100, id="mean", ldelay, gdelay)
	add(s, stats[:min_duty]*100, id="min", ldelay, gdelay)
	add(s, stats[:max_duty]*100, id="max", ldelay, gdelay)


#==Return plot to user (call evalfile(...))
===============================================================================#
ncols = 2
(plot, ncols)
