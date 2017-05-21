# SignalProcessing.jl: {T&hArr;F}-Domain Analysis Tools

[Sample Results](https://github.com/ma-laforge/FileRepo/tree/master/SignalProcessing/sampleplots/README.md) (might be out of date).

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

### Sample Output Gallery

Outputs of said examples, as generated with the EasyPlotGrace.jl module, can be viewed in the [SignalProcessing Gallery](https://github.com/ma-laforge/FileRepo/tree/master/SignalProcessing/sampleplots).

Please note that the plots are likely out of date.

## Known Limitations

### Limited support

 1. Small library of functions.
 1. Limited support for broadcasting functions over `DataHR{DataTime/DataFreq}` vectors.

### Compatibility

Extensive compatibility testing of SignalProcessing.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-0.6.0-rc1 (64-bit)

## Disclaimer

The SignalProcessing.jl module is not yet mature.  Expect significant changes.

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
