%% Radar Parameters
fc = 77.0e9; %Operating frequency (Hz)
c = 3.0e8; %Speed of light
range_res = 1;
range_max = 200;

%% Step 1: FMCW Waveform Design
% Design a FMCW waveform
% Bandwidth (B)
B = c / (2 * range_res);

% Chirp Time (Tchirp)
Tchirp = 5.5 * (range_max * 2 / c);

% Slope of the FMCW
slope = B / Tchirp;
