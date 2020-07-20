# Configures plots for optimal demo
#-------------------------------------------------------------------------------
#=
Checks user environment for preferred plotting backend, and return a
corresponding <:EasyPlotDisplay object.
=#

using CMDimData
using CMDimData.EasyPlot

#Must initialize display before defining specialized "getdemodisplay":
EasyPlot.@initbackend()


#==Obtain plot rendering display:
===============================================================================#

#Default behaviour, just use provided display:
_getdemodisplay(pdisp::EasyPlot.EasyPlotDisplay, renderonly::Bool) = pdisp

if @isdefined EasyPlotMPL
#Return a new display object, respecting renderonly:
function _getdemodisplay(pdisp::EasyPlotMPL.PlotDisplay, renderonly::Bool)
	#Use 
	return EasyPlotMPL.PlotDisplay(guimode=!renderonly)
end
end

if @isdefined(EasyPlotGrace)
#Improve display appearance a bit:
function _getdemodisplay(pdisp::EasyPlotGrace.PlotDisplay, renderonly::Bool)
	template = EasyPlotGrace.GracePlot.template("smallplot_mono")
	plotdefaults = EasyPlotGrace.GracePlot.defaults(linewidth=2.5)

	pdisp = EasyPlotGrace.PlotDisplay()
	#pdisp = EasyPlotGrace.PlotDisplay(template=template)
	#pdisp = EasyPlotGrace.PlotDisplay(plotdefaults)

	pdisp.args = tuple(plotdefaults, pdisp.args...) #Improve appearance a bit
	pdisp.guimode = !renderonly
	return pdisp
end
end

#Start with EasyPlot.defaults.maindisplay when selecting a demo display:
getdemodisplay(; renderonly=false) =
	_getdemodisplay(EasyPlot.defaults.maindisplay, renderonly)


# last line
