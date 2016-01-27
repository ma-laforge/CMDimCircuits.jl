#NetwAnalysis: Circuit element tools
#-------------------------------------------------------------------------------

#==Helper functions
===============================================================================#
#convenient alias... place in CircuitAnalysis?
mag(x) = abs(x)
mag2(x) = abs2(x)


#==Main functions
===============================================================================#
shunt(t::NPType{:ABCD}, z::TImpedance) = shunt(t, admittance(z))
shunt(t::NPType{:ABCD}, args...; kwargs...) = throw("series: Parameter list not supported")

#Compute k stability factor:
function kstab(S::SParameters{2})
	(s11, s12, s21, s22) = mx2elem(S)
	m2det = mag2(s11*s22 - s21*s12)
	return (1 - mag2(s11) - mag2(s22) + m2det)/(2*mag(s12*s21))
end

#Compute Mason's gain (Unilateral gain):
function Ugain(S::SParameters{2})
	k = kstab(S)
	s21_s12 = S[2,1] / S[1,2]
	return mag2(s21_s12 - 1) / (2*k*mag(s21_s12) - 2*real(s21_s12))
end

#Compute Maximum Available Gain:
function MAG(S::SParameters{2})
	k = kstab(S)
	kadj = max(abs(k), 1) #Degenerates MAG into MSG if k<1
	return mag(S[2,1] / S[1,2]) * (kadj - sqrt(kadj*kadj - 1))
end

#Compute Maximum Stable Gain:
MSG(S::SParameters{2}) = mag(S[2,1] / S[1,2])


#==Access gains using a single exported function
===============================================================================#
gain(::DS{:U}, np::Network) = Ugain(np)
gain(::DS{:MA}, np::Network) = MAG(np)
gain(::DS{:MS}, np::Network) = MSG(np)
gain(s::Symbol, np::Network) = gain(DS(s), np)


#==Auto-convert provided networks
===============================================================================#

fnlist = Symbol[:kstab, :MSG, :MAG, :Ugain]
for fn in fnlist; @eval begin #CODEGEN------------------------------------------

$fn(np::Network) = $fn(Network(:S, np))

end; end #CODEGEN---------------------------------------------------------------


#Last line
