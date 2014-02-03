function calibrate_ITD(fs,winSec,P,bCalibrate)
%calibrate_ITD_Subband   Calculate frequency-dependent ITD2azimuth mapping
%
%USAGE
%      calibrate_ITD(fs,winSec)
%      calibrate_ITD(fs,winSec,G,bCalib)
%
%INPUT PARAMETERS
%            fs : sampling frequency in Hertz
%        winSec : frame size in seconds of the cross-correlation analysis
%             P : periphery parameter struct (initialized by init_WP2.m)
%    bCalibrate : if true, enforce re-computation of the mapping function
% 
%OUTPUT PARAMETERS
%     The ITD2Azimuth mapping will be stored in the MAT file
%     ITD2Azimuth_Mapping.mat inside the \Tools directory.

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2013
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/01/31
%   ***********************************************************************

% Initialize persistent variables
persistent PER_fs PER_winSec PER_P


%% 1. CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin < 3 || nargin > 4
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default parameter
if nargin < 4 || isempty(bCalibrate); bCalibrate = false; end


%% 2. CALIBRATION SETTINGS
% 
% 
% Length of random noise sequence in seconds
lengthSec = 0.25;

% Use anechoic HRTF measurements
room = 'SURREY_A';

% Azimuth range of interest (real sound source positions)
azimRange = (-90:5:90);

% New azimuth range after interpolation
azimRangeInterp = (-90:1:90);

% Order of polynomial fit that is applied to the ITD to ensure a monotonic
% mapping
pOrder = 3;
    

%% 3. CALIBRATION STAGE
% 
% 
% Check if we can re-use the calibration file from the last function call
if isequal(fs,PER_fs) && isequal(winSec,PER_winSec) && ...
   isequal(P,PER_P) && ~bCalibrate 
    bRecalibrate = false;
    % If no mapping file is detected ... re-calibrate
    if ~exist('ITD2Azimuth_Mapping.mat','file')
        bRecalibrate = true;
    end
else
    bRecalibrate = true;
end

% Perform calibration
if bRecalibrate
    % Store persistent variables
    PER_fs = fs; PER_winSec = winSec; PER_P = P; 

    % Number of different sound source positions
    nAzim = numel(azimRange);
    
    % Number of different sound source positions after interpolation
    nAzimInterp = numel(azimRangeInterp);
    
    % Number of auditory channels
    if P.bCompute
        nFilter = P.gammatone.nFilter;
    else
        nFilter = 1;
    end
        
    % Create white noise
    noise = randn(round(lengthSec*fs),1);

    % Allocate memory
    itd2Azim       = zeros(nAzim,nFilter);
    itd2AzimInterp = zeros(nAzimInterp,nFilter);
    itd2AzimPoly   = zeros(nAzimInterp,nFilter);
            
    % MAIN LOOP
    %
    %
    % Loop over number of different sound source directions
    for ii = 1 : nAzim

        % Spatialize audio signal using HRTF processing
        binaural = spatializeAudio(noise,fs,azimRange(ii),room);
        
        % Compute peripheral auditory signal
        peripheral = PeripheralProcessing(binaural,fs,P);
        
        % Estimate ITD
        [itdEst,lags] = estimate_ITD(peripheral,fs,winSec);

        % Store azimuth-dependent ITD
        itd2Azim(ii,:) = itdEst;
        
        % Report progress
        fprintf('\nITD2Azimuth calibration: %.2f %%',100*ii/nAzim);
    end
    
        
    % Interpolation
    %
    %
    % Loop over the number of files
    for jj = 1 : nFilter
        % Interpolate to 'rangeAzInterp'
        itd2AzimInterp(:,jj) = interp1(azimRange,itd2Azim(:,jj),azimRangeInterp);
        
        % Ensure that mapping is monotonic by using a polynomial fit
        itd2AzimPoly(:,jj) = polyval(polyfit(azimRangeInterp,itd2AzimInterp(:,jj).',pOrder),azimRangeInterp);
    end
    
    
    % Save data
    %
    %
    mapping.fs           = fs;
    mapping.azim         = azimRangeInterp;
    mapping.itd          = lags/fs;
    mapping.itd2azimRaw  = itd2Azim;
    mapping.itd2azim     = itd2AzimPoly;
    mapping.polyOrder    = pOrder;
    mapping.itdMax       = max(itd2AzimPoly);
    mapping.itdMin       = min(itd2AzimPoly);
    
    % Store ITD2Azimuth template
    save([pwd,filesep,'Tools',filesep,'ITD2Azimuth_Mapping.mat'],'mapping');    
end