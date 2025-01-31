# ECE-GY 6023.  Introduction to Wireless Communications

This repository provides instructional material for the
graduate wireless communications, ECE-GY 6023, at New York University
taught by [Sundeep Rangan](http://wireless.engineering.nyu.edu/sundeep-rangan/):

Anyone is free to use and copy this material (at their own risk!).
But, please cite the material if you use the material in your own class.

## Pre-requisites

The course assumes you are familiar with digital communications at the graduate level.  There are many resources for digital communications, including some lecture notes I created for the [NYU class](https://github.com/sdrangan/digitalcomm).

Additionally, some lecture notes (and problems to be added later) assume you have access to MATLAB along with the communications, phased array and antenna toolboxes.


## SDR Labs
I am starting to add software-defined radio (SDR) labs.  The labs are based on the
simple, but powerful [ADALM-Pluto boards](https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/adalm-pluto.html).
The SDRs were used for the [digital communications class](https://github.com/sdrangan/digitalcomm) and you can look there for introductory material.


## Nvidia Sionna 
[Sionna](https://nvlabs.github.io/sionna/) is a fully open-source Tensorflow-based package developed by Nvidia to support physical layer wireless experiments.
While it does not have the full functionality of MATLAB's toolboxes, it offers integration with python and Tensorflow for machine learning experiments along
with ray tracing.  We are starting to use it for some labs and demos.

## Feedback

Any feedback is welcome.  If you find errors, have ideas for improvements,
or want to voice any other thoughts, [create an issue](https://help.github.com/articles/creating-an-issue/)
and we will try to get to it.
Even better, fork the repository, make the changes yourself and
[create a pull request](https://help.github.com/articles/about-pull-requests/)
and we will try to merge it in.  See the [excellent instructions](https://github.com/ishjain/learnGithub/blob/master/updateMLrepo.md)
from the former TA Ish Jain.


## Lecture Sequence
The tentative plan for the lectures are below. The material is continuously evoloving. 

You can access the MATLAB Live Scripts with [![MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=sdrangan/wirelesscomm).

* Course Introduction
    * Lecture: [[PDF]](./lectures/CourseAdmin.pdf) [[PPT]](./lectures/CourseAdmin.pptx) 
    * Lecture video:  [[YouTube]](https://youtu.be/DZLp12GCHow)
* Unit 1.  Basics of Antennas and Free-space Propagation 
    * Lecture: [[PDF]](./lectures/Unit01_Antennas.pdf) [[PPT]](./lectures/Unit01_Antennas.pptx) 
    * [Lecture videos](./unit01_antennas/readme.md) and in-class exercises
    * Demo: Calculating and displaying antenna patterns [[PDF]](./unit01_antennas/demo_antennas.pdf) [[Matlab]](./unit01_antennas/demo_antennas.m)
    * Demo: 3GPP 5G antenna model [[PDF]](./unit01_antennas/demo_3gpp_antenna.pdf) [[Matlab live]](./unit01_antennas/demo_3gpp_antenna.m)
    * Demo: Spherical coordiantes and rotation matrices [[PDF]](./unit01_antennas/rotation.pdf) [[Matlab live]](./unit01_antennas/demo_3gpp_antenna.m)
    * Sionna demo: Free-space propagation with Nvidia Sionna [[ipynb]](./unit01_antennas/demo_sionna_free_space.ipynb)
      <a target="_blank" href="https://colab.research.google.com/github/sdrangan/wirelesscomm/blob/master/unit01_antennas/demo_sionna_free_space.ipynb">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/></a>
    * Problems:  [[PDF]](./unit01_antennas/prob/prob_antennas.pdf) [[Latex]](./unit01_antennas/prob/prob_antennas.tex)
    * Lab:  Simulating a 28 GHz antenna for a UAV 
        * [[Matlab Live version]](./unit01_antennas/lab_uav_antenna.mlx) [![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=sdrangan/wirelesscomm&file=unit01_antennas/lab_uav_antenna.mlx)
        * [[Sionna version]](./unit01_antennas/lab_uav_antenna_sb.ipynb) <a target="_blank" href="https://colab.research.google.com/github/sdrangan/wirelesscomm/blob/master/unit01_antennas/lab_uav_antenna_sn.ipynb">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/></a>
* Unit 2.  Non-LOS Propagation and Link-Budget Analysis 
    * Lecture: [[PDF]](./lectures/Unit02_Propagation.pdf) [[PPT]](./lectures/Unit02_Propagation.pptx) 
    * [Lecture videos](./unit02_propagation/readme.md) and in-class exercises
    * Demo: Simulating AWGN Noise [[PDF]](./unit02_propagation/demo_awgn.pdf) [[Matlab Live]](./unit02_propagation/demo_awgn.mlx)
    * Demo: Propagation and rate modeling [[PDF]](./unit02_propagation/demo_path_loss_model.pdf) [[Matlab]](./unit02_propagation/demo_path_loss_model.m)
    * Problems:  [[PDF]](./unit02_propagation/prob/prob_propagation.pdf) [[Latex]](./unit02_propagation/prob/prob_propagation.tex)
    * Lab:  Propagation modeling from ray tracing data [[PDF]](./unit02_propagation/lab_prop_modeling.pdf) [[Matlab Live]](./unit02_propagation/lab_prop_modeling.mlx)
* Unit 3.  Multipath Fading
    * Lecture: [[PDF]](./lectures/Unit03_Fading.pdf) [[PPT]](./lectures/Unit03_Fading.pptx) 
    * [Lecture videos](./unit03_fading/readme.md) and in-class exercises
    * Demo: Simulating fading [[PDF]](./unit03_fading/demo_fading.pdf) [[Matlab Live]](./fading/unit03_demo_fading.mlx)
    * Problems:  [[PDF]](./unit03_fading/prob/prob_fading.pdf) [[Latex]](./unit03_fading/prob/prob_fading.tex)
    * Lab with SDR:  Simulating multipath fading [[Directory]](./unit03_fading/partial) 
* Unit 4.  Capacity and Coding on Fading Channels
    * Lecture: [[PDF]](./lectures/Unit04_Coding.pdf) [[PPT]](./lectures/Unit04_Fading.pptx) 
    * [Lecture videos](./unit04_coding/readme.md) and in-class exercises
    * Demo: Uncoded BER on fading channel [[PDF]](./unit04_coding/demo_uncoded.pdf) [[Matlab Live]](./unit04_coding/demo_uncoded.mlx)
    * Demo: Convolutional coding on a fading channel[[PDF]](./unit04_coding/demo_conv.pdf) [[Matlab Live]](./unit04_coding/demo_conv.mlx)
    * Lab:  5G NR Downlink Throughput with Fading and LDPC coding [[PDF]](./unit04_coding/lab_partial/labPdsch.pdf) [[Matlab Live]](./unit04_coding/lab_partial/labPdsch.mlx)
    * Problems:  [[PDF]](./unit04_coding/prob/prob_coding.pdf) [[Latex]](./unit04_coding/prob/prob_coding.tex)
* Unit 5.  Adaptive Modulation and Coding
    * Lecture: [[PDF]](./lectures/Unit05_AMC.pdf) [[PPT]](./lectures/Unit05_AMC.pptx) 
    * [Lecture videos](./unit05_amc/readme.md) and in-class exercises
    * Demo: 802.11 MCS selection  [[PDF]](./unit05_amc/demo_mcs.pdf) [[Matlab Live]](./unit05_amc/demo_mcs.mlx)
    * Demo: Channel Tracking with 5G NR CSI-RS [[PDF]](./unit05_amc/demo_csirs.pdf) [[Matlab Live]](./unit05_amc/demo_csirs.mlx)    
    * Lab:  5G NR DL Throughput with Multi-Process HARQ [[PDF]](./unit05_amc/lab_partial/labHarq.pdf) [[Matlab Live]](./unit05_amc/lab_partial/labHarq.mlx) 
    * Problems:  [[PDF]](./unit05_amc/prob/prob_amc.pdf) [[Latex]](./unit05_amc/prob/prob_amc.tex)
* Unit 6.  Diversity
* Unit 7.  OFDM Channel Estimation and Equalization
    * Lecture:  [[PDF]](./lectures/Unit07_ChanEst.pdf) [[Powerpoint]](../lectures/Unit07_ChanEst.pdf) 
    * [Lecture videos](./unit07_chanest/readme.md) and in-class exercises
    * Demo:  5G NR DM-RS configuration  [[PDF]](./unit07_chanest/demoDMRSConfig.pdf)  [[Matlab Live]](./unit07_chanest/demoDMRSConfig.mlx) 
    * Demo:  Kernel regression channel estimation [[PDF]](./unit07_chanest/demoKernelEst.pdf)  [[Matlab Live]](./unit07_chanest/demoKernelEst.mlx) 
    * Lab:  5G NR DL Throughput with Channel Estimation [[PDF]](./unit07_chanest/lab_partial/labChanEst.pdf) [[Matlab Live]](./unit07_chanest/lab_partial/labChanEst.mlx) 
    * Problems:  [[PDF]](./unit07_chanest/prob/prob_chanest.pdf) [[Latex]](./unit07_chanest/prob/prob_chanest.tex)
* Unit 8.  Multiple Antennas and Beamforming
    * Lecture: [[PDF]](./lectures/Unit08_Beamforming.pdf) [[PPT]](./lectures/Unit08_Beamforming.pptx) 
    * Demo: Visualizing and simualting arrays [[PDF]](./unit08_bf/demoBF.pdf) [[Matlab Live]](./unit08_bf/demoBF.mlx)
    * Demo: Pattern multiplication and mutual coupling [[PDF]](./unit08_bf/mutualCoupling.pdf) [[Matlab Live]](./unit08_bf/mutualCoupling.mlx)
    * Lab:  Simulating beamforming on a 28 GHz channel [[PDF]](./unit08_bf/labPartial/labBF.pdf) [[Matlab Live]](./unit08_bf/labPartial/labBF.pdf)
    * Problems:  [[PDF]](./unit08_bf/prob/prob_bf.pdf) [[Latex]](./unit08_bf/prob/prob_bf.tex)
* Unit 9.  Introduction to MIMO 
    * Lecture: [[PDF]](./lectures/Unit09_MIMO.pdf) [[PPT]](./lectures/Unit09_MIMO.pptx) 
    * Demo: Computing the MIMO Capacity [[PDF]](./unit09_mimo/mimoCapaciy.pdf) [[Matlab Live]](./unit09_mimo/mimoCapaciy.mlx)
    * Demo: Indoor channel data [[PDF]](./unit09_mimo/indoorDataDemo.pdf) [[Matlab Live]](./unit09_mimo/indoorDataDemo.mlx)
    


