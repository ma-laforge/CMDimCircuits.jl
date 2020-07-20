### Split out non-MDDatasets code

None of CircuitAnalysis and some code in NetwAnalysis doesn't depend on CMDData/MDDatasets.

Maybe breaking out that code into a lower-dependency package would be better??

### EDAData: Read in results from parametric sweeps
Add facilities to read collection of files dumped from parametric simulations in the MDDatasets.DataRS structures.

### EDAData: Integrate PSFWrite

### EDAData: Deprecate CppSimData & LibPSFC in samples/tests
Find a better way to get test files for tests/samples.

### EDAData: Add write/read/compare tests
.psf files
