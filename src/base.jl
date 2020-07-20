#EDAData: base types & core functions
#-------------------------------------------------------------------------------


#==Useful constants
===============================================================================#


#==Main data structures
===============================================================================#
struct Tr0Fmt <: FileIO2.DataFormat; end
struct PSFFmt <: FileIO2.DataFormat; end
struct SNPFmt <: FileIO2.TextFormat{FileIO2.ASCIIEncoding}; end

#Add Shorthand File constructors:
FileIO2.File(::FileIO2.Shorthand{:tr0}, path::String) = File{Tr0Fmt}(path)
FileIO2.File(::FileIO2.Shorthand{:psf}, path::String) = File{PSFFmt}(path)
FileIO2.File(::FileIO2.Shorthand{:sNp}, path::String) = File{SNPFmt}(path)


#Last Line
