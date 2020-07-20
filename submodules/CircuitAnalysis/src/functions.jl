#CircuitAnalysis: function tools
#-------------------------------------------------------------------------------

#==Basic tools
===============================================================================#

#Generate error that a function using dispatchable symbols is not supported:
function nosupport(fn::Function, symlist::Vector{Symbol}, args...; kwargs...)
	argstr = [typeof(a) for a in args]
		arglist = join(argstr, ", ")
	kvstr = ["$k=$(typeof(v))" for (k,v) in kwargs]
		kwarglist = join(kvstr, ", ")
	symstr = [string(sym) for sym in symlist]
		symlist = join(symstr, ", ")
	return ArgumentError("Unsupported: $fn{$symlist}($arglist; $kwarglist)")
end

#Last line
