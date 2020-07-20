#demo_cktanalysis.jl: Run sample code for CircuitAnalysis tools
#-------------------------------------------------------------------------------

using CMDimCircuits
using CMDimCircuits.CircuitAnalysis


#==Input data
===============================================================================#
f = collect(1:5)*1e9


#==Sample code
===============================================================================#
@info("Define circuit elements:")
#@show r = resistance(20.5)
#@show g = conductance(1/50)
@show l = inductance(20e-9)
@show c = capacitance(5e-15)

@info("Compute single-frequency values:")
@show ycap = admittance(c, f=1e9)
@show zcap = impedance(c, f=1e9)

@info("Compute frequency-dependent values:")
@show f
@show ycap = admittance(c, f=f)
@show zcap = impedance(c, f=f)

#println("\nOperations:")
#TODO: fix operations

@info("Perform unit conversions:")
@show dB10(2), dB20(2)
@show dB(2,:Wratio), dB(2,:Vratio), dB(2,:Iratio)
@show dBm(2,:W), dBm(2,:VRMS), dBm(2,:Vpk)
@show dBW(2,:W), dBW(2,:VRMS), dBW(2,:Vpk)
@show Vpk(2,:W; R=50), Vpk(2,:VRMS)
@show Ipk(2,:W; R=50), Ipk(2,:IRMS)
@show VRMS(2,:W; R=50), VRMS(2,:Vpk)
@show IRMS(2,:W; R=50), IRMS(2,:Ipk)


:SampleCode_Executed
