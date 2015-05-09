Cue-distractor package
======================

- this package is split into parts: applications, framework, and others
- applications are a good starting point for seeing how to make use of the framework

Applications
------------

- applications are collections of scripts which have to be executed in order
- to get any script ran, you have to add *this* directory to your MATLAB search path
- [`klein`](https://github.com/murtex/cdp/tree/master/klein) is *the* reference application, means it is a complete showcase of framwork functionality
- [`eyetrack`](https://github.com/murtex/cdp/tree/master/eyetrack) handles same type of data, but without any labeling/annotations
- [`dists`](https://github.com/murtex/cdp/tree/master/dists) contains minor scripts of how to modify distractors

Framework
---------

- as already said: *this* directory needs to be on your MATLAB search path
- the framework functionality is split into several namespaces (indicated by a plus sign)
- [`+cdf`](https://github.com/murtex/cdp/tree/master/%2Bcdf) contains *everything* you need to get your data being processed
- [`+cdf/+plot`](https://github.com/murtex/cdp/tree/master/%2Bcdf/%2Bplot) comes up with functionality for testing and debugging
- remaining namespaces like [`+k15`](https://github.com/murtex/cdp/tree/master/%2Bk15), [`+brf`](https://github.com/murtex/cdp/tree/master/%2Bbrf), etc. contain low-level functions

Other
-----

- [`doc`](https://github.com/murtex/cdp/tree/master/doc) contains sources of the (too rarely updated) documentation of this package ([PDF](https://github.com/murtex/cdp/raw/master/doc/cdp.pdf))
- [`data`](TODO) TODO: provide some basic data, plots? at least classifiers?!

