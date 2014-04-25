#tomoAuto
---
### About
tomoAuto is a Lua program to automate the alignment, correction and
recontstruction of cryo-electron tomography (Cryo-ET) data. Coupled with
high-throughput collection, tomoAuto drastically speeds up data processing so
that more time can be spent on data analysis.

tomoAuto is simply a script that handles the use of several popular software
packages in the field and simplifies their use in collection by globalizing the
command line calls and configurations. It has been running in some form or
fashion in our lab for the last 3 years with good results. It is a very rough
release and has many TODOs that have yet to be implemented.  
---

### Software used

**[IMOD](http://bio3d.colorado.edu/imod/)**

**[RAPTOR]
(http://fernandoamat.com/index.php?option=com_content&view=article&id=49:raptor&catid=38:bioimaging&Itemid=56)**

**[TOMO3D]
(https://sites.google.com/site/3demimageprocessing/software)**

----

### Credit and Acknowledgements
If you use this software please read the license file and use the software
appropriately. Also there are many papers to cite if you use this software in
your research. 

**IMOD:**

 Kremer J.R., D.N. Mastronarde and J.R. McIntosh (1996) Computer
visualization of three-dimensional image data using IMOD. J. Struct. Biol.
116:71-76. 

[PubMed](http://www.ncbi.nlm.nih.gov/pubmed/8742726)

Mastronarde, D. N. (1997) Dual-axis tomography: an approach with alignment 
methods that preserve resolution. J. Struct. Biol. 120:343-352.

[PubMed](http://www.ncbi.nlm.nih.gov/pubmed/9441937)

**Nonlinear Anisotropic Diffusion**

Frangakis, A., and Hegerl, R. (2001) Noise reduction in electron tomographic 
reconstructions using nonlinear anisotropic diffusion.
J. Struct. Biol. 135: 239-205

[PubMed](http://www.ncbi.nlm.nih.gov/pubmed/11722164)

**RAPTOR**

F. Amat, F. Moussavi,L.R. Comolli, G. Elidan, K.H. Downing, M. Horowitz (2008) 
"Markov random field based automatic image alignment for electron tomography". 
J. Struct. Biol. 161: 260-275

[PubMed](http://www.ncbi.nlm.nih.gov/pubmed/17855124)

**TOMO3D**

J.I. Agulleiro, J.J. Fernandez (2011) Fast tomographic reconstruction on
multicore computers. Bioinformatics 27:582–583.

[PubMed](http://www.ncbi.nlm.nih.gov/pubmed/21172911)

J.I. Agulleiro, E.M. Garzon, I. Garcia, J.J. Fernandez. (2010)
Vectorization with SIMD extensions speeds up reconstruction in electron
tomography. J. Struct. Biol. 170:570-575.

[PubMed](http://www.ncbi.nlm.nih.gov/pubmed/20085820)

JI Agulleiro, JJ Fernandez. (2012) Evaluation of a multicore-optimized
implementation for tomographic reconstruction. PLoS ONE  7(11):e48261.

[PubMed](http://www.ncbi.nlm.nih.gov/pubmed/23139768)

J.J. Fernandez, S. Li, R.A. Crowther (2006) CTF determination and correction in
electron cryotomography. Ultramicroscopy 106:587-596.

[PubMed](http://www.ncbi.nlm.nih.gov/pubmed/16616422)

J.J. Fernandez, S. Li, V. Lucic. (2007) Three-dimensional anisotropic noise
reduction with automated parameter tuning. Application to electron
cryotomography. Lecture Notes in Computer Science 4788:60-67.

J.J. Fernandez. (2009) TOMOBFLOW: Feature-preserving noise filtering for
electron tomography. BMC Bioinformatics 10:178.

[PubMed](http://www.ncbi.nlm.nih.gov/pubmed/19523199)
