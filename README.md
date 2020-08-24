# CMDimCircuits.jl: Process measurement/simulation results from parametric analyses

&mdash; ***"Focus on the analysis itself, not on data manipulation"***

[![Build Status](https://travis-ci.org/ma-laforge/CMDimCircuits.jl.svg?branch=master)](https://travis-ci.org/ma-laforge/CMDimCircuits.jl)

:art: [**Galleries (sample output)**](https://github.com/ma-laforge/FileRepo/blob/master/SignalProcessing/sampleplots/README.md)
/ [:chart_with_upwards_trend: InspectDR.jl samples](https://github.com/ma-laforge/FileRepo/tree/master/InspectDR/sampleplots/README.md)
:art:

| <img src="https://github.com/ma-laforge/FileRepo/blob/master/InspectDR/sampleplots/demo11.png" width="425"> | <img src="https://github.com/ma-laforge/FileRepo/blob/master/InspectDR/sampleplots/demo2.png" width="425"> |
| :---: | :---: |

| <img src="https://github.com/ma-laforge/FileRepo/blob/master/SignalProcessing/sampleplots/demo15.png" width="850"> |
| :---: |

## Description

`CMDimCircuits.jl` provides an *environment* (a set of tools) to efficiently
post-process and analyze results from circuit measurement & simulation:
 - `[MDDatasets.jl](https://github.com/ma-laforge/MDDatasets.jl)`: Easily handle "parametric analysis" data using a simple, multi-dimensional container, and provide `struct DataF1` to represent `{x,y}` vectors as a continuous function of 1 argument: `y=f(x)`.
 - `[CMDimData.jl](https://github.com/ma-laforge/CMDimData.jl)/EasyPlot`: Easily plot "parametric analysis" data using a backend of your choosing.
 - `[CMDimData.jl](https://github.com/ma-laforge/CMDimData.jl)/EasyData`: Easily *save* "parametric analysis" data to a single .hdf5 file.
 - Various EDA file readers/writers.

More specifically, the goal is to provide an analysis framework leading to
minimal code, written in a *natural*, and *readable* fashion.  The following
describes a typical workflow enabled by this package:

 1. Read in complex multi-dimensional input data from measurement/simulation results.
 1. Treat transient datasets as continuous-time (automatically interpolate when time steps are mismatched).
 1. Perform the same operation on all parametric sweeps (usually) without having to write explicit loops.
 1. Quickly generate plots that shed light on the studied phenomenon.
    1. Select from a multitude of plotting backends (possibly at a later date).
 1. Save both data & plot configuration to a single .hdf5 file.
    1. Reload plot & data for further investigation at a later time.

### Features/Highlights

 - Support for popular EDA file formats: (.tr0, .psf, .sNp).
 - Plot the results of multi-dimensional parametric analyses with a single command.
   - Support for multiple plotting backends ([see CMDimData.jl for more details](https://github.com/ma-laforge/CMDimData.jl)).
   - Generate eye diagrams (even for backends without native support).
   - Generate Smith Plots ([InspectDR backend only](https://github.com/ma-laforge/InspectDR.jl)).
   - Read/write plots to .hdf5 files.

## Table of Contents

 1. [`CMDimCircuits.EDAData`: Accessing EDA data files](doc/EDAData.md)
 1. [`CMDimCircuits.CircuitAnalysis`: Circuit Analysis Tools](doc/CircuitAnalysis.md)
 1. [`CMDimCircuits.NetwAnalysis`: Network Analysis Tools](doc/NetwAnalysis.md)
 1. [`CMDimCircuits.SignalProcessing`: {T&hArr;F}-Domain Analysis Tools](doc/SignalProcessing.md)
 1. [Activating the "C-Data" environment](#ActivatingCData)
 1. [Installation](#Installation)
 1. [Sample Usage](#SampleUsage)

<a name="ActivatingCData"></a>
## Activating the "C-Data" environment

The "C-Data" environment provides a collection of tools to generate/process
parametric analysis data & better visualize (see) mathematical relationships
buried within.  To activate C-Data, you must call the `@using_CData` macro:

```julia
using CMDimCircuits
CMDimCircuits.@using_CData
```

Note that `CMDimCircuits.@using_CData` imports the following modules to your scope:
```julia
using MDDatasets
using CMDimData
using CMDimData.EasyPlot
using CMDimCircuits.CircuitAnalysis
using CMDimCircuits.NetwAnalysis
using CMDimCircuits.SignalProcessing
using CMDimCircuits.EDAData
```

Note that no plotting backend was imported. You must therefore "import" your
preferred plotting library using the procedure
[described here](https://github.com/ma-laforge/CMDimData.jl/blob/master/doc/EasyPlot_backends.md#ImportingBackends).

<a name="Installation"></a>
## Installation

`CMDimCircuits.jl` is registered with Julia's **General** registry.
It can be installed using Julia's built-in package manager:

```julia
]add CMDimData.jl
```

It is also highly suggested that you install InspectDR.jl for plotting.

```julia
]add InspectDR
```

<a name="SampleUsage"></a>
## Sample Usage
Examples of how to use `CMDimCircuits.jl` are provided in the [sample/](sample) subdirectory.

A few examples are organized by module:
 - Use of `CMDimCircuits.NetwAnalysis`: [sample/NetwAnalysis/](sample/NetwAnalysis)
 - Use of `CMDimCircuits.SignalProcessing`: [sample/SignalProcessing/](sample/SignalProcessing)

:art: **Galleries:** [:satellite: sample/SignalProcessing/ output](https://github.com/ma-laforge/FileRepo/tree/master/SignalProcessing/sampleplots/README.md) (might be out of date).

## Usage Tips

### Querying Different Method Signatures

In Julia, a good way to see the methods available for a particular function is to run:

		julia> methods([FUNCTION_NAME])

Given the multitude of optional/keyword agruments in some functions, it is
currently best to take a look at the samples provided [above](#SampleUsage).

## Known Limitations

### [TODO](TODO.md)

### Compatibility

Extensive compatibility testing of the CMDimCircuits.jl package has not been
performed.  It has been tested in the following environment(s):

 - Windows 10 / Linux / Julia-1.3.1

## Disclaimer

The CMDimCircuits.jl package is not yet mature.  Expect significant changes.
