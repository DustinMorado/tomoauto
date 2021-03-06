#tomoauto
## Version 0.2.30
### About
tomoauto is a wrapper-library written in Lua to automate the alignment,
correction and recontstruction of cryo-electron tomography (Cryo-ET)
tilt-series. Coupled with high-throughput collection, tomoauto
speeds up data processing so that more time can be spent on data analysis.

tomoauto is simply a script that handles the use of several popular software
packages in the field and simplifies their use in collection by globalizing the
command line calls and configuration. It has been running in some form or
fashion in our lab for the last 3 years with good results.

Recent releases have expanded the original functionality to handle direct
detector cameras, dose-fractionation, and more complex operations on MRC files.

### Change Log
#### 0.2.30
 * A really big overhaul that reorganized most of the libraries.
 * mrcio.lua is now handled in an object oriented manner to make interactive
   user use more friendly.
 * Settings have been broken up and placed in their own folder to make editing
   global configuration more easy, and it is now also in a standard format using
   lua tables to make the syntax a little easier to remember and read.
 * Every option for every command handled by tomoauto is now in the settings.
 * Added mdoc support, hopefully in the future we will move to just handling
   mdocs and not MRC files or logs for `dose_fractioned_to_stack`.
 * Added some transform routines, they're not in use right now but will be used
   later on to do some conversions from I3 to dynamo in terms of orientations
   and such.

#### 0.2.20
 * Update for Lua 5.3.0 release
 * Added a CTF test-suite comparing CTFFIND4 and CTFPLOTTER
 * Added programs to handle motion-correction with MOTIONCORR
 * No longer need struct library
 * bit32 library was deprecated and therefore removed

#### 0.2.15
 * Wrote a new installation script and packaged with sources for lua and needed
   Lua libraries.

#### 0.2.10
 * Changed final files kept to save space and rely on options available in 3dmod
 * As of IMOD 4.7.9 autofidseed works better than RAPTOR to generate the
   fiducial seed model and is now default. RAPTOR can still be used by passing
   the appropriate option (see tomoauto --help).

#### 0.2.0
 * Added mode option to stop at alignment, ccderase, or to only perform
   reconstruction
 * Stopped using RAPTOR to generate the alignment, now it only produces the
   fiducial seed model and then IMOD performs the alignment.
 * No longer using a folder with the basename which helps keep things clean and
   organized when using the align and then the reconstruct mode.
 * Removed all batch commands, handle them yourself with the shell.
 * Added programs to create a newstack from drift-corrected images collected by
   dose-fractionation.
 * Added a pretty substantial lua module to handle MRC files.
 * Most of the IMOD commands handle multi-core automatically so removed -p
   option.

---

### Software used

**[IMOD](http://bio3d.colorado.edu/imod/)**

**[RAPTOR]
(http://fernandoamat.com/index.php?option=com_content&view=article&id=49:raptor&catid=38:bioimaging&Itemid=56)**

**[TOMO3D]
(https://sites.google.com/site/3demimageprocessing/software)**

**[CTFFIND4]
(http://grigoriefflab.janelia.org/ctffind4)**

**[MOTIONCORR]
(http://cryoem.ucsf.edu/software/driftcorr.html)**

----

### Credit and Acknowledgements
If you use this software please read the license file and use the software
appropriately. Also there are many papers to cite if you use this software in
your research.

**IMOD:**

 Kremer J.R., D.N. Mastronarde and J.R. McIntosh (1996) Computer
visualization of three-dimensional image data using IMOD. J. Struct. Biol.
116:71-76.

[10.1006/jsbi.1996.0013](http://dx.doi.org/10.1006/jsbi.1996.0013)

Mastronarde, D. N. (1997) Dual-axis tomography: an approach with alignment
methods that preserve resolution. J. Struct. Biol. 120:343-352.

[10.1006/jsbi.1997.3919](http://dx.doi.org/10.1006/jsbi.1997.3919)

**RAPTOR**

F. Amat, F. Moussavi,L.R. Comolli, G. Elidan, K.H. Downing, M. Horowitz (2008)
"Markov random field based automatic image alignment for electron tomography".
J. Struct. Biol. 161: 260-275

[10.1016/j.jsb.2007.07.007](http://dx.doi.org/10.1016/j.jsb.2007.07.007)

**TOMO3D**

J.I. Agulleiro, J.J. Fernandez (2011) Fast tomographic reconstruction on
multicore computers. Bioinformatics 27:582–583.

[10.1093/bioinformatics/btq692](http://dx.doi.org/10.1093/bioinformatics/btq692)

J.I. Agulleiro, E.M. Garzon, I. Garcia, J.J. Fernandez. (2010)
Vectorization with SIMD extensions speeds up reconstruction in electron
tomography. J. Struct. Biol. 170:570-575.

[10.1016/j.jsb.2010.01.008](http://dx.doi.org/10.1016/j.jsb.2010.01.008)

J.I. Agulleiro, J.J. Fernandez. (2012) Evaluation of a multicore-optimized
implementation for tomographic reconstruction. PLoS ONE  7(11):e48261.

[10.1371/journal.pone.0048261](http://dx.doi.org/10.1371/journal.pone.0048261)

**CTFFIND4**

J.A. Mindell, N. Grigorieff. (2003) Accurate determination of local defocus and
specimen tilt in electron microscopy. J. Struct. Biol. 142(3):334-47.

[doi:10.1016/S1047-8477(03)00069-8](http://dx.doi.org/10.1016/S1047-8477(03)00069-8)

**MOTIONCORR**

X. Li, et al. (2013) Electron counting and beam-induced motion correction enable
near-atomic-resolution single-particle cryo-EM. Nat. Methods 10(6):584-90.

[doi: 10.1038/nmeth.2472](http://dx.doi.org/doi: 10.1038/nmeth.2472)

----

### Installation
See INSTALL file. Place the tomoauto directory where you want to install it and
in that directory run install_tomoauto.sh.
