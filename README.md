# EDAData.jl

## Description

The EDAData.jl module provides a Julia interface for loading data files used by Electronic Design Automation (EDA) tools.  The module interface performs data operations with the help of the high-level `Data*` structures declared in [MDDatasets.jl](https://github.com/ma-laforge/MDDatasets.jl).


At the moment, EDAData.jl supports the following data formats:

 - **.tr0** (SPICE format): Read only
 - **.psf** (Parameter Storage Format): Read only
 - **.sNp** (Touchstone, .s2p, .s3p, ...): Read/Write

## Dependencies

The EDAData.jl module makes use of 3rd party readers.  For more information, please visit the github pages of the respective readers:

 - **CppSimData.jl** (.tr0): <https://github.com/ma-laforge/CppSimData.jl>
 - **LibPSF.jl** (.psf): <https://github.com/ma-laforge/LibPSF.jl>
 - **LibPSF2.jl** (.psf): <https://github.com/ma-laforge/LibPSF2.jl>

## Sample Usage

 - **File()** (exported by FileIO2): Create file reference

		File([:tr0/:psf/:sNp], path::AbstractString)

 - **Reading .tr0 files**

		r = EDAData._open(File(:tr0, "myfile.tr0"))
		signaldata = read(r, "signalname")
		close(r)

 - **Reading .psf files**

		r = EDAData._open(File(:psf, "myfile.psf"))
		signaldata = read(r, "signalname")
		close(r)

 - **Reading .sNp files**

		r = EDAData._read(File(:sNp, "myfile.s2p"), numports=2)

 - **Writing .sNp files**

		r = EDAData._write(File(:sNp, "outputfile.s2p"))

Further examples on how to use the EDAData.jl capabilities can be found under the [sample directory](sample/).

## Known Limitations

By default, EDAData reads .psf files using the pure-Julia libpsf implementation "LibPSF2.jl".  To opt for a C++ implementation, it is possible to select the LibPSF.jl library using the following julia statement:

	defaultPSFReader = :LibPSF

The constant *must* be defined before the call to import the `EDAData` library.  It can therefore be placed in your ~/.juliarc.jl file.

### Compatibility

Extensive compatibility testing of EDAData.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-0.4.2 (64-bit)

## Disclaimer

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
