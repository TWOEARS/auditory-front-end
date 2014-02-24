function STATES = init_WP2(SET,listCues,listFeat)
%init_WP2   Initialize parameters for WP2 processing
%
%USAGE
%      STATES = init_WP2(STATES,listCues,listFeat)
%
%INPUT PARAMETERS
%       STATES : settings
%     listCues : list of cues to be extracted
%     listCues : list of features to be extracted
%OUTPUT PARAMETERS
%     STATES : 

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
%   v.0.3   2014/02/22 added dependencies
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin < 2 || nargin > 3
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Convert char to cell array
if ~iscell(listCues); listCues = {listCues}; end
if ~iscell(listFeat); listFeat = {listFeat}; end


%% DEFINE DEPENDENCIES
% 
% 
% List of supported features
allFeatures = {'ratemap' 'azimuth' 'azimuth_hist' 'source_position'};
% List of feature dependencies
allDepend   = {{}         {}        {'azimuth'}   {'azimuth_hist'}};

% Re-organize feature list to consider proper order of processing
[listFeat,listDep] = updateFeatureList(listFeat,allFeatures,allDepend);
[listFeat,listDep] = updateFeatureList(listFeat,allFeatures,allDepend);


%% INITIALIZE SIGNAL PARAMETERS
% 
% 
% STATES parameter struct
STATES = struct('signal',[],'cues',[],'features',[]);

% Signal parameters
signal = struct('fsHz',SET.fsHz,'bNormRMS',SET.bNormRMS,...
                'periphery',[],'xcorr',[],'framing',[]);

% Short-cut
fsHz    = SET.fsHz;
fLowHz  = SET.fLowHz;
fHighHz = SET.fHighHz;
nErbs   = SET.nErbs;
bAlign  = SET.bAlign;

% Gammatone parameters 
signal.periphery.gammatone = gammaFIR(fsHz,fLowHz,fHighHz,nErbs,bAlign);

% Hair cell parameters
signal.periphery.ihc.method = SET.ihcMethod;

% Framing parameters
signal.framing.winSize = 2 * round(SET.winSizeSec * fsHz / 2);
signal.framing.hopSize = 2 * round(SET.hopSizeSec * fsHz / 2);
signal.framing.winType = SET.winType;
signal.framing.window  = window(SET.winType,signal.framing.winSize);

% Maximum time delay in seconds that is evaluated
signal.xcorr.maxLag = ceil(SET.maxDelaySec * fsHz);


%% CONFIGURE CUE EXTRACTION  
% 
% 
% Number of cues to compute
nCues = numel(listCues);

% Array of structs for cue settings 
C = repmat(cell2struct({[] [] [] [] [] []},...
           {'name' 'domain' 'fHandle' 'set' 'unit' 'dim'},2),[nCues 1]);

% Loop over the number of cues
for ii = 1 : nCues

    % Empty settings structure
    S = struct;
    
    % Select cue
    switch lower(listCues{ii})
        
        case 'rms'
            % Frame-based RMS
            S.name         = {'RMS'};
            S.domain       = 'time';
            S.fHandle      = 'calcRMS';
            S.unit         = {'dB'};
            S.dim          = {'nFrames x [left right]'};
            
            S.set.wSize    = signal.framing.winSize;
            S.set.hSize    = signal.framing.hopSize;
            S.set.win      = signal.framing.window;
            
        case 'ratemap'
            % Ratemap
            S.name         = {'ratemap'};
            S.domain       = 'periphery';
            S.fHandle      = 'calcRatemap';
            S.unit         = {'magnitude'};
            S.dim          = {'nFilter x nFrames x [left right]'};

            S.set.fsHz     = fsHz;
            S.set.decaySec = 10E-3;
            S.set.wSize    = signal.framing.winSize;
            S.set.hSize    = signal.framing.hopSize;
            S.set.winType  = 'rectwin';
            
        case 'itd_xcorr'
            % Binaural cues according to [1]
            S.name         = {'itd'};
            S.domain       = 'crosscorrelation';
            S.fHandle      = 'calcITD';
            S.unit         = {'s'};
            S.dim          = {'nFilter x nFrames'};

            S.set.fsHz     = fsHz;
            
        case 'ic_xcorr'
            % Binaural cues according to [1]
            S.name         = {'ic'};
            S.domain       = 'crosscorrelation';
            S.fHandle      = 'calcIC';
            S.unit         = {''};
            S.dim          = {'nFilter x nFrames'};
            
        case 'ild'
            S.name         = {'ild'};
            S.domain       = 'periphery';
            S.fHandle      = 'calcILD';
            S.unit         = {'dB'};
            S.dim          = {'nFilter x nFrames'};
            
            S.set.wSize    = signal.framing.winSize;
            S.set.hSize    = signal.framing.hopSize;
            S.set.winType  = 'rectwin';
            
        otherwise
            error('%s: Cue ''%s'' is not supported.',mfilename,listCues{ii})
    end
    
    % Store ii-th cue settings
    C(ii) = copyFields(C(ii),S);
end

% Copy cue structure
STATES.signal = signal;
STATES.cues   = C;


%% CONFIGURE FEATURE EXTRACTION  
% 
% 
% Number of features to compute
nFeatures = numel(listFeat);

% Array of structs for feature settings 
F = repmat(cell2struct({[] [] [] [] [] [] []},...
           {'name' 'cue' 'feature' 'fHandle' 'set' 'unit' 'dim'},2),...
           [nFeatures 1]);

% Loop over the number of features
for ii = 1 : nFeatures

    % Empty settings structure
    S = struct;
    
    % Select cue
    switch lower(listFeat{ii})
        
        case 'azimuth'
            % Map ITD to azimuth
            S.name          = {lower(listFeat{ii})};
            S.cue           = {'itd'};
            S.feature       = listDep{ii};
            S.fHandle       = 'estimateAzimuth_Lookup';
            S.unit          = {'degree'};
            S.dim           = {'nFilter x nFrames'};
                        
            set.rootDir     = [pwd,filesep,'Data',filesep];
%             set.rangeSource = (-180:5:180).';
%             set.rangeAzim   = (-180:1:179).';
            set.rangeSource = (-90:5:90).';
            set.rangeAzim   = (-90:1:90).';
            set.average     = 'median';
            
            S.set.mapping   = calibrate_ITD(STATES,set);
            
            S.set.bFitPoly  = true;
            S.set.polyOrder = 11;
            

        case 'azimuth_hist'
            % Azimuth histogram
            S.name          = {lower(listFeat{ii})};
            S.cue           = {'ic'};
            S.feature       = listDep{ii};
            S.fHandle       = 'calcAzimuthHist';
            S.unit          = {'degree'};
            S.dim           = {'nAzimuth x 1'};
                        
            S.set.azimuth       = (-180:5:180).';
            S.set.azimuth       = (-90:5:90).';
            
            S.set.bCueSelection = false;
            S.set.thresIC       = 0.95;
            
%             S.set.bSelectChan   = false;
%             S.set.cfHz          = STATES.signal.periphery.gammatone.cfHz;
%             S.set.thresFreq     = 2500;

        case 'source_position'
            % Estimate source position based on azimuth histogram
            S.name          = {lower(listFeat{ii})};
            S.cue           = {};
            S.feature       = listDep{ii};
            S.fHandle       = 'estSourceAzimuth';
            S.unit          = {'degree'};
            S.dim           = {'nSources x [azimuth salience]'};
                        
            S.set.nSources  = inf;
            
        case 'ratemap'
            % Ratemap feature
            S.name          = {lower(listFeat{ii})};
            S.cue           = {'ratemap'};
            S.feature       = listDep{ii};
            S.fHandle       = 'calcRatemapFeatures';
            S.unit          = {''};
                        
            S.set.compress  = 'cuberoot';
            S.set.normalize = 'meanvar';
            S.set.bBinaural = true;
            
            if S.set.bBinaural
                S.dim = {'nFilter x nFrames x [left right]'};
            else
                S.dim = {'nFilter x nFrames'};
            end
            
        otherwise
            error('%s: Feature ''%s'' is not supported.',mfilename,listFeat{ii})
    end
    
    % Verify that requried cues are selected
    if ~isempty(S.cue)
        msg = verifyList(S.cue,[STATES.cues.name]);
        
        if ~isempty(msg)
            error('%s: %s cue is required for %s extraction.',mfilename,msg,S.name{:});
        end
    end
    
    % Store ii-th feature settings
    F(ii) = copyFields(F(ii),S);
end

% Copy feature structure
STATES.features = F;

% TODO: If cue request is empty, automatically determine cue list based on
% feature listing

