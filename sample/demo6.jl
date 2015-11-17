#Demo 6: Fourier Transforms
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = axes(ylabel="Amplitude (V)", xlabel="Time (s)")
vvsf = axes(ylabel="Amplitude (V)", xlabel="Frequency (Hz)")
dbvsf = axes(ylabel="Amplitude (dB)", xlabel="Frequency (Hz)")
fvspad = axes(ylabel="Frequency (Hz)", xlabel="padding")
color1 = line(color=2)
color2 = line(color=3)


#==Input data
===============================================================================#
tfund = 1e-9 #Fundamental
osr = 20 #(fundamental) oversampling ratio


#==Computations
===============================================================================#
tvec = timespace(:ts, tfund/osr, :tfund, tfund)
Δt = step(tvec)
sigvec = rand(DataFloat, length(tvec))
sig = DataTime(tvec, sigvec, tperiodic=false)

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("padding", collect(0:10:100))
]

#Generate data:
sigSpec = DataHR{DataF1}(sweeplist) #Create empty sigSpec
for coord in subscripts(sigSpec)
	(padding,) = parameter(sigSpec, coord)
	tpad = 0:Δt:(Δt*((length(tvec)-1)+padding))
	xtpad = zeros(length(tpad))
	xtpad[1:length(sigvec)] = sigvec
	pad = DataTime(tpad, xtpad, tperiodic=false)
	Fpad = freqdomain(pad)
	sigSpec.subsets[coord...] = abs2(fspectrum(Fpad))
end

fmax = maximum(xval(sigSpec))
fstep = DataHR{DataFloat}(sweeplist) #Create empty data
for coord in subscripts(fstep)
	fstep.subsets[coord...] = sigSpec.subsets[coord...].x[2]
end


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Fourier Transform vs Padding")
s = add(plot, vvst, title="Time Domain")
	add(s, DataF1(sig), id="")
s = add(plot, dbvsf, title="Sampled Frequency Spectrum")
	add(s, dB20(sigSpec), id="")
#throw(:Done)


#==Show results
===============================================================================#
ncols = 1
if !isdefined(:plotlist); plotlist = Set([:grace]); end
if in(:grace, plotlist)
	import EasyPlotGrace
	plotdefaults = GracePlot.defaults(linewidth=2.5)
	gplot = GracePlot.new()
		GracePlot.set(gplot, plotdefaults)
	render(gplot, plot, ncols=ncols); display(gplot)
end
if in(:MPL, plotlist)
	import EasyPlotMPL
	display(Backend{:MPL}, plot, ncols=ncols);
end

:Test_Complete
