#SignalProcessing: Time/Frequency domain signals
#-------------------------------------------------------------------------------

import MDDatasets: _operators1, _operators2, _basefn1, _dotop


#==Helper functions
===============================================================================#
missing(s::Symbol)=throw(ArgumentError("Missing argument: $s"))

Base.isvalid(::DS{:time}, d::DataTF) = d.tvalid
Base.isvalid(::DS{:freq}, d::DataTF) = d.fvalid
#invalidate(::DS{:time}, d::DataTF) = (d.tvalid = false)
#invalidate(::DS{:freq}, d::DataTF) = (d.fvalid = false)
#Implement validate(DataTF)?

isteven(d::DataTF) = evenlength(d.t)
isteven(d::DataFreq) = isteven(d.data)
isteven(d::DataTime) = isteven(d.data)


#==Basic DataTime/DataFreq functionality
===============================================================================#
Base.copy(d::DataTF) = DataTF(d.tperiodic, d.tvalid, d.fvalid, t, copy(d.xt), f, copy(d.Xf))
Base.copy(d::DataTime) = validatelengths(DataTime(copy(d.data)))
Base.copy(d::DataFreq) = validatelengths(DataFreq(copy(d.data)))

Base.length(d::DataTime) = length(validatelengths(d).data.t)
Base.length(d::DataFreq) = length(validatelengths(d).data.f)

#==Accessors/Data converters
===============================================================================#
DataF1(d::DataTime) = DataF1(collect(d.data.t), copy(d.data.xt))
DataF1(d::DataFreq) = DataF1(collect(d.data.f), copy(d.data.Xf))

datavec(::DS{:time}, d::DataTF) = d.t
datavec(::DS{:time}, d::DataTime) = datavec(TIME, d.data)
datavec(::DS{:time}, d::DataFreq) = datavec(TIME, d.data)

datavec(::DS{:freq}, d::DataTF) = d.f
datavec(::DS{:freq}, d::DataTime) = datavec(FREQ, d.data)
datavec(::DS{:freq}, d::DataFreq) = datavec(FREQ, d.data)

datavec(::DS{:sig}, d::DataTime) = d.data.xt
datavec(::DS{:sig}, d::DataFreq) = d.data.Xf

#Returns sampled frequency spectrum (non-periodic signals)
#Normalizes FFT results -> |X(f)| samples or {ak} coefficients
function fspectrum(d::DataFreq)
	ensure(!d.data.tperiodic,
		ArgumentError("Frequency spectrum is only valid for non-periodic signals"))
	return DataF1(collect(d.data.f), d.data.Xf)
end

#Returns Fourier-series coefficients (t-periodic signals)
#Normalizes FFT results -> |X(f)| samples or {ak} coefficients
function fcoeff(d::DataFreq)
	ensure(d.data.tperiodic,
		ArgumentError("Fourier-series coefficients are only valid for time-periodic signals"))
	return DataF1(collect(d.data.f), d.data.Xf./length(d.data.t))
end


#==Support basic math operations
===============================================================================#

for op in _operators1; @eval begin #CODEGEN--------------------------------------

#op DataTime:
Base.$op(d::DataTime) = DataTime(d.data, $op(d.data.xt))

#op DataFreq:
Base.$op(d::DataFreq) = DataFreq(d.data, $op(d.data.Xf))

end; end #CODEGEN---------------------------------------------------------------


for op in _operators2; @eval begin #CODEGEN--------------------------------------

#DataTime op Number:
Base.$op(d::DataTime, n::Number) = DataTime(d.data, $(_dotop(op))(d.data.xt, n))

#Number op DataTime:
Base.$op(n::Number, d::DataTime) = DataTime(d.data, $(_dotop(op))(n, d.data.xt))

#DataFreq op Number:
Base.$op(d::DataFreq, n::Number) = DataFreq(d.data, $(_dotop(op))(d.data.Xf, n))

#Number op DataFreq:
Base.$op(n::Number, d::DataFreq) = DataFreq(d.data, $(_dotop(op))(n, d.data.Xf))

end; end #CODEGEN---------------------------------------------------------------


#==Support for 1-argument functions from Base
===============================================================================#

for fn in _basefn1; @eval begin #CODEGEN----------------------------------------

#fn(DataTime)
$fn(d::DataTime) = DataTime(d.data, $fn(d.data.xt))

#fn(DataFreq)
$fn(d::DataFreq) = DataFreq(d.data, $fn(d.data.Xf))

end; end #CODEGEN---------------------------------------------------------------


#==Fourier transforms/series
===============================================================================#
#TODO: use \mscrF (ℱ)??
#function Fourier(x::DataF1)

function timedomain(d::DataFreq)
	if !d.data.tvalid
		d.data.xt = irfft(d.data.Xf, length(d.data.t))
		d.data.tvalid = true
	end
	return DataTime(d.data) #Reference same data
end

function freqdomain(d::DataTime)
	if !d.data.fvalid
		d.data.Xf = rfft(d.data.xt)
		d.data.fvalid = true
	end
	return DataFreq(d.data) #Reference same data
end

#Last line
