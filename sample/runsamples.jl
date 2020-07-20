#Run sample code
#-------------------------------------------------------------------------------

using CircuitAnalysis


#==Input data
===============================================================================#
f = collect(1:5)*1e9


#==Helper functions
===============================================================================#
sepline = String(fill('-', 80))


#==Intermediate Computations
===============================================================================#


#==Sample code
===============================================================================#
println("\nDefine circuit elements:\n", sepline)
#@show r = resistance(20.5)
#@show g = conductance(1/50)
@show l = inductance(20e-9)
@show c = capacitance(5e-15)

println("\nCompute single-frequency values:\n", sepline)
@show ycap = admittance(c, f=1e9)
@show zcap = impedance(c, f=1e9)

println("\nCompute frequency-dependent values:\n", sepline)
@show f
@show ycap = admittance(c, f=f)
@show zcap = impedance(c, f=f)

#println("\nOperations:", sepline)
#TODO: fix operations

println("\nPerform unit conversions:\n", sepline)
@show dB10(2), dB20(2)
@show dB(2,:Wratio), dB(2,:Vratio), dB(2,:Iratio)
@show dBm(2,:W), dBm(2,:VRMS), dBm(2,:Vpk)
@show dBW(2,:W), dBW(2,:VRMS), dBW(2,:Vpk)
@show Vpk(2,:W; R=50), Vpk(2,:VRMS)
@show Ipk(2,:W; R=50), Ipk(2,:IRMS)
@show VRMS(2,:W; R=50), VRMS(2,:Vpk)
@show IRMS(2,:W; R=50), IRMS(2,:Ipk)


:SampleCode_Executed
