% EGG signal high-pass filtering (with phase correction)
% Last update: 08-14-2023

% Clear the workspace and command window
clc;
clear;

% Prompt user to select folders with EGG files
% EGG files are assumed to be in WAV format
eggName = uigetdir('Select the folder with the EGG files.');
cd(eggName);
eggFiles = dir('*.wav');

% Prompt user to select the directory to save processed files
saveDir = uigetdir('Select the directory you wish to save to');

% Loop through each EGG file to process the data
for i = 1:size(eggFiles)
    fprintf('Processing file %d of %d...\n', i, size(eggFiles, 1));

    % Load EGG signal from WAV file
    cd(eggName)
    [raw_signal, fs] = audioread(eggFiles(i).name);

    Fs = fs;  % Sample rate
    raw_signal = raw_signal;  % raw EGG signal data

    % Design the Butterworth high-pass filter
    cutoff_freq = 40;   % Cutoff frequency in Hz
    filter_order = 4;   % Filter order
    
    % Calculate normalized cutoff frequency
    cutoff_norm = cutoff_freq / (0.5 * Fs);

    % Design the filter
    [b, a] = butter(filter_order, cutoff_norm, 'high');

    % Apply the high-pass filter to the raw signal
    filtered_signal = filter(b, a, raw_signal);

    % Design the reverse high-pass filter (same parameters as the original)
    [b_reverse, a_reverse] = butter(filter_order, cutoff_norm, 'high');

    % Apply the reverse high-pass filter to the high-pass filtered signal
    phase_corrected_signal = filter(b_reverse, a_reverse, filtered_signal);

    % Create a time vector
    t = (0:length(raw_signal)-1) / Fs;

    % Plot the signals
    figure;

    subplot(3,1,1);
    plot(t, raw_signal);
    title('Raw EGG Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');

    subplot(3,1,2);
    plot(t, filtered_signal);
    title('High-Pass Filtered EGG Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');

    subplot(3,1,3);
    plot(t, phase_corrected_signal);
    title('Phase-Corrected EGG Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');

    % Navigate to the directory where the filtered files will be saved
    cd(saveDir)

    % Create filenames for the filtered EGG signals
    new_fileName = [eggFiles(i).name(1:end-4) '_filtered.wav'];

    % Save the filtered files to new .wav files
    audiowrite(new_fileName, phase_corrected_signal, Fs);
end

fprintf('Filtering completed for all files.\n');
