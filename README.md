Cue-distractor package
======================

Essentials
----------

- a detailed **documentation** of this package can be found [here](https://github.com/murtex/cdp/blob/master/doc/cdp.pdf "package documentation") (download as [PDF](https://github.com/murtex/cdp/raw/master/doc/cdp.pdf "package documentation"))
- each directory of this package also comes up with a (more or less) descriptive **README** file outlining what is inside
- directories starting with a plus sign (+) contain MATLAB code and are used as **namespaces** to subdivide the package structure (see [Packages Create Namespaces](https://www.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html "MATLAB documentation") on how to handle them)
- other directories may contain MATLAB code, shell scripts, latex, or even binary data files
- the package itself needs to be on the MATLAB **search path** in order to use its functionality (refer to [addpath](https://www.mathworks.com/help/matlab/ref/addpath.html "MATLAB documentation") on how to achieve this)

Framework
---------

- a very **first start** could be a visit to the [`cdf`](https://github.com/murtex/cdp/tree/master/%2Bcdf "cdf") submodule
- that module provides **high-level** structures and functionality to get [Psychtoolbox](http://psychtoolbox.org/ "Psychtoolbox")-styled data conveniently processed (but is not exclusively dependent on that format)
- more fundamental, **low-level** functions are given by the modules [`dsp`](https://github.com/murtex/cdp/tree/master/%2Bdsp "dsp") (Digital signal processing) and [`sta`](https://github.com/murtex/cdp/tree/master/%2Bsta "sta") (Short-time analysis)
- these two modules rely only on the basic notion of (multi-dimensional) time series
- command and progress **logging**, uniform and coherent **plotting** are parts of the [`xis`](https://github.com/murtex/cdp/tree/master/%2Bxis "xis") submodule

Applications
------------

- the [klein]()-application, as the **refrence application**, TODO...

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

