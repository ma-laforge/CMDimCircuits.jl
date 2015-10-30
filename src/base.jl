#SignalProcessing base types & core functions
#-------------------------------------------------------------------------------


#==Main data structures
===============================================================================#

#-------------------------------------------------------------------------------
abstract AbstractDataDomain
abstract Domain{Symbol} <: AbstractDataDomain

#Aliases to reduce typo mistakes:
typealias BitDomain Domain{:bit} #Bit domain (discrete time, but one sample per bit)
#TODO: Should BitDomain <: DTDomain?  Should it not exist?
typealias DTDomain Domain{:DT} #Discrete-time domain
typealias CTDomain Domain{:CT} #Continuous-time domain
typealias FDomain Domain{:f} #Frequency domain
typealias ZDomain Domain{:Z} #Z-domain

#-------------------------------------------------------------------------------
abstract AbastractFrequency{Symbol} #Id
typealias Hertz AbastractFrequency{:Hz}
typealias RadiansPerSecond AbastractFrequency{:rad}

#-------------------------------------------------------------------------------
immutable Pole{T<:Number,AbastractFrequency}
	v::T
end
typealias PoleHz{T<:Number} Pole{T,Hertz}
typealias PoleRad{T<:Number} Pole{T,RadiansPerSecond}

#Constructor function:
Pole{T<:Number}(v::T, u::Symbol) = Pole{T,AbastractFrequency{u}}(v)


#==Conversion functions
===============================================================================#
#==Problem:
Conversions do not maintain numeric data types.
TODO: Use proper type conversion routines
==#
Base.convert{T,U<:AbastractFrequency}(::Type{U}, p::Pole{T,U}) = p
Base.convert(::Type{Hertz}, p::PoleRad) = Pole(p.v/(2*pi),:Hz)
Base.convert(::Type{RadiansPerSecond}, p::PoleHz) = Pole(p.v*(2*pi),:rad)

#Value extractor functions:
value(p::Pole) = p.v
value(u::Symbol, p::Pole) = value(convert(AbastractFrequency{u}, p))


#==Main functions
===============================================================================#





#==Generate friendly show functions
===============================================================================#
function Base.show{T,U}(io::IO, p::Pole{T, AbastractFrequency{U}})
	print(io, "Pole{$T,$U}($(p.v))")
end
#Last line
