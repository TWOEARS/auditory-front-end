clear all
close all
clc

%% Add paths
path = fileparts(mfilename('fullpath')); 
% run([path filesep '..' filesep '..' filesep 'src' filesep 'startWP2.m'])
run('../../src/startWP2.m');

%% test signal
% 1. grabbed from MAP1_14h codes

% sampleRate= 50000;
sampleRate = 48000;             % trying to unify the input characteristics
signalType= 'tones';
toneFrequency= 10000;            % or a pure tone (Hz)
% duration=0.200;                 % seconds
duration = 0.5;                 % trying to unify the input characteristics
beginSilence=0.050;
endSilence=0.050;
rampDuration=.005;              % raised cosine ramp (seconds)
leveldBSPL= (-10:10:90);   

% define 20-ms onset sample after ramp completed (blue line)
%  allowing 5-ms response delay
onsetPTR1=round((rampDuration+ beginSilence +0.005)*sampleRate);
onsetPTR2=round((rampDuration+ beginSilence +0.005 + 0.020)*sampleRate);

% last half 
lastHalfPTR1=round((beginSilence+duration/2)*sampleRate);
lastHalfPTR2=round((beginSilence+duration-rampDuration)*sampleRate);

dt=1/sampleRate; % seconds
time=dt: dt: duration;
inputSignal=sum(sin(2*pi*toneFrequency'*time), 1);
amp=10.^(leveldBSPL/20)*28e-6;   % converts to Pascals (peak)
inputSignal=amp'*inputSignal;
% apply ramps
% catch rampTime error
if rampDuration>0.5*duration, rampDuration=duration/2; end
rampTime=dt:dt:rampDuration;
ramp=[0.5*(1+cos(2*pi*rampTime/(2*rampDuration)+pi)) ...
    ones(1,length(time)-length(rampTime))];
ramp_temp = repmat(ramp, [length(leveldBSPL), 1]);

inputSignal=inputSignal.*ramp_temp;
ramp_temp=fliplr(ramp_temp);
inputSignal=inputSignal.*ramp_temp;
% add silence
intialSilence= zeros(1,round(beginSilence/dt));
finalSilence= zeros(1,round(endSilence/dt));
inputSignal= [repmat(intialSilence, [length(leveldBSPL), 1]) inputSignal repmat(finalSilence, [length(leveldBSPL), 1])];

% 2. from WP2 test script
load('TestBinauralCues');

% 3. from CASP 2008 test script
load('CASP_data'); fs = 44100;

%% Instantiate manager and data object

request = 'drnl';

% dObj = dataObject(inputSignal(2,:), fs);
% mObj = manager(dObj);               % Manager instance
% 
% param_struct = genParStruct('drnl_CF', [500 1000 5000 10000]);
% out = mObj.addProcessor(request, param_struct);

dObj = dataObject(xStapes, fs);
mObj = manager(dObj);               % Manager instance

% %% from CASP2008 test script
% % Basilar filterbank variables
% BM.MinCF = 100;               % lowest CF in Hz
% BM.MaxCF = 10000;             % highest CF in Hz
% BM.Align = 1000;              % base frequency in Hz
% BM.BW    = 1.0;               % bandwidth of the filter in ERB
% BM.Dens  = 1.0;               % filter density in 1/ERB
% % calculates center frequencies of basilar-membrane filterbank in ERB
% [BM.NrChannels, BM.CenterFreq] = getGFBCenterERBs(BM.MinCF, BM.MaxCF, BM.Align, BM.Dens);
% 
% % convert from ERBs to freqs
% BM.CenterFreqs = erbtofreq(BM.CenterFreq);
% % These seem to be the "Characteristic Frequencies" for DRNL filterbank
% 
% % calculate filter coefficients for basilar-membrane filterbank and lowpass
% [BM.b(1,:,:), BM.a(1,:,:)]=getGFBFilterCoefs(BM.NrChannels, BM.CenterFreqs, BM.BW, fs);
% [Lp.b1, Lp.a1] = butter(1, 1000*2/fs);

param_struct = genParStruct('drnl_CF', BM.CenterFreqs);
out = mObj.addProcessor(request, param_struct);

%% for testing against MAP examples
% param_struct = genParStruct('drnl_CF', [500 1000 5000 10000]);
% out = mObj.addProcessor(request, param_struct);


%% Request processing
mObj.processSignal();

%% Compare results - against CASP 2008 output: IntRep.BM

% dObj.drnl.Data vs IntRep.BM

diff = dObj.drnl{1}.Data - IntRep.BM;
figure;
imagesc(dObj.drnl{1}.Data); colorbar;
figure;
imagesc(IntRep.BM); colorbar;
figure;
imagesc(diff); colorbar;


% dObj.drnl{1}.plot;      % this needs revising - inside TImeFrequencySignal



