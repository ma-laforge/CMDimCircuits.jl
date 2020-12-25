#Demo 6: Fourier Transforms
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
dbvsf = cons(:a, labels = set(yaxis="Amplitude (dB)", xaxis="Frequency (Hz)"))


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
plot_t = push!(cons(:plot, vvst, title="Time Domain"),
	cons(:wfrm, DataF1(collect(tvec), sigvec)),
)
plot_f = push!(cons(:plot, dbvsf, title="Sampled Frequency Spectrum"),
	cons(:wfrm, dB20(sigSpec)),
)

pcoll = push!(cons(:plotcoll, title="Fourier Transform vs Padding"), plot_t, plot_f)
	pcoll.ncolumns = 1


#==Display results in pcoll
===============================================================================#
EasyPlot.displaygui(pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
