# EDAData.jl

## Description

The EDAData.jl module provides a Julia interface for loading data files used by Electronic Design Automation (EDA) tools.  The module interface performs data operations with the help of the high-level `Data*` structures declared in [MDDatasets.jl](https://github.com/ma-laforge/MDDatasets.jl).


At the moment, EDAData.jl supports the following data formats:

 - **.tr0** (SPICE format): Read only
 - **.psf** (Parameter Storage Format): Read only
 - **.sNp** (Touchstone, .s2p, .s3p, ...): Read/Write

## Dependencies

The EDAData.jl module provides wrappers to access file contents as `DataMD` datasets.  For more information on the readers, please visit their respective github pages:

 - **SpiceData.jl** (.tr0): <https://github.com/ma-laforge/SpiceData.jl>
 - **LibPSFC.jl** (.psf): (Optional: 3rd party wrapper) <https://github.com/ma-laforge/LibPSFC.jl>
 - **LibPSF.jl** (.psf): (Pure-Julia implementation) <https://github.com/ma-laforge/LibPSF.jl>

## Sample Usage

 - **File()** (exported by FileIO2): Create file reference

		File([:tr0/:psf/:sNp], path::String)

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

By default, EDAData reads .psf files using the pure-Julia libpsf implementation "LibPSF.jl".  To opt for a C++ implementation, it is possible to select the LibPSFC.jl library by modifying `defaultPSFReader` found in `src/LibPSF.jl`:

	defaultPSFReader = :LibPSFC

### Compatibility

Extensive compatibility testing of EDAData.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-0.7.0 (64-bit)

## Disclaimer

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
