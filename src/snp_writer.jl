#EDAData: .sNp (Touchstone) file writer

#==Main data structures
===============================================================================#
type SNPWriter <: AbstractWriter{SNPFmt}; end


#==Helper functions
===============================================================================#
function assert_valid(m::NetworkParameterMatrix, context::AbstractString)
	throw(TypeError(:NetworkParameterMatrix, context, NetworkParameterMatrix{DataF1}, typeof(m)))
end
function assert_valid{T}(m::NetworkParameterMatrix{DataF1, T}, context::AbstractString)
	sz = size(m.d)
	if sz[1] != sz[2]
		throw(ArgumentError("NetworkParameterMatrix must be square"))
	end

	x = m.d[1,1].x

	for row in 1:sz[1], col in 1:sz[2]
		if m.d[row,col].x != x
			throw(ArgumentError("NetworkParameterMatrix: frequencies do not match."))
		end
	end

	return true
end


#==Open/write/close functions
===============================================================================#

#Write NetworkParameterMatrix to sNp file
#NOTE: For now, always write f(Hz), data:re/im
function Base.write(::Type{SNPWriter}, path::AbstractString, m::NetworkParameterMatrix)
	assert_valid(m, "write(::Type{SNPWriter}, ...)")
	nptype = parameter_type(m)
	nptype_str = string(nptype)
	nport = size(m.d)[2]
	istwoport = (2==nport)
	portidstr = ""

	if istwoport
		#Special case: write x11, x21, x12, x22... gross...
		m = NetworkParameterMatrix{DataF1, nptype}(
			m.ref,
			[m.d[1,1] m.d[2,1]; m.d[1,2] m.d[2,2]]
		)
		portidstr = ["re$p im$p" for p in ["11", "21", "12", "22"]]
		portidstr = "! freq " * join(portidstr, " ")
	else
		portidstr = "! freq "
		for row in 1:nport, col in 1:nport
			portidstr *= "re$nptype_str$row$col im$nptype_str$row$col"
		end
	end

	open(path, "w") do w
		nowstr = string(now())
		
		println(w, "! $nport port network data")
		println(w, "! Created with C-Data ($nowstr)")

		println(w, "# Hz $nptype_str RI R $(m.ref)")
		println(w, portidstr)

		for ifreq in 1:length(m.d[1,1])
			print(w, m.d[1,1].x[ifreq])
			vcount = 0

			for row in 1:nport, col in 1:nport
				val = m.d[row,col].y[ifreq]
				print(w, " ", real(val), " ", imag(val))

				vcount += 1
				if 0 == vcount % 4
					println(w)
					vcount = 0
				end
			end
			if vcount > 0; println(w); end
		end
	end
end

_write(file::File{SNPFmt}, m::NetworkParameterMatrix) = #Write .sNp with this module.
	write(SNPWriter, file.path, m)

#Last line
