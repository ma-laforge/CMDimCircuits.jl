#SignalProcessing base types & core functions
#-------------------------------------------------------------------------------


#==Useful constants
===============================================================================#
const TIME = DS{:time}()
const FREQ = DS{:freq}()


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


#==Time<=>Frequency domain signals
Only supports real signals for now (using rfft).
Users need only provide positive frequency spectrum.
TODO: Could we make this more generic (rename?) to include pos<=>"Frequency"?
TODO: What about 2D images, 3D movies, etc?
TODO: Make generic, instead of basing t/f on DataFloat?
TODO: Is DataTF necessary??  Could having just DataTime & DataFreq be enough?
===============================================================================#
type DataTF
	tperiodic::Bool #Represents a periodic signal
	tvalid::Bool #Time-domain data is valid
	fvalid::Bool #Frequency-domain data is valid
	#NOTE: Keep length(t) as either odd/even, when performing rfft
	t::FloatRange{DataFloat} 
	xt::Vector{DataFloat} #x(t)
	f::FloatRange{DataFloat}
	Xf::Vector{DataComplex} #X(f)
end
DataTF(::DS{:time}, t, xt; tperiodic::Bool=false) =
	DataTF(tperiodic, true, false, t, xt, timetofreq(t), [])

DataTF(::DS{:freq}, f, Xf; teven::Bool=true, tperiodic::Bool=false) = 
	DataTF(tperiodic, false, true, freqtotime(f, teven), [], f, Xf)

#Simple wrapper to point to DataTF:
#-------------------------------------------------------------------------------
immutable DataTime
	data::DataTF
end
DataTime(t::Range, xt::Vector{DataFloat}; tperiodic::Bool=false) = DataTime(DataTF(TIME, t, xt, tperiodic=tperiodic))
DataTime(t::Range; tperiodic::Bool=false) = DataTime(t, collect(t), tperiodic=tperiodic)
#For low-level algorithms... Initializes data ranges:
DataTime(d::DataTF, xt::Vector{DataFloat}) =
	validatelengths(DataTime(DataTF(d.tperiodic, true, false, d.t, xt, d.f, [])))
DataTime(t::Range, xt::DataF1; tperiodic::Bool=false) =
	DataTime(t, sample(xt, t).y, tperiodic=tperiodic)

immutable DataFreq
	data::DataTF
end
DataFreq(f::Range, Xf::Vector{DataComplex}; teven::Bool=true, tperiodic::Bool=false) =
	DataFreq(DataTF(FREQ, f, Xf, teven=teven, tperiodic=tperiodic))
DataFreq(f::Range; teven::Bool=true, tperiodic::Bool=false) =
	DataFreq(f, collect(f), teven=teven, tperiodic=tperiodic)
DataFreq(f::Range, Xf::DataF1; teven::Bool=true, tperiodic::Bool=false) =
	DataFreq(f, sample(Xf, f).y, teven=teven, tperiodic=tperiodic)
#For low-level algorithms... Initializes data ranges:
DataFreq(d::DataTF, Xf::Vector{DataComplex}) =
	validatelengths(DataFreq(DataTF(d.tperiodic, false, true, d.t, [], d.f, Xf)))

#Z-domain data (discrete time, continuous frequency approximation):
#TODO: Think about details a bit more... what about x-values, etc?
DataZ(n::Int; teven::Bool=true) =
	DataFreq(linspace(0, 2pi, n), Xf, teven=teven, tperiodic=false)
DataZ(Xf::Vector{DataComplex}; teven::Bool=true) =
	DataFreq(linspace(0, 2pi, length(Xf)), Xf, teven=teven, tperiodic=false)


#==Useful assertions
===============================================================================#
	
#Validate data lengths:
function validatelengths(d::DataTime)
	@assert(length(d.data.t)==length(d.data.xt), "Invalid DataTime: Lengths do not match: t & x(t)")
	return d
end
function validatelengths(d::DataFreq)
	@assert(length(d.data.f)==length(d.data.Xf), "Invalid DataFreq: Lengths do not match: f & X(f)")
	return d
end


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


#Last line
