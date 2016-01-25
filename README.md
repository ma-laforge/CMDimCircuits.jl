# CircuitAnalysis.jl: Circuit Analysis Tools

## Description

The CircuitAnalysis.jl module provides tools to assist in circuit analysis.  The goal is to make the API simple, clear, and succinct.

The module includes:

 - Dispatchable "value tag" wrapper objects to identify values, and simplify API.
 - Unit conversion tools (V, I, W, V/V, I/I, W/W, dB, dBm, dBW).

NOTE: The API is not yet fully consistent.

### Principal Types

#### Value Tags (Not Exported)

 - **`TImpedance`**`{DATATYPE}`: Tags data as an impedance value (facilitates dispatch).
 - **`TAdmittance`**`{DATATYPE}`: Tags data as an admittance value (facilitates dispatch).
 - **`TInductance`**`{DATATYPE}`: Tags data as an inductance value (facilitates dispatch).
 - **`TCapacitance`**`{DATATYPE}`: Tags data as an capacitance value (facilitates dispatch).

### Function Listing

#### Constructors

**Value Tags**

 - **`impedance`**`(::Number)`: Creates a `TImpedance` tag to "type" the provided value.
 - **`admittance`**`(::Number)`: Creates a `TAdmittance` tag to "type" the provided value.
 - **`inductance`**`(::Number)`: Creates a `TInductance` tag to "type" the provided value.
 - **`capacitance`**`(::Number)`: Creates a `TCapacitance` tag to "type" the provided value.

#### Calculators

 - **`impedance`**`(...)`: Computes element impedance & returns `TImpedance` tagged value.
  - `impedance(::TCapacitance; f=[::Number/Vector/...])`: Computes `Zcap` @ given `f`.
  - `impedance(::TInductance; f=[::Number/Vector/...])`: Computes `Zind` @ given `f`.
 - **`admittance`**`(...)`: Computes element impedance & returns `TAdmittance` tagged value.
  - `admittance(::TCapacitance; f=[::Number/Vector/...])`: Computes `Ycap` @ given `f`.
  - `admittance(::TInductance; f=[::Number/Vector/...])`: Computes `Yind` @ given `f`.

#### Unit Conversion

 - **`dB20`**`(v)`: Returns `20*log10(|v|)`.
 - **`dB10`**`(v)`: Returns `10*log10(v)`.
 - **`dB`**`(v, u::Symbol)`, where u &isin; {:Wratio, :Vratio, :Iratio}
 - **`dBm`**`(v, u::Symbol)`, where u &isin; {:W, :VRMS, :Vpk}
 - **`dBW`**`(v, u::Symbol)`, where u &isin; {:W, :VRMS, :Vpk}
 - **`Vpk`**`(v, u::Symbol, R=[RESVAL])`, where u &isin; {:W, :VRMS}
 - **`Ipk`**`(v, u::Symbol, R=[RESVAL])`, where u &isin; {:W, :IRMS}
 - **`VRMS`**`(v, u::Symbol, R=[RESVAL])`, where u &isin; {:W, :Vpk}
 - **`IRMS`**`(v, u::Symbol, R=[RESVAL])`, where u &isin; {:W, :Ipk}

#### Traits (Utility functions for instances and types)

<a name="SampleUsage"></a>
## Sample Usage

Examples of the CircuitAnalysis.jl capabilities can be found under the [test directory](test/).

## Known Limitations

### Limited support

 1. Small library of functions.

### Compatibility

Extensive compatibility testing of CircuitAnalysis.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-0.4.0 (64-bit)

## Disclaimer

The CircuitAnalysis.jl module is not yet mature.  Expect significant changes.

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
