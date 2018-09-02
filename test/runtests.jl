#Test code
#-------------------------------------------------------------------------------

using CircuitAnalysis

#No real test code yet... just run demos:


#==Input data
===============================================================================#
sepline = "---------------------------------------------------------------------"
f = collect(1:3)*1e9


#==Intermediate Computations
===============================================================================#


#==Tests
===============================================================================#

println("\nTest impedance operations:")
println(sepline)

@show c = capacitance(5e-15)
try; admittance(c); @warn("Failed")
catch e; @info("Fail successful: ", e); end

@show ycap = admittance(c, f=1e9)
@show zcap = impedance(c, f=1e9)


println("\nTest impedance{vector} operations:")
println(sepline)
@show ycap = admittance(c, f=f)
@show -ycap
#@show ycap .* 5
#@show 5 .* ycap
#@show ycap .+ ycap
#@show ycap ./ 5
#try; 5 ./ ycap; @warn("Failed") #Would make impedance
#catch e; @info("Fail successful."); end

println("\nTest unit conversion:")
println(sepline)
@show dB10(2), dB20(2)
@show dB(2,:Wratio), dB(2,:Vratio), dB(2,:Iratio)
@show dBm(2,:W), dBm(2,:VRMS), dBm(2,:Vpk)
@show dBW(2,:W), dBW(2,:VRMS), dBW(2,:Vpk)
@show Vpk(2,:W; R=50), Vpk(2,:VRMS)
@show Ipk(2,:W; R=50), Ipk(2,:IRMS)
@show VRMS(2,:W; R=50), VRMS(2,:Vpk)
@show IRMS(2,:W; R=50), IRMS(2,:Ipk)

:Test_Complete
