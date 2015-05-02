Cue-distractor package
======================

Essentials
----------

- a detailed **documentation** of this package can be found [here](https://github.com/murtex/cdp/blob/master/doc/cdp.pdf "package documentation") (download as [PDF](https://github.com/murtex/cdp/raw/master/doc/cdp.pdf "package documentation")) /currently ONLY A DRAFT)
- each directory of this package also comes up with a (more or less) descriptive **README** file outlining what is inside (actually you are now reading one of these)
- directories starting with a plus (+) sign contain MATLAB code and are used as **namespaces** to subdivide the package structure (see [Packages Create Namespaces](https://www.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html "MATLAB documentation") on how to handle them)
- other directories may contain MATLAB code, shell scripts, latex, or even binary data files
- the package itself needs to be on the MATLAB **search path** in order to use its functionality (refer to [addpath](https://www.mathworks.com/help/matlab/ref/addpath.html "MATLAB documentation") on how to achieve this)

Framework
---------

- the very **first start** should be a visit to the [`cdf`](https://github.com/murtex/cdp/tree/master/%2Bcdf "cdf") submodule
- that module provides **high-level** structures and functions to easily get [Psychtoolbox](http://psychtoolbox.org/ "Psychtoolbox")-styled data processed, but is not exclusively dependent on that format
- fundamental, **low-level** functionality is given by the modules [`dsp`](https://github.com/murtex/cdp/tree/master/%2Bdsp "dsp") (Digital signal processing) and [`sta`](https://github.com/murtex/cdp/tree/master/%2Bsta "sta") (Short-time analysis), both modules only rely on the concept of (multi-dimensional) **time series**
- for process logging and coherent plots consider using parts of the [`xis`](https://github.com/murtex/cdp/tree/master/%2Bxis "xis") module

Applications
------------

Data
----

Modules/Namespaces
------------------

- `cdf`: cue-distractor framework
- `dsp`: digital signal processing
- `k15`: landmark detection
- `sta`: short-time analysis
- `xis`: convenience functionality
- `klein`: reference application
- `dists`: distractor modification

