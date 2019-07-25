# :art: Galleries (Sample Output) :art:

[:satellite: SignalProcessing.jl](https://github.com/ma-laforge/FileRepo/tree/master/SignalProcessing/sampleplots/README.md) (might be out of date).

# SignalProcessing.jl: {T&hArr;F}-Domain Analysis Tools

| <img src="https://github.com/ma-laforge/FileRepo/blob/master/SignalProcessing/sampleplots/demo15.png" width="850"> |
| :---: |

| <img src="https://github.com/ma-laforge/FileRepo/blob/master/SignalProcessing/sampleplots/demo1.png" width="425"> | <img src="https://github.com/ma-laforge/FileRepo/blob/master/SignalProcessing/sampleplots/demo17.png" width="425"> |
| :---: | :---: |

## Description

### Principal Types

- **`DataTime`**: Represents a time-domain signal, x(t), with a constant time step.
- **`DataFreq`**: Represents a frequency-domain signal, x(t), with a constant frequency step.
- **`DataHR{DataTime/DataFreq}`**: A collection of data with hyper-rectangular organization.
- **`Pole(v, :rad/:Hz)`**: Creates a pole object, in rad/s or Hz.
- **`Index(v)`**: Creates an index value (identifies a number as an integer-valued index, or span).


### Function Listing

#### Frequency Domain

- **`timespace`**`(::Symbol, ::Number, ::Symbol, ::Number)`: Generates a range representing time.
  - `timespace(:ts, [SAMPLING_PERIOD], :tfund, [PERIOD_OF_FUNDAMENTAL])`: Guarantees accuracy of `ts` & verifies `tfund`.
  - `timespace(:tfund, [PERIOD_OF_FUNDAMENTAL], :ts, [SAMPLING_PERIOD])`: Targets a value of `tfund` & verifies applicability of `ts`.
- **`timedomain`**`(::DataFreq)`: Returns a `DataTime` (performs `ifft()`, if necessary).
- **`step`**`()`: Generates a step response.
  - `step(reftime::DataTime, [::Pole,] ndel::Index=[DELAY_TSTEPS], amp=[AMPLITUDE])`: Discrete time (drop `::Pole` to get ideal response).
  - `step(reftime::DataF1, ::Pole, tdel=[DELAY_TIME], amp=[AMPLITUDE])`: Continuous time.
- **`pulse`**`()`: Generates a pulse response.
  - `pulse(reftime::DataTime, [::Pole,] ndel::Index=[DELAY_TSTEPS], amp=[AMPLITUDE], tpw::Index=[PULSE_WIDTH])`: Discrete time (drop `::Pole` to get ideal response).
  - `pulse(reftime::DataF1, ::Pole, tdel=[DELAY_TIME], amp=[AMPLITUDE], tpw=[PULSE_WIDTH])`: Continuous time.
- **`prbs`**`(reglen=[LFSR_REG_LEN], seed=[SEED], nsamples=[NUM_OUTPUT_SAMPLES])`: Generates PRBS sequence.
- **`pattern`**`()`: Generates pattern from a bit sequence
  - `pattern(seq::Vector, pulseresp::DataTime, nbit::Index=[TSTEPS_PER_BIT_PERIOD])`: Discrete time
  - `pattern(seq::{Vector/DataF1}, pulseresp::DataF1, tbit::Index=[BIT_PERIOD])`: Continuous time
- **`datavec`**`(::Symbol, ::DataMD)`: Accessor for a base vector
  - `datavec(:time, ::{DataTime/DataFreq})`: Returns the time vector
  - `datavec(:freq, ::{DataTime/DataFreq})`: Returns the frequency vector
  - `datavec(:sig, ::DataTime)`: Returns the signal vector (x(t))
  - `datavec(:sig, ::DataFreq)`: Returns the signal vector (X(f))

#### Time Domain

- **`freqdomain`**`(::DataTime)`: Returns a `DataFreq` (performs `fft()`, if necessary)
- **`fspectrum`**`(::DataFreq)`: Returns sampled frequency spectrum (non-periodic signals).
- **`fcoeff`**`(::DataFreq)`: Returns Fourier-series coefficients (time-periodic signals).

#### Querying Different Method Signatures

In Julia, a good way to see the methods available for a particular function is to run:

		julia> methods([FUNCTION_NAME])

Given the multitude of optional/keyword agruments in some functions, it is currently best to take a look at the samples provided [below](#SampleUsage).

<a name="SampleUsage"></a>
## Sample Usage

Examples of the SignalProcessing.jl capabilities (+more) can be found under the [sample directory](sample/).

:art: **Galleries:** [:satellite: SignalProcessing.jl](https://github.com/ma-laforge/FileRepo/tree/master/SignalProcessing/sampleplots/README.md) (might be out of date).

<a name="Installation"></a>
## Installation

SignalProcessing.jl is part of the [CData](https://github.com/ma-laforge/CData.jl) analysis/visualization suite.  The installation process is described [here](https://github.com/ma-laforge/CData.jl#installation).

## Known Limitations

### Limited support

1. Small library of functions.
1. Limited support for broadcasting functions over `DataHR{DataTime/DataFreq}` vectors.

### Compatibility

Extensive compatibility testing of SignalProcessing.jl has not been performed.  The module has been tested using the following environment(s):

- Linux / Julia-1.1.1 (64-bit)

## Disclaimer

The SignalProcessing.jl module is not yet mature.  Expect significant changes.

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
