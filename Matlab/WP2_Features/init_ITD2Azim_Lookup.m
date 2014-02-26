function mapping = init_ITD2Azim_Lookup(STATES,SET,bCalibrate)
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


% Select list of cues and features that should be extracted
listFeatures = {};
listCues     = {'itd_xcorr'};

% Initialize processing
STATES = init_WP2(listFeatures,listCues,STATES.SET);


%% 2. CALIBRATION SETTINGS
% 
% 
% Length of random noise sequence in seconds
lengthSec = 1;


%% 3. CALIBRATION STAGE
% 
% 
% Check if we can re-use the calibration file from the last function call
if isequal(SET,PER_set) && isequal(STATES,PER_STATES) && ~bCalibrate 
    bRecalibrate = false;
    % If no mapping file is detected ... re-calibrate
    if ~exist([SET.rootDir,'ITD2Azimuth_Mapping.mat'],'file')
        bRecalibrate = true;
    end
else
    bRecalibrate = true;
end

% Perform calibration
if bRecalibrate
    % Store persistent variables
    PER_set = SET; PER_STATES = STATES; 

    % Number of different sound source positions
    nAzimPos = numel(SET.rangeSource);
    
    % Number of different sound source positions after interpolation
    nAzimInterp = numel(SET.rangeAzim);
    
    % Number of auditory filters
    nFilter = STATES.signals(strcmp([STATES.signals.domain],'gammatone')).set.paramGT.nFilter;
    
    % Create white noise
    noise = randn(round(lengthSec*SET.fsHz),1);

    % Allocate memory
    itd       = zeros(nAzimPos,nFilter);
    itdInterp = zeros(nAzimInterp,nFilter);
    
            
    % MAIN LOOP
    %
    %
    % Loop over number of different sound source directions
    for ii = 1 : nAzimPos

        % Spatialize audio signal using HRTF processing
        earSignals = auralizeWP1(noise,SET.fsHz,SET.rangeSource(ii));
        
        % Perform WP2 signal computation
        [SIGNALS,STATES] = process_WP2_signals(earSignals,SET.fsHz,STATES);

        % Perform WP2 cue computation
        [CUES,STATES] = process_WP2_cues(SIGNALS,STATES);
        
        % Estimate ITD
        itdEst = feval(SET.average,CUES.data(:,:,1),2);
        
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
        itdInterp(:,jj) = interp1(SET.rangeSource,itd(:,jj),SET.rangeAzim);
        
%         % Ensure that mapping is monotonic by using a polynomial fit
%         itd2AzimPoly(:,jj) = polyval(polyfit(set.rangeAzim,itd2AzimInterp(:,jj).',set.polyOrder),set.rangeAzim);
    end
    
    % Save data
    %
    %
    mapping.fs      = SET.fsHz;
    mapping.azimuth = SET.rangeAzim;
    mapping.itd     = itdInterp;
    
%     mapping.itd2azimRaw  = itd2Azim;
%     mapping.polyOrder    = set.polyOrder;
%     mapping.itdMax       = max(itd2AzimPoly);
%     mapping.itdMin       = min(itd2AzimPoly);
    
    % Store ITD2Azimuth template
    save([SET.rootDir,'ITD2Azimuth_Mapping.mat'],'mapping');    
else
    load([SET.rootDir,'ITD2Azimuth_Mapping.mat']);    
end