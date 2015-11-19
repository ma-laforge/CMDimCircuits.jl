#Demo 5: Fourier Series
#-------------------------------------------------------------------------------

using MDDatasets
using SignalProcessing
using EasyPlot


#==Constants
===============================================================================#
vvst = axes(ylabel="Amplitude (V)", xlabel="Time (s)")
vvsf = axes(ylabel="Amplitude (V)", xlabel="Frequency (Hz)")


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
plot=EasyPlot.new(title="Fourier Transform Tests")
s = add(plot, vvst, title="Time domain")
	#add(s, DataF1(sig), id="", glyph(shape=:o))
	add(s, DataF1(sig), id="")
s = add(plot, vvsf, title="")
	add(s, sigSpec, id="", glyph(shape=:o, size=1.5), line(style=:none, color=:red, width=2))
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
	display(:MPL, plot, ncols=ncols);
end

:Test_Complete
