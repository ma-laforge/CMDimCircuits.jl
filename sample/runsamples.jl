#Run sample code
#-------------------------------------------------------------------------------

module CMDimCircuits_Sample

#==Helper functions
===============================================================================#
function printheader(title)
	println("\n", title, "\n", repeat("-", 80))
end

filelist = ["demo_cktanalysis.jl",
	"demo_psf_r.jl", "demo_snp_rw.jl", "demo_tr0_r.jl",
]

for file in filelist
	printheader("Executing $file...")
	evalfile(file)
end

end

:SampleCode_Executed
