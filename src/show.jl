#NetwAnalysis show functions
#-------------------------------------------------------------------------------


#==Generate friendly show functions
===============================================================================#

function Base.show{NP}(io::IO, t::Type{NPType{NP}})
	print(io, "NPType{:$NP}")
end

function Base.show(io::IO, np::SParameters)
	println(io, "SParameters{$(portcount(np))-port, z0=$(np.z0)}[")
	println(io, np.m)
	println(io, "]")
end

function Base.show(io::IO, np::ZParameters)
	println(io, "ZParameters{$(portcount(np))-port}[")
	println(io, np.m)
	println(io, "]")
end

function Base.show(io::IO, np::YParameters)
	println(io, "YParameters{$(portcount(np))-port}[")
	println(io, np.m)
	println(io, "]")
end

function Base.show(io::IO, np::ABCDParameters)
	println(io, "ABCDParameters[")
	println(io, np.m)
	println(io, "]")
end

#Last line
