#NetwAnalysis show functions
#-------------------------------------------------------------------------------


#==Generate friendly show functions
===============================================================================#

Base.show{NP}(io::IO, t::Type{NPType{NP}}) =	print(io, "NPType{:$NP}")

_printmatrix{T<:Number}(io::IO, m::NetworkParameterMatrix{T}) = println(io, m)
function _printmatrix(io::IO, m::NetworkParameterMatrix)
	nports = portcount(m)
	for row = 1:nports, col = 1:nports
		print(io, "  ($row,$col)=")
		if isassigned(m, row, col)
			println(io, m[row, col])
		else
			println(io, "UNDEFINED")
		end
	end
end

function Base.show(io::IO, np::SParameters)
	println(io, "SParameters{$(portcount(np))-port, z0=$(np.z0)}[")
	_printmatrix(io, np.m)
	println(io, "]")
end

function Base.show(io::IO, np::TParameters)
	println(io, "TParameters{$(portcount(np))-port, z0=$(np.z0)}[")
	_printmatrix(io, np.m)
	println(io, "]")
end

function Base.show(io::IO, np::ZParameters)
	println(io, "ZParameters{$(portcount(np))-port}[")
	_printmatrix(io, np.m)
	println(io, "]")
end

function Base.show(io::IO, np::YParameters)
	println(io, "YParameters{$(portcount(np))-port}[")
	_printmatrix(io, np.m)
	println(io, "]")
end

function Base.show(io::IO, np::ABCDParameters)
	println(io, "ABCDParameters[")
	_printmatrix(io, np.m)
	println(io, "]")
end

#Last line
