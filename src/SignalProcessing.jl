#SignalProcessing: 
#-------------------------------------------------------------------------------

module SignalProcessing

using MDDatasets

#Functions to this module will be accessing/appending:
import MDDatasets: value
import MDDatasets: DataF1

#Type used to dispatch on a symbol & minimize namespace pollution:
#-------------------------------------------------------------------------------
immutable DS{Symbol}; end; #Dispatchable symbol

include("vectorop.jl")
include("base.jl")
include("timefreq.jl")
include("dt_generators.jl")
include("ct_generators.jl")
include("show.jl")

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

#Time/Frequency domain signals:
export DataTime, DataFreq, DataZ

#Functions
#-------------------------------------------------------------------------------
export timedomain, freqdomain #Performs (i)fft, if necessary
export fspectrum #Returns sampled frequency spectrum (non-periodic signals)
export fcoeff #Returns Fourier-series coefficients (t-periodic signals)
export pulse #Gererate pulse response
export prbs #Generate PRBS sequence
export pattern #Generate pattern from a bit sequence
export datavec #getter function
export timespace #Generate a range representing time
#==Implements timespace(:PRIMARY, v1, :SECONDARY, v2; tstart = tstart)
	where PRIMARY/SECONDARY can be of the following combinations:
	(PRIMARY is targeted value - secondary might get rounded)
		(:ts, :tfund)
		(:tfund, :ts)    *TODO
		(:ts, :n)        *TODO
		(:tfund, :n)     *TODO
		(:tsig, :n)      *TODO
	AND:
		ts: sampling period
		tfund: fundamental period of frequency-domain signal
		tspan: actual signal time span (instead of its *fundamental* period)
		n: number of sampling points (always exact)
==#


#==Other interface tools (symbols not exported to avoid collisions):
================================================================================
	MDDatasets.value... already part of MDDatasets
	Base.step... already part of base, so can't export it...
==#

end #SignalProcessing

#Last line
