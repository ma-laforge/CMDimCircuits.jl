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

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("padding", collect(0:10:100))
]

#Generate data:
sigSpec = fill(DataHR, sweeplist) do padding
	#t-vector (+padding):
	tpad = 0:Δt:(Δt*((length(tvec)-1)+padding))
	#x(t)-vector:
	xtpad = zeros(length(tpad))
	xtpad[1:length(sigvec)] = sigvec
	#Padded time-domain signal:
	pad = DataTime(tpad, xtpad, tperiodic=false)

	Fpad = freqdomain(pad) #Frequency-domain signal (DataFreq)
	return abs2(fspectrum(Fpad)) #Spectrum (DataF1)
end

#Informative:
fmax = maximum(xval(sigSpec))

fstep = DataHR{DataFloat}(sweeplist) #Create empty data
for inds in subscripts(fstep)
	fstep.elem[inds...] = sigSpec.elem[inds...].x[2]
end

@show fmax
@show fstep


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Fourier Transform vs Padding")
s = add(plot, vvst, title="Time Domain")
	add(s, DataF1(collect(tvec), sigvec), id="")
s = add(plot, dbvsf, title="Sampled Frequency Spectrum")
	add(s, dB20(sigSpec), id="")


#==Return plot to user (call evalfile(...))
===============================================================================#
plot.ncolumns = 1
plot
