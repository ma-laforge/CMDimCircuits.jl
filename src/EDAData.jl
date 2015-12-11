#EDAData
#-------------------------------------------------------------------------------

module EDAData

import CppSimData
using FileIO2
using MDDatasets

include("tr0.jl")

FileIO2.File(::FileIO2.Shorthand{:tr0}, path::AbstractString) = File{Tr0Fmt}(path)

#==Exported symbols
===============================================================================#
#None

#==Extensions to other modules
================================================================================
	FileIO2.File(:tr0, [FILENAME])
	Base.open()
	Base.step... already part of base, so can't export it...
==#


end #EDAData
