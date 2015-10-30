#SignalProcessing: 
#-------------------------------------------------------------------------------

module SignalProcessing

using MDDatasets

#Functions to this module will be accessing/appending:
import MDDatasets: value

include("base.jl")
include("dt_generators.jl")
include("ct_generators.jl")

#==Warnings
================================================================================
-To save time, many of the functions do not currently maintain numeric data
 types. For example, feeding in an array of Float32 might result in returing an
 array of Float64.  This should be corrected.

-Pole(:SYMBOL, 5) can construct objects with any invalid symbol (Neither :Hz or
 :rad).  This will cause akward error messages.
 TODO: Is there a better way?
==#

#==Exported symbols
===============================================================================#
#==Objects to help with multiple dispatch.
NOTE:
   In turn, the function names become more succinct, and fewer functions need to
   be exported (reduces namespace pollution).
==#
export Pole, Domain

#Accessor functions:
#export

#Functions
#-------------------------------------------------------------------------------
export pulse #Gererate pulse response
export prbs #Generate PRBS sequence
export pattern #Generate pattern from a bit sequence

#==Other interface tools (symbols not exported to avoid collisions):
================================================================================
	MDDatasets.value... already part of MDDatasets
	Base.step... already part of base, so can't export it...
==#

end #SignalProcessing

#Last line
