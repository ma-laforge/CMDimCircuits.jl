#EDAData: .sNp (Touchstone) file writer

#==Main data structures
===============================================================================#
type SNPWriter <: AbstractWriter{SNPFmt}; end


#==Useful validations/assertions
===============================================================================#
function validate_structure(np::NetworkParameters, context::AbstractString)
	if !(eltype(np) <: DataF1)
		throw(ArgumentError("$context: NetworkParameters elements must be DataF1."))
	end

	nports = portcount(np)
	x = np[1,1].x

	for row in 1:nports, col in 1:nports
		if np[row,col].x != x
			throw(ArgumentError("NetworkParameters: frequencies do not match."))
		end
	end

	return true
end


#==Helper functions
===============================================================================#


#==Open/write/close functions
===============================================================================#

#Write NetworkParameters to sNp file
#NOTE: For now, always write f(Hz), data:re/im
#      Only supports parameters with eltype(np) <: DataF1
function __write(::Type{SNPWriter}, path::AbstractString, np::NetworkParameters)
	validate_structure(np, "write(::Type{SNPWriter}, ...)")
	nptype = NPType(np)
	nptype_str = string(Symbol(nptype))
	nport = portcount(np)
	istwoport = (2==nport)
	portidstr = ""
	nwkwargs = Dict()
	z0 = 50 #Default

	if typeof(np) <: NetworkParametersRef
		z0 = np.z0
		push!(nwkwargs, :z0 => z0)
	end

	if istwoport
		#Special case: reorder parameters (x11, x21, x12, x22...) gross...
		m = Array(eltype(np), nport, nport)
		m[1,1] = np.m[1,1]; m[1,2] = np.m[2,1];
		m[2,1] = np.m[1,2]; m[2,2] = np.m[2,2];
		np = Network(nptype, m; nwkwargs...)
		portidstr = ["re{$p} im{$p}" for p in ["11", "21", "12", "22"]]
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

		println(w, "# Hz $nptype_str RI R $z0")
		println(w, portidstr)

		for ifreq in 1:length(np[1,1])
			print(w, np[1,1].x[ifreq])
			vcount = 0

			for row in 1:nport, col in 1:nport
				val = np[row,col].y[ifreq]
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

Base.write{TP, NP}(::Type{SNPWriter}, path::AbstractString, np::NetworkParametersRef{TP, NP, DataF1}) =
	__write(SNPWriter, path, np)
Base.write{TP, NP}(::Type{SNPWriter}, path::AbstractString, np::NetworkParametersNoRef{TP, NP, DataF1}) =
	__write(SNPWriter, path, np)

#Write .sNp with this module:
_write{TP, NP, T<:DataF1}(file::File{SNPFmt}, np::NetworkParametersRef{TP, NP, T}) =
	__write(SNPWriter, file.path, np)
_write{TP, NP, T<:DataF1}(file::File{SNPFmt}, np::NetworkParametersNoRef{TP, NP, T}) =
	__write(SNPWriter, file.path, np)


#Last line
