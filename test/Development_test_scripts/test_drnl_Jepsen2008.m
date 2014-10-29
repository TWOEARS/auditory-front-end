% Test script to compare the output from TwoEars DRNL filterbank processor
% to the I/O function in (Jepsen et al. 2008) (Figure 2, p425)

clear all
close all
clc

%% Add paths
path = fileparts(mfilename('fullpath'));
% also added twoears-tools folder following the updates re circular buffers
% (assuming the folder is located inside the same folder where twoears-wp2 is) 
addpath(genpath([path filesep '..' filesep '..' filesep '..' filesep 'twoears-tools']))
run([path filesep '..' filesep '..' filesep 'src' filesep 'startWP2.m'])

%% test signal
% 1. sinusoid with some onset/offset ramps
% pasted from MAP1_14h test codes to potentially test against the MAP
% implementation
sampleRate = 44100;
fs = sampleRate;             % trying to unify the input characteristics
toneFrequency= [1000 2400 4000 8000];           % (Hz)
duration = 0.5;                 % trying to unify the input characteristics
beginSilence=0.050;
endSilence=0.050;
rampDuration=.005;              % raised cosine ramp (seconds)
leveldBSPL= (0:10:100);   

% calibration factor (see Jepsen et al. 2008)
dBSPLCal = 100;         % signal amplitude 1 should correspond to max SPL 100 dB
ampCal = 1;             % signal amplitude to correspond to dBSPLRef
pRef = 2e-5;            % reference sound pressure (p0)
pCal = pRef*10^(dBSPLCal/20);
calibrationFactor = ampCal*10.^((leveldBSPL-dBSPLCal)/20);
levelPressure = pRef*10.^(leveldBSPL/20);

% define 20-ms onset sample after ramp completed (blue line)
%  allowing 5-ms response delay
onsetPTR1=round((rampDuration+ beginSilence +0.005)*sampleRate);
onsetPTR2=round((rampDuration+ beginSilence +0.005 + 0.020)*sampleRate);
% last half 
lastHalfPTR1=round((beginSilence+duration/2)*sampleRate);
lastHalfPTR2=round((beginSilence+duration-rampDuration)*sampleRate);

dt=1/sampleRate; % seconds
time=dt: dt: duration;

% calculate ramp factor
% catch rampTime error
if rampDuration>0.5*duration, rampDuration=duration/2; end
rampTime=dt:dt:rampDuration;
ramp=[0.5*(1+cos(2*pi*rampTime/(2*rampDuration)+pi)) ...
    ones(1,length(time)-length(rampTime))];
ramp_temp = repmat(ramp, [length(leveldBSPL), 1]);  % to be multiplied to inputSignal

% derive silence parts
intialSilence= zeros(1,round(beginSilence/dt));
finalSilence= zeros(1,round(endSilence/dt));

inputSignalMatrix = zeros(length(leveldBSPL), ...
    length(time)+length(intialSilence)+length(finalSilence), ...
    length(toneFrequency));

for ii=1:length(toneFrequency)
    inputSignal=sin(2*pi*toneFrequency(ii)'*time);      % amplitude -1~+1
    % "input amplitude of 1 corresponds to a maximum SPL of 100 dB"
    % calibration: calculate difference between input level dB SPL and the
    % given SPL for calibration (100 dB)
    inputSignal = calibrationFactor'*inputSignal;
    % % "signal amplitude is scaled in pascals in prior to OME"
    % inputSignal = levelPressure'*inputSignal;
    
    % apply ramp
    inputSignal=inputSignal.*ramp_temp;
    ramp_temp=fliplr(ramp_temp);
    inputSignal=inputSignal.*ramp_temp;
    % add silence
    inputSignal= [repmat(intialSilence, [length(leveldBSPL), 1]) ...
        inputSignal repmat(finalSilence, [length(leveldBSPL), 1])];
    
    inputSignalMatrix(:, :, ii) = inputSignal;
end

% amp=10.^(leveldBSPL/20)*28e-6;   % converts to Pascals (peak) - MAP1_14
% inputSignal=amp'*inputSignal;

% matrix to store output (I/O function)
ioFunctionMatrix = zeros(length(toneFrequency), length(leveldBSPL));

request = 'drnl';

for jj=1:length(toneFrequency)
    xStapes = OuterMiddleFilter(inputSignalMatrix(:, :, jj).');
%     % parameter structure for testing on-freq stimulation
%     param_struct = genParStruct('drnl_cf', toneFrequency(jj));
    % parameter structure for testing different stimulation freq at single CF
    param_struct = genParStruct('drnl_cf', 4000);
    for kk=1:length(leveldBSPL)
        dObj = dataObject(xStapes(:, kk), fs);
        mObj = manager(dObj);
        out = mObj.addProcessor(request, param_struct);
        mObj.processSignal();
        peakOut = max(dObj.drnl{1}.Data(:));
        peakOutdB = 20*log10(peakOut);
        ioFunctionMatrix(jj, kk) = peakOutdB;
        clear dObj mObj out
    end
    clear xStapes param_struct
end

plot(leveldBSPL, ioFunctionMatrix, '-*');
legendCell=cellstr(num2str(toneFrequency', '%-dHz'));
legend(legendCell, 'Location', 'NorthWest');


% % For testing against MAP examples
% dObj = dataObject(inputSignal(2,:), fs);
% mObj = manager(dObj);               % Manager instance
% param_struct = genParStruct('drnl_CF', [500 1000 5000 10000]);
% out = mObj.addProcessor(request, param_struct);



% % For testing against CASP2008 test script
% % comparison to CASP output needs stapes output as the input to DRNL
% % filterbank - so use xStapes instead of x for dataObject
% dObj = dataObject(xStapes, fs);
% mObj = manager(dObj);               % Manager instance
% % BM.CenterFreqs is a list of Characteristic Frequencies as the input to
% % DRNL processor
% out = mObj.addProcessor(request, param_struct);
% 
% %% Request processing
% mObj.processSignal();
% 
% %% Compare results - to CASP 2008 output: IntRep.BM
% duration = length(xStapes)/fs;
% dt=1/fs; % seconds
% time=dt: dt: duration;
% 
% % dObj.drnl.Data vs IntRep.BM
% diff = (abs(dObj.drnl{1}.Data(:) - IntRep.BM)+eps).';
% figure;
% imagesc(dObj.drnl{1}.Data(:).'); colorbar;
% figure;
% imagesc(IntRep.BM.'); colorbar;
% figure;
% imagesc(20*log10(diff)); colorbar;
% set(gca,'XTick', [round(size(dObj.drnl{1}.Data(:).', 2)/2) size(dObj.drnl{1}.Data(:).', 2)]);
% set(gca,'XTickLabel', {time(round(size(dObj.drnl{1}.Data(:).', 2)/2)), time(size(dObj.drnl{1}.Data(:).', 2))});
% set(gca,'YTick', [1 round(size(dObj.drnl{1}.Data(:).', 1)/2) size(dObj.drnl{1}.Data(:).', 1)]);
% set(gca,'YTickLabel', {BM.CenterFreqs(1), BM.CenterFreqs(round(size(dObj.drnl{1}.Data(:).', 1)/2)), BM.CenterFreqs(size(dObj.drnl{1}.Data(:).', 1))});
% xlabel('Time [sec]');
% ylabel('CF [Hz]');
% title('Error in BM output between drnlProc and CASP2008');
% 
% 
% % dObj.drnl{1}.plot;      % this needs revising - inside TImeFrequencySignal



