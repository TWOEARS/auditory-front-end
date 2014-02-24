function mapping = calibrate_ITD(STATES,set,bCalibrate)
%calibrate_ITD_Subband   Calculate frequency-dependent ITD2azimuth mapping
%
%USAGE
%      calibrate_ITD(P,set)
%      calibrate_ITD(P,set,bCalib)
%
%INPUT PARAMETERS
%             P : periphery parameter struct (initialized by init_WP2.m)
%           set : settings
%    bCalibrate : if true, enforce re-computation of the mapping function
% 
%OUTPUT PARAMETERS
%     The ITD2Azimuth mapping will be stored in the MAT file
%     ITD2Azimuth_Mapping.mat inside the \Data directory.

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2013
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/01/31
%   v.0.2   2014/02/22 adopted to new structure
%   ***********************************************************************

% Initialize persistent variables
persistent PER_set PER_STATES


%% 1. CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin < 2 || nargin > 3
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default parameter
if nargin < 3 || isempty(bCalibrate); bCalibrate = false; end

% Detect ITD cue 
bITDCues = strcmp('itd',[STATES.cues.name]);

if any(bITDCues)
    STATES.cues = STATES.cues(bITDCues);
else
    error('%s: ITD cue is required for azimuth extraction.',mfilename);
end


%% 2. CALIBRATION SETTINGS
% 
% 
% Length of random noise sequence in seconds
lengthSec = 0.5;


%% 3. CALIBRATION STAGE
% 
% 
% Check if we can re-use the calibration file from the last function call
if isequal(set,PER_set) && isequal(STATES,PER_STATES) && ~bCalibrate 
    bRecalibrate = false;
    % If no mapping file is detected ... re-calibrate
    if ~exist([set.rootDir,'ITD2Azimuth_Mapping.mat'],'file')
        bRecalibrate = true;
    end
else
    bRecalibrate = true;
end

% Perform calibration
if bRecalibrate
    % Short-cut
    fsHz = STATES.signal.fsHz;
    
    % Store persistent variables
    PER_set = set; PER_STATES = STATES; 

    % Number of different sound source positions
    nAzimPos = numel(set.rangeSource);
    
    % Number of different sound source positions after interpolation
    nAzimInterp = numel(set.rangeAzim);
    
    % Number of auditory filters
    nFilter = STATES.signal.periphery.gammatone.nFilter;
    
    % Create white noise
    noise = randn(round(lengthSec*fsHz),1);

    % Allocate memory
    itd       = zeros(nAzimPos,nFilter);
    itdInterp = zeros(nAzimInterp,nFilter);
    
            
    % MAIN LOOP
    %
    %
    % Loop over number of different sound source directions
    for ii = 1 : nAzimPos

        % Spatialize audio signal using HRTF processing
        earSignals = auralizeWP1(noise,fsHz,set.rangeSource(ii));
        
        % Perform WP2 computation
        [SIGNALS,CUES] = process_WP2_cues(earSignals,fsHz,STATES);
        
        % Estimate ITD
        itdEst = feval(set.average,CUES.data(:,:,1),2);
        
        % Store azimuth-dependent ITD
        itd(ii,:) = itdEst;
        
        % Report progress
        fprintf('\nITD2Azimuth calibration: %.2f %%',100*ii/nAzimPos);
    end
    
    
    % Interpolation
    %
    %
    % Loop over the number of files
    for jj = 1 : nFilter
        % Interpolate to 'rangeAzInterp'
        itdInterp(:,jj) = interp1(set.rangeSource,itd(:,jj),set.rangeAzim);
        
%         % Ensure that mapping is monotonic by using a polynomial fit
%         itd2AzimPoly(:,jj) = polyval(polyfit(set.rangeAzim,itd2AzimInterp(:,jj).',set.polyOrder),set.rangeAzim);
    end
    
    % Save data
    %
    %
    mapping.fs      = fsHz;
    mapping.azimuth = set.rangeAzim;
    mapping.itd     = itdInterp;
    
%     mapping.itd2azimRaw  = itd2Azim;
%     mapping.polyOrder    = set.polyOrder;
%     mapping.itdMax       = max(itd2AzimPoly);
%     mapping.itdMin       = min(itd2AzimPoly);
    
    % Store ITD2Azimuth template
    save([set.rootDir,'ITD2Azimuth_Mapping.mat'],'mapping');    
else
    load([set.rootDir,'ITD2Azimuth_Mapping.mat']);    
end