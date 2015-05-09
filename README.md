Cue-distractor package
======================

- this package is split into parts: applications, framework, and others
- applications are a good starting point for seeing how to make use the framework

Applications
------------

- applications are collections of scripts which have to be executed in order
- to get any script ran, you have to add *this* directory to your MATLAB search path
- `klein` is *the* reference application, means it is a complete showcase of framwork functionality
- `eyetrack` handles same type of data, but without any labeling/annotations
- `dists` contains minor scripts of how to modify distractors

Framework
---------

- as already said: *this* directory needs to be on your MATLAB search path
- the framework functionality is split into several namespaces (indicated by a plus sign)
- `+cdf` contains *everything* you need to get your data being processed
- `+cdf/+plot` comes up with functionality for testing and debugging
- remaining namespaces like `+sta`, `+k15`, etc. contain low-level functions

Other
-----

- `doc` contains the sources of the (too rarely updated) documentation of this package (download its PDF here)
- `data` TODO: provide some basic data, plots? at least classifier?!

