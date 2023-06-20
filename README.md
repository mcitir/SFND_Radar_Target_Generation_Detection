# Project: Radar Target Generation and Detection

This is the project submission for the "Radar Target Generation and Detection" in the Udacity Sensor Fusion Engineer Nanodegree program.

![01_layout](/assets/01_layout.PNG)

|Success Criteria|Specifications|
|---|---|
|**Step 1:** FMCW Waveform Design|&#x2714; Done, The calculated slope was approximately 2e13.  |
|>> Bandwidth (B), chirp time (T_cpi) and slope of the chirp|&#x2714; Done|
|**Step 2:** Simulation Loop|&#x2714; Done|
| **Step 3:** Range FFT (1st FFT)|&#x2714; Done|
|>> Range FFT implementation on Mixed Signal|&#x2714; Done, The peak was already obtained at correct range.|
| **Step 4:** 2D CFAR |&#x2714; Done|
|>> Implementation steps for the 2D CFAR|&#x2714; Done|
|>> Selection of Training, Guard cells and offset|&#x2714; Done|
|>> Steps taken to suppress the non-thresholded cells at the edges|&#x2714; Done,|

## Detailed explanations are already given at [MATLAB file](https://github.com/mcitir/SFND_Radar_Target_Generation_Detection/blob/main/Radar_Target_Generation_and_Detection.m). You will only find a summary as requested by [Rubric](https://review.udacity.com/#!/rubrics/2548/view).

### Step 1: FMCW Waveform Design
Based on the task, the slope is calculated as expected and the value `2e13` was obtained as requested.

### Step 2: Simulation Loop
The numbers of Doppler cells and range cells were chosen as a power of 2. Thus, this will provide computational efficiency and memory management.  
```
Nd = 128; 
Nr = 1024;
```
Here, a time vector `t` that spans from `0` to the total time of the chirp period (`Nd *T_cpi`) with a total of `Nr* Nd` samples. Therefore, `t= linspace(0, Nd*T_cpi,Nr*Nd)` is used for time span calculation. To calculate Range Fast Fourier Transform (FFT) along the range dimension and Doppler FFT along the Doppler dimension, we reshape the mix signal vector into `NxD` array.  


### Step 3: Range FFT (1st FFT)

1D FFT was implemented on mixed signal. The steps are implemented:

- Reshape the vector into `NxD` array to define size of range and doppler.
- Run the FFT on the beat signal along the range bins dimension
- Absolut value of FFT output
- Calculate the maximum value (peak) of the signal_fft
- Normalize
- Since Output of FFT double-sided, reduce the half of the samples
- Plot

Output:
![plot_1](/assets/plot_1.png)

### Step 4: 2D CFAR

The steps are done based on the requested goal:

- Select the number of Training Cells in the both the dimensions
- Select the number of the Guard cells in the both dimensions around the Cell under test (CUT) for accurate estimation
- Determine offset the threshold by SNR value in dB
- Steps taken to suppress the non-thresholded cells at the edges.
  - Firstly, two outer loop designed to slide through the complete map (matrix). CUT must have a margin from the edges.
  - Thresholded block is selected as smaller than the Map; to keep the map size same, non-thresholded are assigned a value of 0.
  - Training cells, Guard cells and offset were selected by an increase or decrease test. 

![plot_2](/assets/plot_2_haehzcgfa.png)
![plot_3](/assets/plot_3_uy0ibrrnz.png)