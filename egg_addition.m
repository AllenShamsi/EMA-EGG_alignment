% Struct addition script
% Written by Jessica Goel
% Last updated: 07/30/23

clc; clear;

% Step 1: Gathering number and location of .mat files.
matName = uigetdir('Select the folder the .mat files are in.'); 
cd(matName);
matFiles = dir('*.mat');

% Step 2: Gathering number and location of egg .wav files.
wavName = uigetdir('Select the folder the egg wav files are in.');
cd(wavName);
wavFiles = dir('*.wav');

% Step 3: Finding desired directory to store updated structs in.
saveDirectory = uigetdir('Select the folder you want to save the new .mat files to.');

% Step 4: Check to make sure number of .wav files and .mat files are equal.
% Print error if not.
if length(wavFiles)~= length(matFiles)
    error('Oops! It looks like you are missing .mat or .wav files. Check your folders and try again.'); 
else
    for i = 1:1:length(wavFiles) % Loop through all files.
        
        % Step 5: Load .mat file.
        cd(matName)
        temp1 = matFiles(i).name;
        matCurrent = struct2cell(load(temp1));
        
        % Step 6: Load .wav file.
        cd(wavName);
        temp2 = wavFiles(i).name;
        wavCurrent = audioread(temp2);
        
        % Step 7: Add line. 
        matCurrent{1,1}(7).NAME='EGG';
        matCurrent{1,1}(7).SRATE=16000;
        matCurrent{1,1}(7).SIGNAL=wavCurrent;
        
        % Step 8: Generate updated .mat file.
        matNew=matCurrent{1,1};
        
        % Step 9: Save updated .mat file.
        cd(saveDirectory)
        fileName = [temp1(1:end-4),'_with_EGG'];
        SaveVar(matNew, fileName)    
    end
end
