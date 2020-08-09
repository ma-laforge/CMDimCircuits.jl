#CMDimCircuits: Physics-related tools
#-------------------------------------------------------------------------------

module Physics
	module Constants
		import Base: π #Just in case

		const DECIBELS_PER_NEPERS = 20/log(10) #dB: Decibels/Nepers
		const kB = 1.380_648_8e-23 #J/K: Boltzmann constant
		const h = 6.626_070_040e-34 #Js: Planck constant
		const ħ = h/(2π) #Js: Planck constant (reduced)

		#Free space (vacuum):
		const c = 299_792_458 #m/s: Speed of light (defined)
		const μ0 = 4e-7*π #H/m: Permeability of free space (defined)
		const ɛ0 = 1/(μ0*c^2) #F/m: Permittivity of free space (defined)
		const Z0 = μ0*c #Ω: Characteristic impedance of free space (defined)

		#Particles:
		const q = 1.602_176_565e-19 #C: Elementary charge
		const me = 9.109_382_91e-31 #kg: Electron mass
		const mp = 1.672_621_777e-27 #kg: Proton mass

		function _show()
			symblist = Symbol[
				:DECIBELS_PER_NEPERS, :kB, :h, :ħ,
				:c, :μ0, :ɛ0, :Z0, :q, :me, :mp,
			]
			for s in symblist
				val = Constants.eval(:($s))
				println("$s: $val")
			end
		end

		export DECIBELS_PER_NEPERS
		export kB, h, ħ
		export c, μ0, ɛ0, Z0
		export q, me, mp
	end
end

#Last line
