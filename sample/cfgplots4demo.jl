# Configures plotting backend to use for demos
#-------------------------------------------------------------------------------

using CMDimData
using CMDimData.EasyPlot
CMDimData.@includepkg EasyPlotInspect
EasyPlot.defaults.guibuilder = EasyPlot.getbuilder(:gui, :InspectDR)

# last line
