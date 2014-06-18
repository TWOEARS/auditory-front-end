function STATES = init_WP2(listFeatures,listCues,SET)
%init_WP2   Initialize parameters for WP2 processing
%
%USAGE
%         STATES = init_WP2(listFeatures,listCues,SET)
%
%INPUT PARAMETERS
%   listFeatures : list of features to be extracted
%       listCues : list of cues to be extracted
%            SET : general settings
% 
%OUTPUT PARAMETERS
%         STATES : initialized states for all SIGNALS, CUES and FEATURES

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2013
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/01/31
%   v.0.2   2014/02/21 added modular cue extraction structure
%   v.0.3   2014/02/22 added feature extraction structure
%   v.0.4   2014/02/22 added dependencies
%   v.0.5   2014/02/26 automatically determine dependencies
%   v.0.6   2014/03/05 added onset and offset strength
%   ***********************************************************************


%% TODOs
% 
% 
% TODO: use a flag bProcess to activate certain cues/features. Still, all
% the parameters are stored 
% 
% TODO: Use feedback to control frequency resolution, therefore, all
% internal filter states have to be reset
% 
% TODO: implement separate scripts for initialization of
% signals,cues and features
% 
% TODO: define signals, cues and features as classes

% TODO: SIGNALS and CUES can be monaural or binaural, and this request
% should be trigger by the respective CUES and FEATURES


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin < 2 || nargin > 3
    help(mfilename);
    error('Wrong number of input arguments!')
end


%% DEFINE DEPENDENCIES
% 
% 
% Get dependencies for features, cues and signals
DEP = define_Dependencies;

% Convert char to cell array
if ~iscell(listCues) && ~isempty(listCues) 
    listCues = {listCues};     
end
if ~iscell(listFeatures) && ~isempty(listFeatures)
    listFeatures = {listFeatures}; 
end

% Check if either cues or features are requested
if isempty(listCues) && isempty(listFeatures)
    msgCue  = verifyList(fieldnames(DEP.cues).',{});
    msgFeat = verifyList(fieldnames(DEP.features).',{});

    % List supported cues and features
    error('No CUES and no FEATURES selected! The following options are supported:\n\nCUES: %s \n\nFEATURES: %s',msgCue,msgFeat);
end

% Update cue list and feature list to consider all dependencies
[listFeatures,listCues,listSignals] = updateSigCueFeatList(listFeatures,listCues,DEP);

% STATES parameter struct
STATES = struct('SET',SET,'DEP',DEP,'signals',[],'cues',[],'features',[]);


%% CONFIGURE GENERAL PARAMETERS
% 
% 
% Short-cut
fsHz    = SET.fsHz;
fLowHz  = SET.fLowHz;
fHighHz = SET.fHighHz;
nErbs   = SET.nErbs;
bAlign  = SET.bAlign;

% Hair cell parameters
ihcMethod = SET.ihcMethod;

% Framing parameters
wSizeSec = SET.winSizeSec;
hSizeSec = SET.hopSizeSec;


%% CONFIGURE SIGNAL EXTRACTION  
% 
% 
% Number of signals to compute
nSignals = numel(listSignals);

% Array of structs for cue settings 
SIGNALS = repmat(cell2struct({[] [] [] [] [] []},...
          {'domain' 'fsHz' 'fHandle' 'dependency' 'dim' 'set'},2),[nSignals 1]);

% Loop over the number of cues
for ii = 1 : nSignals

    % Empty settings structure
    S = struct;
    
    % Initialize signal name
    S.domain = listSignals(ii);
    
    % Initialize signal dependencies
    S.dependency = DEP.signals.(S.domain{:});
    
    % Select cue
    switch lower(listSignals{ii})
        case 'time'
            S.fHandle       = 'process_EarSignals';
            S.dim           = {'nSamples x [left right]'};
            S.fsHz          = fsHz;
            
            S.set.bRemoveDC = true;
            S.set.bNormRMS  = true;
                        
        case 'gammatone'
            S.fHandle       = 'process_Gammatone';
            S.dim           = {'nSamples x nFilters x [left right]'};
            S.fsHz          = fsHz;            
            
            S.set.paramGT   = gammaFIR(S.fsHz,fLowHz,fHighHz,nErbs,bAlign);
            
        case 'innerhaircell'
            S.fHandle       = 'process_InnerHairCell';
            S.dim           = {'nSamples x nFilters x [left right]'};
            S.fsHz          = fsHz;            

            S.set.ihcMethod = ihcMethod;
            
        case 'crosscorrelation'
            S.fHandle       = 'process_CrossCorrelation';
            S.dim           = {'nLags x nFrames x nFilters'};
            S.fsHz          = fsHz;            
    
            S.set.wSizeSec  = wSizeSec;
            S.set.hSizeSec  = hSizeSec;
            S.set.winType   = 'rectwin';
            
            S.set.maxDelaySec = SET.maxDelaySec;

        case 'autocorrelation'
            S.fHandle       = 'process_AutoCorrelation';
            S.dim           = {'nLags x nFrames x nFilters x [left right]'};
            S.fsHz          = fsHz;            
            
            S.set.wSizeSec  = wSizeSec;
            S.set.hSizeSec  = hSizeSec;
            S.set.winType   = 'rectwin';
            
            S.set.bBandpass   = true;
            S.set.K           = 2;
            S.set.bCenterClip = false;
            S.set.ccMethod    = 'clc';
            S.set.ccAlpha     = 0.68;
             
        otherwise
            error('%s: SIGNAL ''%s'' is not supported.',mfilename,listSignals{ii})
    end
    
    % Store ii-th cue settings
    SIGNALS(ii) = copyFields(SIGNALS(ii),S);
end

% Save signal structure
STATES.signals = SIGNALS;


%% CONFIGURE CUE EXTRACTION  
% 
% 
% Number of cues to compute
nCues = numel(listCues);

% Array of structs for cue settings 
C = repmat(cell2struct({[] [] [] [] [] []},...
           {'name' 'dependency' 'fHandle' 'set' 'unit' 'dim'},2),[nCues 1]);

% Loop over the number of cues
for ii = 1 : nCues

    % Empty settings structure
    S = struct;
    
    % Initialize cue name
    S.name = listCues(ii);
    
    % Initialize cue dependencies
    S.dependency = DEP.cues.(S.name{:});
    
    % Select cue
    switch lower(listCues{ii})
        case 'rms'
            % Frame-based RMS
            S.fHandle      = 'calcRMS';
            S.unit         = {'dB'};
            S.dim          = {'nFrames x [left right]'};
            
            S.set.bBinaural = true;
            S.set.wSizeSec  = wSizeSec;
            S.set.hSizeSec  = hSizeSec;
            S.set.winType   = 'hann';
            
        case 'synchrony'
            % Autocorrelogram
            S.fHandle      = 'calcSynchrony';
            S.unit         = {'magnitude'};
            S.dim          = {'nFilter x nFrames x [left right]'};

            S.set.fsHz     = fsHz;
            S.set.fRangeHz = [50 800];
                        
            S.set.wSize    = wSizeSec;
            S.set.hSize    = hSizeSec;
            S.set.winType  = 'rectwin';

            % Get gammatone center frequencies 
            S.set.fHz      = STATES.signals(strcmp([STATES.signals.domain],'gammatone')).set.paramGT.cfHz;
        
        case 'sacf'
            % Summary-auto correlation function
            S.fHandle      = 'calcSACF';
            S.unit         = {'magnitude'};
            S.dim          = {'nLags x nFrames x [left right]'};
       
        case 'ratemap_magnitude'
            % Ratemap
            S.fHandle      = 'calcRatemap';
            S.unit         = {'magnitude'};
            S.dim          = {'nFilter x nFrames x [left right]'};

            S.set.fsHz     = fsHz;
            S.set.decaySec = 8E-3;
            
            S.set.bBinaural   = true;
            S.set.bDownSample = false;
            S.set.scaling  = 'magnitude';
            S.set.wSizeSec = wSizeSec;
            S.set.hSizeSec = hSizeSec;
            S.set.winType  = 'rectwin';
            
            % Get gammatone center frequencies 
            S.set.fHz      = STATES.signals(strcmp([STATES.signals.domain],'gammatone')).set.paramGT.cfHz;
      
        case 'ratemap_power'
            % Ratemap
            S.fHandle      = 'calcRatemap';
            S.unit         = {'power'};
            S.dim          = {'nFilter x nFrames x [left right]'};

            S.set.fsHz     = fsHz;
            S.set.decaySec = 8E-3;
            
            S.set.bBinaural   = true;
            S.set.bDownSample = false;
            S.set.scaling  = 'power';
            S.set.wSizeSec = wSizeSec;
            S.set.hSizeSec = hSizeSec;
            S.set.winType  = 'rectwin';
            
            % Get gammatone center frequencies 
            S.set.fHz      = STATES.signals(strcmp([STATES.signals.domain],'gammatone')).set.paramGT.cfHz;
              
        case 'onset_strength'
            % Onset strength in dB
            S.fHandle      = 'calcOnsetStrength';
            S.unit         = {'dB'};
            
            S.set.bBinaural  = true;
            S.set.maxOnsetdB = 30;
            S.set.fsHz       = fsHz;
            S.set.decaySec   = 8E-3;
            S.set.wSizeSec   = wSizeSec;
            S.set.hSizeSec   = hSizeSec;
            S.set.winType    = 'rectwin';

            if S.set.bBinaural
                S.dim = {'nFilter x nFrames x [left right]'};
            else
                S.dim = {'nFilter x nFrames'};
            end
            
        case 'offset_strength'
            % Offset strength in dB
            S.fHandle      = 'calcOffsetStrength';
            S.unit         = {'dB'};
            
            S.set.bBinaural   = true;
            S.set.maxOffsetdB = 30;
            S.set.fsHz        = fsHz;
            S.set.decaySec    = 8E-3;
            S.set.wSizeSec    = wSizeSec;
            S.set.hSizeSec    = hSizeSec;
            S.set.winType     = 'rectwin';
                        
            if S.set.bBinaural
                S.dim = {'nFilter x nFrames x [left right]'};
            else
                S.dim = {'nFilter x nFrames'};
            end
            
        case 'itd_xcorr'
            % Interaural time difference
            S.fHandle      = 'calcITD';
            S.unit         = {'s'};
            S.dim          = {'nFilter x nFrames'};

            S.set.fsHz     = fsHz;
            
        case 'ic_xcorr'
            % Interaural correlation
            S.fHandle      = 'calcIC';
            S.unit         = {};
            S.dim          = {'nFilter x nFrames'};
            
        case 'ild'
            % Interaural level difference
            S.fHandle      = 'calcILD';
            S.unit         = {'dB'};
            S.dim          = {'nFilter x nFrames'};
            
            S.set.wSizeSec = wSizeSec;
            S.set.hSizeSec = hSizeSec;
            S.set.winType  = 'rectwin';
            
        case 'average_deviation'
            % Average deviation
            S.fHandle      = 'calcAverageDeviation';
            S.unit         = {};

            S.set.bBinaural = true;
            S.set.wSizeSec  = wSizeSec;
            S.set.hSizeSec  = hSizeSec;
            S.set.winType   = 'rectwin';
                        
            if S.set.bBinaural
                S.dim = {'nFilter x nFrames x [left right]'};
            else
                S.dim = {'nFilter x nFrames'};
            end
            
        otherwise
            error('%s: Cue ''%s'' is not supported.',mfilename,listCues{ii})
    end
    
    % Store ii-th cue settings
    C(ii) = copyFields(C(ii),S);
end

% Save cue structure
STATES.cues = C;


%% CONFIGURE FEATURE EXTRACTION  
% 
% 
% Number of features to compute
nFeatures = numel(listFeatures);

% Array of structs for feature settings 
F = repmat(cell2struct({[] [] [] [] [] []},...
           {'name' 'dependency' 'fHandle' 'set' 'unit' 'dim'},2),...
           [nFeatures 1]);

% Loop over the number of features
for ii = 1 : nFeatures

    % Empty settings structure
    S = struct;
    
    % Initialize feature name
    S.name = listFeatures(ii);
    
    % Initialize feature dependencies
    S.dependency = DEP.features.(S.name{:});
    
    % Select cue
    switch lower(listFeatures{ii})
        
        case 'azimuth'
            % Map ITD to azimuth
            S.fHandle       = 'process_ITD2Azim_Lookup';
            S.unit          = {'degree'};
            S.dim           = {'nFilter x nFrames'};
                        
            set.rootDir     = [pwd,filesep,'WP2_Data',filesep];
            set.fsHz        = fsHz;

            set.rangeSource = (-90:5:90).';
            set.rangeAzim   = (-90:5:90).';
            set.average     = 'median';
            
            S.set.mapping   = init_ITD2Azim_Lookup(STATES,set);
            
            S.set.bFitPoly  = false;
            S.set.polyOrder = 11;

        case 'azimuth_hist'
            % Azimuth histogram
            S.fHandle       = 'calcAzimuthHist';
            S.unit          = {'degree'};
            S.dim           = {'nAzimuth x 1'};
                        
%             S.set.azimuth       = (-180:5:180).';
            S.set.azimuth       = (-90:5:90).';
            
            S.set.bCueSelection = true;
            S.set.thresIC       = 0.95;

        case 'source_position'
            % Estimate source position based on azimuth histogram
            S.fHandle       = 'estSourceAzimuth';
            S.unit          = {'degree'};
            S.dim           = {'nSources x [azimuth salience]'};
                        
            S.set.nSources  = inf;
            
        case 'ratemap_feature'
            % Ratemap feature
            S.fHandle       = 'calcRatemapFeatures';
            S.unit          = {};
                        
            S.set.compress  = 'cuberoot';
            S.set.normalize = 'meanvar';
            S.set.bBinaural = true;
            
            if S.set.bBinaural
                S.dim = {'nFilter x nFrames x [left right]'};
            else
                S.dim = {'nFilter x nFrames'};
            end
            
        case 'pitch'
            % Pitch estimation based on SACF
            S.fHandle       = 'estPitch_SACF';
            S.unit          = {'Hz'};
            S.dim           = {'nFrames x [left right] x [pitch confidence]'};
                        
            S.set.fsHz      = fsHz;
            S.set.fRangeHz  = [50 400];
            S.set.medFilt   = 5;
            S.set.confThres = 0.33;
           
        otherwise
            error('%s: Feature ''%s'' is not supported.',mfilename,listFeatures{ii})
    end

    % Store ii-th feature settings
    F(ii) = copyFields(F(ii),S);
end

% Save feature structure
STATES.features = F;

