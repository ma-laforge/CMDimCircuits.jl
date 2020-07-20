@testset "NetwAnalysis tests" begin show_testset_section() #Scope for test data

using MDDatasets
using CMDimCircuits.CircuitAnalysis
using CMDimCircuits.NetwAnalysis
import CMDimCircuits.NetwAnalysis: NetworkParameters, NetworkParametersNoRef, NetworkParametersRef
include("netwanalysis_cmptools.jl")


#==Input data
===============================================================================#
f = collect(1:3)*1e9
c = capacitance(5e-15)


#==Intermediate Computations
===============================================================================#
ycap = admittance(c, f=1e9)
zcap = impedance(c, f=1e9)
ycap_vec = admittance(c, f=f)


#==Helper functions
===============================================================================#


#==Tests
===============================================================================#
@testset "Test constructors" begin show_testset_description()
	S = Network(:S, [1 2; 3 4])
		@test isa(S, NetworkParametersRef{:S,2,Int64})
		@test S.m == [1 2; 3 4]
		@test S.z0 == 50 #Default
	T = Network(:ABCD, [1 2; 3 4])
		@test isa(T, NetworkParametersNoRef{:ABCD,2,Int64})
		@test T.m == [1 2; 3 4]
end

@testset "Test traits" begin show_testset_description()
	S = Network(:S, [1 2; 3 4])
	nptype = NPType(S)
		@test isa(nptype, NPType{:S})
		@test Symbol(nptype) == :S
end

printheader("Test impedance operations:")
	@show shunt(:ABCD, zcap)
	@show shunt(:ABCD, ycap)
	@show series(:ABCD, zcap)
	@show series(:ABCD, ycap)

@testset "Basic matrix operations" begin show_testset_description()
	S = Network(:S, [1 2; 3 4])
	Sx2 = S * 2
	@test maxerror(Sx2, Network(:S, 2 .* S.m)) < SPARAM_THRESH
	#@show S.*[3 4; 2 1] #TODO: Julia v0.6: Figure out a way to do element-by-element operations??
	mm = S*[3 4; 2 1]
	@test maxerror(mm, Network(:S, S.m * [3 4; 2 1])) < SPARAM_THRESH
	s21 = S[2,1]
	@test s21 == S.m[2,1]
end

@testset "Complex matrix{vector} operations" begin show_testset_description()
	TC = shunt(:ABCD, ycap_vec) #Matrix of vectors
	TCpull = vector_pull(TC) #Vector of matrices
	TCpush = vector_push(TCpull) #Back to matrix of vectors
	@test maxerror(TC, TCpush) < ABCD_THRESH
end

@testset "Subset operations" begin show_testset_description()
	S = Network(:S, [1 2; 3 4])
	Sswapped = submatrix(S, [2, 1]) #Port-swapped
	@test maxerror(Sswapped, Network(:S, [4 3; 2 1])) < SPARAM_THRESH
	Γ = submatrix(S, [1])
		Γ_mx2D = convert(Array{Int64,2}, [S.m[1,1]]')
	x = Network(:S, Γ_mx2D, z0=S.z0)
	@test maxerror(Γ, Network(:S, Γ_mx2D, z0=S.z0)) < SPARAM_THRESH
end

@testset "Network parameter conversions" begin show_testset_description()
	T = Network(:ABCD, S)
	Z = Network(:Z, T)
	T2 = Network(:ABCD, T) #Passthrough
	@test maxerror(T, T2) < ABCD_THRESH
	@show S2 = Network(:S, Z, z0=75)
	@show T = Network(:T, S2)
end

@testset "Specific S <=> T conversions" begin show_testset_description()
	S = Network(:S, [0 1; 1 0])
	T = Network(:T, S)
	@test maxerror(Network(:T, [1.0 0.0; 0.0 1.0], z0=50), T) < TPARAM_THRESH
end

@testset "Matrix impedance transformations" begin show_testset_description()
	_S50 = Network(:S, [1 2; 3 4])
	_S75 = Network(:S, _S50, z0=75)
	_T50 = Network(:T, _S50)
	_T75 = Network(:T, _S75)

	@test maxerror(Network(:T, _S75), _T75) < TPARAM_THRESH
	@test maxerror(Network(:T, _S75, z0=50), _T50) < TPARAM_THRESH
	@test maxerror(Network(:T, _S50, z0=75), _T75) < TPARAM_THRESH
	@test maxerror(Network(:T, _T75, z0=50), _T50) < TPARAM_THRESH

	@test maxerror(Network(:S, _T50), _S50) < SPARAM_THRESH
	@test maxerror(Network(:S, _T75), _S75) < SPARAM_THRESH
	@test maxerror(Network(:S, _T75, z0=50), _S50) < SPARAM_THRESH
	#TODO: add tests more to validate impedance transformation (use realistic impedances)
	#Z->S50->S75; Z->S75
end

printheader("Test stability & gains:")
	@show S = Network(:S, [1 2; 3 4])
	@show kstab(S)
	@show gain(:U, S)
	@show gain(:MA, S)
	@show gain(:MS, S)

end
