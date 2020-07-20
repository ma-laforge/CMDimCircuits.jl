@testset "EDAData tests" begin show_testset_section() #Scope for test data

using MDDatasets
using CMDimCircuits.CircuitAnalysis #Calculations
using CMDimCircuits.NetwAnalysis #For manipulating matrices
using CMDimCircuits.EDAData
include("netwanalysis_cmptools.jl")


#==Helper functions
===============================================================================#


@testset ".sNp files: Simple write/read/compare" begin show_testset_description()
	#Input data
	Z0 = 50 #Ohms (reference impedance)
	ℓ = 5e-3 #Meters
	Zc = 200 #Ohms (line impedance)
	μ0 = 4pi*1e-7 #F/m
	ϵ0 = 8.854e-12 #H/m
	f = collect(1:.1:100)*1e9

	#Computations
	len_mm = ℓ/1e-3
	filepath_S = "lineS_$(len_mm)m.s2p"
	filepath_Z = "lineZ_$(len_mm)m.s2p"

	ω = 2pi*f
	α = 0
	β = ω*sqrt(μ0*ϵ0)
	γ = α .+ im*β

	#Convert γ type to DataF1 (function of 1 argument):
	γ = DataF1(f, γ)

	#ABCD matrix:
	A = cosh(γ*ℓ)      ;B = sinh(γ*ℓ)*Zc;
	C = sinh(γ*ℓ)/Zc   ;D = cosh(γ*ℓ);
	T = Network(:ABCD, [A B; C D])

	#Convert to S-paramters:
	S = Network(:S, T)
	(s11, s12, s21, s22) = mx2elem(S)
	@test maxerror(s11, S[1,1]) < SPARAM_THRESH
	@test maxerror(s12, S[1,2]) < SPARAM_THRESH
	@test maxerror(s21, S[2,1]) < SPARAM_THRESH
	@test maxerror(s22, S[2,2]) < SPARAM_THRESH

	ts = typeof(S)
	msg = "typeof(S) = $ts\n" *
	      "TODO: Should be LESS SPECIFIC: NetworkParametersRef{:S,2,DataF1}"
	@warn msg

	#Save data to .s2p file:
	EDAData.write_snp(filepath_S, S)
	EDAData.write_snp(filepath_Z, Network(:Z, S))

	#Re-load data:
	Sread = EDAData.read_snp(filepath_S, numports=2)
		@test :S == Symbol(NPType(Sread))
		@test maxerror(Sread, S) < SPARAM_THRESH

	Zdata = EDAData.read_snp(filepath_Z, numports=2)
		@test :Z == Symbol(NPType(Zdata))
		@test maxerror(Network(:S, Zdata), S) < SPARAM_THRESH
end

@testset ".psf files: Simple write/read/compare" begin show_testset_description()
	@info "      TODO: Add PSFWrite module & tests"
end

@testset ".tr0 files: Simple write/read/compare" begin show_testset_description()
	@info "      TODO: Add tests"
end

end
