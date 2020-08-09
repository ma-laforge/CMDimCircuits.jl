using Test, CMDimCircuits


function printheader(title)
	println("\n", title, "\n", repeat("=", 80))
end

function show_testset_section()
	println()
	@info "SECTION: " * Test.get_testset().description * "\n" * repeat("=", 80)
end

function show_testset_description()
	@info "Testing: " * Test.get_testset().description
end

testfiles = ["cktanalysis.jl", "netwanalysis.jl", "edadata.jl"]

for testfile in testfiles
	include(testfile)
end

#==List available physics constants (informative)
===============================================================================#
printheader("List of available CMDimCircuits.Physics.Constants.*")
CMDimCircuits.Physics.Constants._show()
println()

:Test_Complete
