Cue-distractor package
======================

Essentials
----------

- a detailed **documentation** of this package can be found [here](https://github.com/murtex/cdp/blob/master/doc/cdp.pdf "package documentation") (download as [PDF](https://github.com/murtex/cdp/raw/master/doc/cdp.pdf "package documentation"))
- each directory of this package also comes up with a (more or less) descriptive **README** file outlining what is inside (actually you are now reading one of these)
- directories starting with a plus (+) sign contain MATLAB source codes and are used as **namespaces** to subdivide the package structure (see [Packages Create Namespaces](https://www.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html "MATLAB documentation") for how to use them)
- other directories may contain MATLAB code, shell scripts, latex, or even binary data files
- the package itself needs to be on the MATLAB **search path** in order to use its functionality (refer to [addpath](https://www.mathworks.com/help/matlab/ref/addpath.html "MATLAB documentation") on how to achieve this)

Framework
---------

- a very first **starting point** should be the [`cdf`](https://github.com/murtex/cdp/tree/master/%2Bcdf "cdf") submodule
- this module provides **high-level** structures and functions to get experimental data processed

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

