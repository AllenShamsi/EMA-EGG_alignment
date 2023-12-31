% EGG-EMA Signal Alignment
% Last update: 09-06-2023

% Clear the workspace and command window
clc;
clear;

% Prompt user to select folders for EGG and EMA files
% EGG files are assumed to be in CSV format, and EMA files are assumed to be in WAV format
eggName = uigetdir('Select the folder the EGG files are in.');
cd(eggName);
eggFiles = dir('*.csv');

emaName = uigetdir('Select the folder the WAV files are in.');
cd(emaName)
emaFiles = dir('*.wav');

% Prompt user to select the directory to save processed files
saveDir = uigetdir('Select the directory you wish to save to');

% Loop through each EMA file to process the data
for i = 1:size(emaFiles)
    fprintf('Processing file %d of %d...\n', i, size(emaFiles, 1));

    % Load EGG signal from CSV file
    cd(eggName)
    eggCurrent = readmatrix(eggFiles(i).name);
    egg_audio = eggCurrent(:, 1);
    egg_laryngogram = eggCurrent(:, 2);
    egg_sampRate = 16000;

    % Load EMA signal from WAV file
    cd(emaName)
    [ema_audio, fs] = audioread(emaFiles(i).name);

    % Resample ema_audio to match the EGG signal
    [P, Q] = rat(egg_sampRate/fs);
    ema_audio = resample(ema_audio, P, Q);

    % Pad or truncate egg_audio to match the duration of ema_audio
    if length(egg_audio) < length(ema_audio)
        num_zeros = length(ema_audio) - length(egg_audio);
        egg_audio = [zeros(num_zeros, 1); egg_audio];
        egg_laryngogram = [zeros(num_zeros, 1); egg_laryngogram];

    elseif length(egg_audio) > length(ema_audio)
        num_truncate = length(egg_audio) - length(ema_audio);
        egg_audio = egg_audio(num_truncate+1:end);
        egg_laryngogram = egg_laryngogram(num_truncate+1:end);
    end

    % Perform cross-correlation to find time delay between EMA and EGG signals
    [C, lag] = xcorr(ema_audio, egg_audio);
    [~, idx] = max(abs(C));
    delay_samples = lag(idx);

    fprintf('The EGG is delayed by %i samples \n', delay_samples);

    % Initialize arrays for aligned EGG audio and laryngogram signals
    egg_audio_aligned = zeros(length(egg_audio), 1);
    egg_laryngogram_aligned = zeros(length(egg_laryngogram), 1);

    % Perform alignment based on the calculated delay_samples
    if delay_samples >= 0
        egg_audio_aligned(1+delay_samples:end) = egg_audio(1:end-delay_samples);
        egg_laryngogram_aligned(1+delay_samples:end) = egg_laryngogram(1:end-delay_samples);
    else
        egg_audio_aligned(1:end+delay_samples) = egg_audio(-delay_samples+1:end);
        egg_laryngogram_aligned(1:end+delay_samples) = egg_laryngogram(-delay_samples+1:end);
    end

    % Normalize the signal to its maximum amplitude
    egg_audio_aligned = egg_audio_aligned / max(abs(egg_audio_aligned));
    egg_laryngogram_aligned = egg_laryngogram_aligned / max(abs(egg_laryngogram_aligned));
    egg_audio = egg_audio / max(abs(egg_audio));

    % Create a new figure with three vertically stacked subplots
    figure;
    subplot(4, 1, 1);
    plot((1:length(egg_audio)) / egg_sampRate, egg_audio, 'b');
    title('EGG Audio');
    ylabel('Amplitude');

    subplot(4, 1, 2);
    plot((1:length(ema_audio)) / egg_sampRate, ema_audio, 'b');
    title('EMA Audio');
    ylabel('Amplitude');

    subplot(4, 1, 3);
    plot((1:length(egg_audio_aligned)) / egg_sampRate, egg_audio_aligned, 'g');
    title('Aligned EGG Audio');
    ylabel('Amplitude');

    subplot(4, 1, 4);
    plot((1:length(egg_laryngogram_aligned)) / egg_sampRate, egg_laryngogram_aligned, 'r');
    title('Aligned EGG Laryngogram');
    ylabel('Amplitude');
    xlabel('Time (seconds)');

    % Navigate to the directory where processed files will be saved
    cd(saveDir)

    % Create filenames for the processed EGG audio and laryngogram signals
    egg_laryngogram_aligned_fileName = [emaFiles(i).name(1:end-4) '_EGG_laryngogram_aligned.wav'];

    % Save the processed files to new .wav files
    audiowrite(egg_laryngogram_aligned_fileName, egg_laryngogram_aligned, egg_sampRate);
    
end

fprintf('Processing completed for all files.\n');
