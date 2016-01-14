#EDAData show functions
#-------------------------------------------------------------------------------

#==Generate friendly show functions
===============================================================================#


function Base.show{T, NT}(io::IO, m::NetworkParameterMatrix{T, NT})
	sz = size(m.d)
	numports = sz[1]
	#Assert NP matrix size?
	println(io, string(typeof(m)), " - $numports ports [")

	for row = 1:numports, col = 1:numports
		print(io, "($row, $col)=")
		if isdefined(m.d, row, col)
			println(io, m.d[row, col])
		else
			println(io, "UNDEFINED")
		end
	end
	println(io, "]")
end

#Last line
