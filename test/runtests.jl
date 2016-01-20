#Test code
#-------------------------------------------------------------------------------

using NetwAnalysis

#No real test code yet... just run demos:


#==Input data
===============================================================================#
sepline = "---------------------------------------------------------------------"
f = collect(1:5)*1e9


#==Intermediate Computations
===============================================================================#


#==Tests
===============================================================================#

println("\nTest constructors:")
println(sepline)
@show S = Network(:S, [1 2; 3 4])
@show T = Network(:ABCD, [1 2; 3 4])

println("\nTest traits:")
println(sepline)
@show nptype = NPType(S)
@show Symbol(nptype)

println("\nTest matrix operations:")
println(sepline)
@show S
@show S.*2
@show S.*[3 4; 2 1]
@show S*[3 4; 2 1]
@show s21 = S[2,1]

@show c = capacitance(5e-15)

try; admittance(c)
catch e; warn(e); end

@show ycap = admittance(c, f=1e9)
@show zcap = impedance(c, f=1e9)

@show shunt(:ABCD, zcap)
@show shunt(:ABCD, ycap)

@show series(:ABCD, zcap)
@show series(:ABCD, ycap)

:Test_Complete
