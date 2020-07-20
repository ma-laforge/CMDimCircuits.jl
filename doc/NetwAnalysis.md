# NetwAnalysis.jl: Network Analysis Tools

## Description

### Principal Types

**Exported**

 - **`Network`**`{NUMPORTS}` Abstract data type - represents any network.
 - **`NPType`**`{NPSYMBOL}`: Identifies network parameter type (facilitates dispatch).

**Not Exported**

 - **`SParameters`**`{NUMPORTS, DATATYPE}`: Stores S parameters.
 - **`ZParameters`**`{NUMPORTS, DATATYPE}`: Stores Z parameters.
 - **`YParameters`**`{NUMPORTS, DATATYPE}`: Stores Y parameters.
 - **`HParameters`**`{DATATYPE}`: Stores H parameters.
 - **`GParameters`**`{DATATYPE}`: Stores G parameters.
 - **`ABCDParameters`**`{DATATYPE}`: Stores ABCD parameters.

### Function Listing

#### Constructors

 - **`Network`**`({::Symbol/::NPType}, nwkpar::Array[, z0=[::Real]])`: Constructs concrete network parameter matrix <: Network.
  - `Network(:S, [0 1; 1 0], z0=50)`: Construct S parameter network (z0=50 &Omega;).
  - `Network(NPType{:S}, [0 1; 1 0], z0=50)`: Construct S parameter network (z0=50 &Omega;).
  - ...

#### Traits (Utility functions for instances and types)

 - **`Symbol`**`(::NPType)`: Returns symbol value corresponding to an `NPType`.
 - **`eltype`**`(::NetworkParameters)`: Returns a network parameter matrix element type.
 - **`portcount`**`(::NetworkParameters)`: Returns the port count.

#### Conversion Routines

 - **`Network`**`({::Symbol/::NPType}, nwkpar::NetworkParameters[, z0=[::Real]])`: Performs network parameter matrix conversion.
  - `Network(:S, Z, z0=50)`: Convert Z &rArr; S parameter network (z0=50 &Omega;).
  - `Network(NPType{:S}, Z, z0=50)`: Convert Z &rArr; S parameter network (z0=50 &Omega;).
 - **`vector_push`**`(np::Vector{NetworkParameters})`: Converts `Vector{NetworkParameters{Number}}` &rArr; `NetworkParameters{Vector{Number}}`
 - **`vector_pull`**`(np::NetworkParameters{Vector})`: Converts `NetworkParameters{Vector{Number}}` &rArr; `Vector{NetworkParameters{Number}}`
 - **`submatrix`**`(np::{S/Y/Z}Parameters, ports::Vector{Int})`: Creates a network parameter matrix that is a subset of np.  Can also be used to re-order ports.

#### Other
 - **`series`**`({::Symbol/::NPType}, {::TImpedance/::TAdmittance})`: Returns a 2-port network parameter matrix representing the provided series impedance/admittance value.
 - **`shunt`**`({::Symbol/::NPType}, {::TImpedance/::TAdmittance})`: Returns a 2-port network parameter matrix representing the provided shunt impedance/admittance value.

<a name="SampleUsage"></a>
## Sample Usage

Examples of the NetwAnalysis.jl capabilities (+more) can be found under the [sample directory](sample/).

## Known Limitations

### Limited support

 1. Small library of functions.

### Compatibility

Extensive compatibility testing of NetwAnalysis.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-1.1.1 (64-bit)

## Disclaimer

The NetwAnalysis.jl module is not yet mature.  Expect significant changes.

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
