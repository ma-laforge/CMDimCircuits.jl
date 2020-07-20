using Test, CMDimCircuits


function printheader(title)
	println("\n", title, "\n", repeat("-", 80))
end

function show_testset_section()
	println()
	@info "New test section: " * Test.get_testset().description
end

function show_testset_description()
	@info "   Run test: " * Test.get_testset().description
end

@testset "CMDimCircuits tests" begin
	testfiles = ["cktanalysis.jl", "netwanalysis.jl", "edadata.jl"]

	for testfile in testfiles
		include(testfile)
	end

end #testset

:Test_Complete
