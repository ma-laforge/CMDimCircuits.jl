#FileIO2 tools to manipulate text files
#-------------------------------------------------------------------------------

#==Implements a text reader.

NOTE: Uses inefficient high-level tools (readline/split) to provide functionnality.
==#


#==Constants
===============================================================================#
const splitter_default = [' ', '\t']
const splitter_csv = [' ', '\t', ',']

#==Main data structures
===============================================================================#
mutable struct TextReader{T<:TextFormat} <: AbstractReader{T}
	s::IO
	splitter
	linebuf::Vector
end

#Define default TextReader - when text format not (fully) specified:
(::Type{TextReader})(s::IO, splitter, linebuf::Vector) =
	TextReader{TextFormat{UnknownTextEncoding}}(s, splitter, linebuf)
(::Type{TextReader{TextFormat}})(s::IO, splitter, linebuf::Vector) =
	TextReader{TextFormat{UnknownTextEncoding}}(s, splitter, linebuf)

#Default splitter value:
(RT::Type{T})(s::IO, splitter = splitter_default) where T<:TextReader =
	RT(s, splitter, String[])


#==Helper functions
===============================================================================#
#Advance TextReader linebuf, if necessary:
#TODO: Re-implement with more efficient, lower level functions
function refreshbuf(r::TextReader)
	while length(r.linebuf) < 1
		if eof(r.s); throw(EOFError()); end
		linebuf = split(chomp(readline(r.s)), r.splitter)

		for token in linebuf
			if token != ""
				push!(r.linebuf, token)
			end
		end
	end
end


#==Open/read/close functions
===============================================================================#

open(RT::Type{T}, path::String, splitter = splitter_default) where T<:TextReader =
	RT(open(path, "r"), splitter)
open(RT::Type{TextReader{T}}, path::String, splitter = splitter_csv) where T<:CSVFormat =
	RT(open(path, "r"), splitter)

#Read in entire text file as string
function read(RT::Type{T}, path::String) where T<:TextReader
	open(RT, path) do reader
		return read(reader.s, String)
	end
end

#Read in next token as String:
function read(r::TextReader, ::Type{DT}) where DT<:AbstractString
	refreshbuf(r)
	v = popfirst!(r.linebuf)
	try
		#Read ahead if necessary (Update state for eof()):
		refreshbuf(r)
	catch
	end
	return v
end

#Read in next token & interpret as of type DT:
function read(r::TextReader, ::Type{DT}) where DT
	return parse(DT, read(r, String))
end

#Read in next token & interpret as most appropriate type:
function read(r::TextReader, ::Type{Any})
	return parse(read(r, String))
end


close(r::TextReader) = close(r.s)

#==Support functions
===============================================================================#
eof(r::TextReader) = (eof(r.s) && length(r.linebuf) < 1)

function Base.readline(r::TextReader)
	linebuf = []
	return readline(r.s)
end

function Base.read(r::TextReader, String)
	linebuf = []
	return read(r.s, String)
end

#Last line
