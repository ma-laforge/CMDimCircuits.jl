#Demo 6: Fourier Transforms
#-------------------------------------------------------------------------------

using MDDatasets
using CircuitAnalysis
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = axes(ylabel="Amplitude (V)", xlabel="Time (s)")
vvsf = axes(ylabel="Amplitude (V)", xlabel="Frequency (Hz)")
dbvsf = axes(ylabel="Amplitude (dB)", xlabel="Frequency (Hz)")
fvspad = axes(ylabel="Frequency (Hz)", xlabel="padding")


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


#==Return plot to user (call evalfile(...))
===============================================================================#
ncols = 1
(plot, ncols)
