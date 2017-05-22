#Test code
#-------------------------------------------------------------------------------

using CircuitAnalysis 
using NetwAnalysis

#No real test code yet... just run demos:


#==Input data
===============================================================================#
sepline = "---------------------------------------------------------------------"
f = collect(1:3)*1e9
c = capacitance(5e-15)


#==Intermediate Computations
===============================================================================#
ycap = admittance(c, f=1e9)
zcap = impedance(c, f=1e9)
ycap_vec = admittance(c, f=f)


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
@show shunt(:ABCD, zcap)
@show shunt(:ABCD, ycap)
@show series(:ABCD, zcap)
@show series(:ABCD, ycap)

println("\nTest matrix operations:")
println(sepline)
@show S
@show S.*2
#@show S.*[3 4; 2 1] #TODO: Julia v0.6: Figure out a way to do element-by-element operations??
@show S*[3 4; 2 1]
@show s21 = S[2,1]

println("\nTest matrix{vector} operations:")
println(sepline)
@show TC = shunt(:ABCD, ycap_vec)
@show TCpull = vector_pull(TC)
@show TCpush = vector_push(TCpull)
@show TC-TCpush #Take difference

println("\nTest subset operations:")
println(sepline)
@show S
@show submatrix(S, [2, 1])
@show submatrix(S, [1])

println("\nTest network parameter conversions:")
println(sepline)
@show T = Network(:ABCD, S)
@show Z = Network(:Z, T)
@show Network(:ABCD, T) #Passthrough
@show S2 = Network(:S, Z, z0=75)
@show T = Network(:T, S2)

println("\nTest specific S <=> T conversions:")
println(sepline)
@show S = Network(:S, [0 1; 1 0])
@show T = Network(:T, S)

println("\nRef values:")
println(sepline)
@show _S50 = Network(:S, [1 2; 3 4])
@show _S75 = Network(:S, _S50, z0=75)
@show _T50 = Network(:T, _S50)
@show _T75 = Network(:T, _S75)

println("\nLook at conversion error:")
println(sepline)
@show Network(:T, _S75) - _T75
@show Network(:T, _S75, z0=50) - _T50
@show Network(:T, _S50, z0=75) - _T75
@show Network(:T, _T75, z0=50) - _T50

@show Network(:S, _T50) - _S50
@show Network(:S, _T75) - _S75
@show Network(:S, _T75, z0=50) - _S50

println("\nTest stability & gains:")
println(sepline)
@show S = Network(:S, [1 2; 3 4])
@show kstab(S)
@show gain(:U, S)
@show gain(:MA, S)
@show gain(:MS, S)

:Test_Complete
