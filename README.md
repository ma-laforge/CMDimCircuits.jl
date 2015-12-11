# EDAData.jl

## Description

The EDAData.jl module provides a Julia interface for loading data files used by Electronic Design Automation (EDA) tools.  The module interface performs data operations with the help of the high-level `Data*` structures declared in [MDDatasets.jl](https://github.com/ma-laforge/MDDatasets.jl).


At the moment, EDAData.jl supports the following data formats:

 - **.tr0** (SPICE format): Read only

## Sample Usage

Examples on how to use the EDAData.jl capabilities can be found under the [sample directory](sample/).

## Dependencies

The EDAData.jl module makes use of 3rd party readers.  For more information, please visit the github pages of the respective readers:

 - **CppSimData.jl** (.tr0): <https://github.com/ma-laforge/CppSimData.jl>

## Known Limitations

### Compatibility

Extensive compatibility testing of EDAData.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-0.4.0 (64-bit)

## Disclaimer

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
