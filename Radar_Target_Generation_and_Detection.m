clc; clear; close all;

%% Radar Parameters
fc = 77.0e9;       % [Hz],   Operating frequency
range_res = 1;     % [m],    Range resolution
range_max = 200;   % [m],    Max range
vel_res = 3;       % [m/s],  Velocity resolution
vel_max = 70;      % [m/s],  Max velocity

% Misc. Parameters
c = 3.0e8;         % [m/s],  Speed of light

% User defined Range and Velocity of target
range = 110;
vel = -20;

%% Step 1: FMCW Waveform Design
% Design a FMCW waveform

% Chirp Bandwidth (B)
B = c / (2 * range_res);

% Chirp Time (Tcpi)
T_cpi = 5.5 * (range_max * 2 / c);

% Slope of the FMCW
slope = B / T_cpi;

%% Step 2: Simulation Loop

Nd = 64; 
Nr = 512;

% timestamp, total time for samples
t= linspace(0, Nd*T_cpi,Nr*Nd);

% Allocation of the vectors for Tx, Rx, and Mix
Tx = zeros(1,length(t));
Rx = zeros(1,length(t));
Mix = zeros(1,length(t));

% and for range_covered and time delay (td)
r_t = zeros(1,length(t));
td = zeros(1,length(t));

for i = 1:length(t)

    % For each time stamp update the Range of Target for constant velocity.
    r_t(i) = range + (vel*t(i)); 
    td(i) = (2*r_t(i))/c; % time delay 
    
    % For each time sample we need update the transmitted and received
    % signal
    Tx(i) = cos(2*pi*(fc*t(i) + (slope*t(i)^2)/2.0));
    Rx(i) = cos(2*pi*(fc*(t(i)-td(i)) + (slope*(t(i)-td(i))^2)/2.0));

    % Mixing the Transmit and Receive generate the beat signal 
    Mix(i) = Tx(i).*Rx(i); 

end

%% Step 3: Range FFT (1st FFT)

% Reshape the vector into N*D array. N and D defines the size of Range and
% Doppler FFT
Mix = reshape(Mix,[Nr,Nd]);


% Run the FFT on the beat signal along the range bins dimension (Nr)
signal_fft = fft(Mix,Nr);

% Normalize
signal_fft = signal_fft ./max(signal_fft); 

% Absolut value of FFT output
signal_fft = abs(signal_fft);

% Calculate the maximum value (peak) of the signal_fft


% Since Output of FFT double-sided, reduce the half of the samples
signal_fft = signal_fft(1:Nr/2);

% Plot
figure('Name','Range from the first FFT')
plot(signal_fft)
axis ([0 200 0 1.3]);
title('Range from the first FFT');
ylabel('Amplitude')
xlabel('Range [m]')

%% Step 4: 2D CFAR

% 2D FFT implementation
Mix = reshape(Mix,[Nr,Nd]);
signal_fft2 = fft2(Mix, Nr, Nd);

% One side of the signal
signal_fft2 = signal_fft2(1:Nr/2,1:Nd);
signal_fft2 = fftshift(signal_fft2);

% Absolute of the signal
RDM = abs(signal_fft2);
RDM = 10* log10(RDM);

% Plot the output of 2D FFT
doppler_axis = linspace(-100, 100, Nd);
range_axis = linspace(-200, 200, Nr/2)*((Nr/2)/400);

figure('Name', '2d FFT Implementation'), surf(doppler_axis,range_axis,RDM);
title("Amplitude and range from FFT2");
xlabel("Velocity");
ylabel("Range");
zlabel("Amplitude");

% Select the number of Training Cells in the both the dimensions
Tr = 9;
Td = 7;

% Select the number of the Guard cells in the both dimensions around the
% Cell under test (CUT) for accurate estimation
Gr = 4;
Gd = 4;


% Offset the threshold by SNR value in dB
offset = 10; % e.g. formula: pow2db(snr) + 10 * log10(numel(guard_cells));

% Allocation of noise_level


[rows_RDM, cols_RDM] = size(RDM);
RDM_pow = db2pow(RDM);

for i = Tr+Gr+1 : (Nr/2) - (Gr+Tr)
    for j = Td+Gd+1:Nd-(Gd+Td)
        noise_level = zeros(1,1);
        for p = i - (Tr+Gr):i+Tr+Gr
            for q = j - (Td+Gd):j+Td+Gd

                if (abs(i-p)>Gr || abs(j-q)>Gd)
                    noise_level = noise_level+ RDM_pow(p,q);
                end
            end
        end

        threshold = pow2db(noise_level/(2*(Td+Gd+1)*2*(Tr+Gr+1)-(Gr*Gd)-1));
        % Add the SNR offset to the threshold
        threshold = threshold + offset;

        % Measure the signal in Cell Under Test (CUT) and compaire against
        CUT = RDM(i,j);

        if (CUT<threshold)
            RDM(i,j) = 0;
        else
            RDM(i,j) = 1;
        end

    end
end

for i = 1: Tr + Gr
    RDM(i, :) = 0;
    RDM(Nr / 2 - i - 1:Nr / 2, :) = 0;
end
for i = 1:Td + Gd
    RDM(:, i) = 0;
    RDM(:, Nd - i - 1:Nd) = 0;
end

figure('Name', 'CFAR Filtered RDM'), surf(doppler_axis,range_axis,RDM);
colorbar;
title( 'CFAR Filtered RDM');
xlabel('Speed');
ylabel('Range');
zlabel('Normalized Amplitude');










