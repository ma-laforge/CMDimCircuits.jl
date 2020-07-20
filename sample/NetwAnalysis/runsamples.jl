#Run sample code
#-------------------------------------------------------------------------------

function printheader(title)
	println("\n", title, "\n", repeat("-", 80))
end

for i in 1:2
	filename = "demo$i.jl"
	printheader("Executing $filename...")
	result = evalfile(filename)
end

:SampleCode_Executed
