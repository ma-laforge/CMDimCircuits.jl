#Run sample code
#-------------------------------------------------------------------------------

function printheader(title)
	println("\n", title, "\n", repeat("-", 80))
end

for i in 1:17
#if 13==i; continue; end #Some plot engines fail here (has 0-length data).
	filename = "demo$i.jl"
	printheader("Executing $filename...")
	result = evalfile(filename)
end

:SampleCode_Executed
