Cue-distractor package
======================

- this package is divided into parts: applications ([`apps`](#apps)), framework ([`cdp`](#cdp)) and documentation ([`doc`](https://github.com/murtex/cdp/tree/maria/doc))
- applications are a good starting point to see how to make use of the framework
- the full (but sadly not too very often updated) documentation of this package can be found [here](https://github.com/murtex/cdp/blob/maria/doc/cdp.pdf) (use the 'Raw' button there to download the PDF)

<a name="apps"></a>
Applications
------------

- each application is a collection of scripts (not only Matlab) solving specific tasks of its whole purpose
- so far there are
  - [`klein`](https://github.com/murtex/cdp/tree/maria/apps/klein) as *the* reference application for the entire framework
  - [`eyetrack`](https://github.com/murtex/cdp/tree/maria/apps/eyetrack) as a subset of `klein` having no labeled data available
  - [`cdd`](https://github.com/murtex/cdp/tree/maria/apps/cdd) being similar to `eyetrack`
  - [`distmod`](https://github.com/murtex/cdp/tree/maria/apps/distmod) containing some minor scripts of how to modify distractors
- please follow the given links above for more detailed decription and documentation

<a name="cdp"></a>
Framework
---------

- the framework ([`cdp`](https://github.com/murtex/cdp/tree/maria/cdp)) contains scripts for core functionality
- its essentials are
  - data structures ([`+cdf`](https://github.com/murtex/cdp/tree/maria/cdp/%2Bcdf))
  - signal processing ([`+dsp`](https://github.com/murtex/cdp/tree/maria/cdp/%2Bdsp), [+sta](https://github.com/murtex/cdp/tree/maria/cdp/%2Bsta)), 
  - landmark detection ([+k15](https://github.com/murtex/cdp/tree/maria/cdp/%2Bk15))
  - label classification ([+brf](https://github.com/murtex/cdp/tree/maria/cdp/%2Bbrf))
  - logging and plotting helpers ([+xis](https://github.com/murtex/cdp/tree/maria/cdp/%2Bxis), [+cdf/+plot](https://github.com/murtex/cdp/tree/maria/cdp/%2Bcdf/%2Bplot))
- if you are interested in how things work behind the curtain please follow these links
