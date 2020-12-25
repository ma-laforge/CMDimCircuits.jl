#Demo 5: Fourier Series
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
magvsf = cons(:a, labels = set(yaxis="|X(f)|²", xaxis="Frequency (Hz)"))


#==Input data
===============================================================================#
tfund = 1e-9 #Fundamental
osr = 20 #(fundamental) oversampling ratio
nfund = 20 #cycles of the fundamenal

#==Computations
===============================================================================#
t = DataTime(timespace(:ts, tfund/osr, :tfund, nfund*tfund), tperiodic=true)
sig = sin(t*(2pi/tfund))
Fsig = freqdomain(sig)
#sigSpec = abs2(fspectrum(Fsig)) #Aperiodic
sigSpec = abs2(fcoeff(Fsig)) #Periodic

#==Generate plot
===============================================================================#
plot_t = push!(cons(:plot, vvst, title="Time domain", legend=false),
#	cons(:wfrm, DataF1(sig), glyph=set(shape=:o)),
	cons(:wfrm, DataF1(sig)),
)
plot_f = push!(cons(:plot, magvsf, title="Frequency domain", legend=false),
	cons(:wfrm, sigSpec, glyph=set(shape=:o, size=1.5), line=set(style=:none, color=:red, width=2)),
)

pcoll = push!(cons(:plotcoll, title="Fourier Transform Tests"), plot_t, plot_f)
	pcoll.ncolumns = 1


#==Display results in pcoll
===============================================================================#
EasyPlot.displaygui(pcoll)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
