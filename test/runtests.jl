#Test code
#-------------------------------------------------------------------------------

using NetwAnalysis

#No real test code yet... just run demos:


#==Input data
===============================================================================#
sepline = "---------------------------------------------------------------------"
f = collect(1:3)*1e9


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

println("\nTest impedance operations:")
println(sepline)

@show c = capacitance(5e-15)
try; admittance(c)
catch e; warn(e); end

@show ycap = admittance(c, f=1e9)
@show zcap = impedance(c, f=1e9)

@show shunt(:ABCD, zcap)
@show shunt(:ABCD, ycap)
@show series(:ABCD, zcap)
@show series(:ABCD, ycap)

println("\nTest matrix operations:")
println(sepline)
@show S
@show S.*2
@show S.*[3 4; 2 1]
@show S*[3 4; 2 1]
@show s21 = S[2,1]

println("\nTest impedance{vector} operations:")
println(sepline)
@show ycap = admittance(c, f=f)

println("\nTest matrix{vector} operations:")
println(sepline)
@show TC = shunt(:ABCD, ycap)
@show TCpull = vector_pull(TC)
@show TCpush = vector_push(TCpull)
@show TC-TCpush #Take difference

println("\nTest subset operations:")
println(sepline)
@show S
@show sub(S, [2, 1])
@show sub(S, [1])

println("\nNetwork parameter conversion operations:")
println(sepline)
@show T = Network(:ABCD, S)
@show Z = Network(:Z, T)
@show Network(:ABCD, T) #Passthrough

:Test_Complete
