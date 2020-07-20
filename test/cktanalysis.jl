@testset "CircuitAnalysis tests" begin show_testset_section() #Scope for test data

using CMDimCircuits.CircuitAnalysis
import CMDimCircuits.CircuitAnalysis: DataTag
import CMDimCircuits.CircuitAnalysis: TCapacitance
import CMDimCircuits.CircuitAnalysis: TImpedance, TAdmittance


#==Input data
===============================================================================#
f = collect(1:3)*1e9
c = capacitance(5e-15)
j = im


#==Tests
===============================================================================#

@testset "Operations On Impedance Values" begin show_testset_description()
	fsng = 1e9
	ω = 2π*fsng
	@test c == TCapacitance(5.0e-15)
	@test_throws ArgumentError admittance(c) #Needs frequency
	@test TImpedance(1/(j*ω*c.v)) == impedance(c, f=fsng)
	@test TAdmittance(j*ω*c.v) == admittance(c, f=fsng)
end

@testset "Operations On Impedance Vectors" begin show_testset_description()
	rtol = 1e-4
	ω = 2π*f
	_ycap = j .* ω .* c.v
	ycap = admittance(c, f=f)
	@test ycap ≈ TAdmittance(_ycap) rtol = rtol
	a = -ycap
	b = TAdmittance(-(ycap.v))
	@test (-ycap) == TAdmittance(-(ycap.v))
	@test (-ycap).v == -(ycap.v)

	#@show ycap .* 5
	#@show 5 .* ycap
	#@show ycap .+ ycap
	#@show ycap ./ 5
	#try; 5 ./ ycap; @warn("Failed") #Would make impedance
	#catch e; @info("Fail successful."); end
end

@testset "Unit conversions" begin show_testset_description()
	rtol = 1e-4
	halfpwr = 3.010299956639812 #approx 3dB
	@test dB10(2) ≈ halfpwr rtol = rtol
	@test dB20(2) ≈ 2*halfpwr rtol = rtol

	#Decibels when provided power/voltage/current ratios
	@test dB(2,:Wratio) ≈ halfpwr rtol = rtol
	@test dB(2,:Vratio) ≈ 2*halfpwr rtol = rtol
	@test dB(2,:Iratio) ≈ 2*halfpwr rtol = rtol

	#Decibels reffered to 1W
	@test dBW(2,:W) ≈ halfpwr rtol = rtol
	@test dBW(2,:VRMS) ≈ 2*halfpwr rtol = rtol
	@test dBW(2,:Vpk) ≈ halfpwr rtol = rtol

	#Decibels reffered to 1mW
	@test dBm(2,:W) ≈ 30+halfpwr rtol = rtol
	@test dBm(2,:VRMS) ≈ 30+2*halfpwr rtol = rtol
	@test dBm(2,:Vpk) ≈ 30+halfpwr rtol = rtol

	#RMS voltage:
	@test VRMS(2,:W; R=50) ≈ sqrt(2*50) rtol = rtol
	@test VRMS(2,:Vpk) ≈ 2/sqrt(2) rtol = rtol

	#RMS current:
	@test IRMS(2,:W; R=50) ≈ sqrt(2/50) rtol = rtol
	@test IRMS(2,:Ipk) ≈ 2/sqrt(2) rtol = rtol

	#Peak voltage:
	@test Vpk(2,:W; R=50) ≈ sqrt(2*50)*sqrt(2) rtol = rtol
	@test Vpk(2,:VRMS) ≈ 2*sqrt(2) rtol = rtol

	#Peak current:
	@test Ipk(2,:W; R=50) ≈ sqrt(2/50)*sqrt(2) rtol = rtol
	@test Ipk(2,:IRMS) ≈ 2*sqrt(2) rtol = rtol
end

end
