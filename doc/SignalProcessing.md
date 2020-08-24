# CMDimCircuits.SignalProcessing: {T&hArr;F}-Domain Analysis Tools

| <img src="https://github.com/ma-laforge/FileRepo/blob/master/SignalProcessing/sampleplots/demo15.png" width="850"> |
| :---: |

| <img src="https://github.com/ma-laforge/FileRepo/blob/master/SignalProcessing/sampleplots/demo1.png" width="425"> | <img src="https://github.com/ma-laforge/FileRepo/blob/master/SignalProcessing/sampleplots/demo17.png" width="425"> |
| :---: | :---: |

## Principal Types

 - **`DataTime`**: Represents a time-domain signal, x(t), with a constant time step.
 - **`DataFreq`**: Represents a frequency-domain signal, x(t), with a constant frequency step.
 - **`DataHR{DataTime/DataFreq}`**: A collection of data with hyper-rectangular organization.
 - **`Pole(v, :rad/:Hz)`**: Creates a pole object, in rad/s or Hz.
 - **`Index(v)`**: Creates an index value (identifies a number as an integer-valued index, or span).

### More on: `DataTime`/`DataFreq`/(`DataTF`)
`DataTime` & `DataFreq` are merely wrapper objects pointing to `DataTF` for dispatch purposes.

 - The idea is that `DataTF` initially stores *either* time or frequency information for the signal.
 - Later, when it is required, the complementary information is lazily generated in `DataTF`.

Thus, the structure of `DataTF` ensures the `fft`/`ifft` of a signal does not have to be called more than once.

NOTE:
 - `DataTime`/`DataFreq` signals only support constant time/frequency steps.
 - `DataTime`/`DataFreq` signals can be tagged as either time-periodic, or aperiodic.
   - Depending on the case, proper scaling will be used to represent either the Fourier series coefficients (`fcoeff`), or a sampling of the frequency spectrum (`fspectrum`).

## Function Listing

### Frequency Domain

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
- **`pattern`**`()`: Generates pattern from a bit sequence.
  - `pattern(seq::Vector, pulseresp::DataTime, nbit::Index=[TSTEPS_PER_BIT_PERIOD])`: Discrete time.
  - `pattern(seq::{Vector/DataF1}, pulseresp::DataF1, tbit::Index=[BIT_PERIOD])`: Continuous time.
- **`datavec`**`(::Symbol, ::DataMD)`: Accessor for a base vector.
  - `datavec(:time, ::{DataTime/DataFreq})`: Returns the time vector.
  - `datavec(:freq, ::{DataTime/DataFreq})`: Returns the frequency vector.
  - `datavec(:sig, ::DataTime)`: Returns the signal vector (`x(t)`).
  - `datavec(:sig, ::DataFreq)`: Returns the signal vector (`X(f)`).

### Time Domain

- **`freqdomain`**`(::DataTime)`: Returns a `DataFreq` (performs `fft()`, if necessary)
- **`fspectrum`**`(::DataFreq)`: Returns sampled frequency spectrum (non-periodic signals).
- **`fcoeff`**`(::DataFreq)`: Returns Fourier-series coefficients (time-periodic signals).

## Known Limitations

1. Limited support for broadcasting functions over `DataHR{DataTime/DataFreq}` vectors.
