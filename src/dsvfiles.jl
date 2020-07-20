#A simple DSV (delimiter-seperated values) file reader
#-------------------------------------------------------------------------------
module DSVFiles
#==Implements a basic character-delimited text reader.
Uses somewhat impractical high-level tools (readline/split) to provide a more
traditional handling of character-delimited files.

#TODO: Doesn't enforce that CSV data MUST HAVE a "," between values.
==#

import Base: open, read, write, close, readline, eof


#==Constants
===============================================================================#
const splitter_default = [' ', '\t']
const splitter_csv = [' ', '\t', ',']


#==Main data structures
===============================================================================#
mutable struct DSVReader
	s::IO
	splitter
	linebuf::Vector
end

#Default splitter value:
(RT::Type{T})(s::IO, splitter = splitter_default) where T<:DSVReader =
	RT(s, splitter, String[])


#==Helper functions
===============================================================================#
#Advance DSVReader linebuf, if necessary:
#TODO: Re-implement with more efficient, lower level functions
function refreshbuf(r::DSVReader)
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

open(RT::Type{T}, path::String, splitter = splitter_default) where T<:DSVReader =
	RT(open(path, "r"), splitter)

#Read in entire text file as string
function read(RT::Type{T}, path::String) where T<:DSVReader
	open(RT, path) do reader
		return read(reader.s, String)
	end
end

#Read in next token as String:
function read(r::DSVReader, ::Type{DT}) where DT<:AbstractString
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
function read(r::DSVReader, ::Type{DT}) where DT
	return parse(DT, read(r, String))
end

#Read in next token & interpret as most appropriate type:
function read(r::DSVReader, ::Type{Any})
	return parse(read(r, String))
end


close(r::DSVReader) = close(r.s)


#==Support functions
===============================================================================#
eof(r::DSVReader) = (eof(r.s) && length(r.linebuf) < 1)

function readline(r::DSVReader)
	linebuf = []
	return readline(r.s)
end

function read(r::DSVReader, String)
	linebuf = []
	return read(r.s, String)
end


#==High-level interface
===============================================================================#

#Default delimiter-seperated value:
open_dsv(path::String, splitter = splitter_default) =
	open(DSVReader, path, splitter = splitter)
open_csv(path::String) =
	open(DSVReader, path, splitter = splitter_csv)

end
#Last line
