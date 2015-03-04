function dep = getDependencies(sig,depth)
%getDependencies    Provides a list of dependencies needed to extract the
%                   signal sig
%
%USAGE
%           dep = getDependencies(sig)
%           dep = getDependencies(sig,depth)
%
%INPUT ARGUMENTS
%           sig : Signal, cue or feature label
%         depth : Specifies the level of dependency: 'direct' for
%                 first-order dependency only, 'full' for a complete
%                 recursive list (default: depth = 'full')
%
%OUTPUT ARGUMENTS
%           dep : cell array of signal, cue or feature labels on which 
%                 sig depends
%
% TO DO: Need to be upgraded if a new feature that has more than two direct
% dependencies is introduced.

if nargin<2 || isempty(depth); depth = 'full';end

switch sig
    
    % Signals first
    case 'time'
        dep = {'time'};
        
%     case 'framedSignal'
%         dep = {'time'};
        
    case 'filterbank'
        dep = {'time'};
        
    case 'innerhaircell'
        dep = {'filterbank'};
        
    case 'adaptation'
        dep = {'innerhaircell'};
        
    case 'ams_features'
        dep = {'innerhaircell'};
        
    case 'crosscorrelation'
        dep = {'innerhaircell'};
     
    case 'autocorrelation'
        dep = {'innerhaircell'};
                
    % Cues
    case 'rms'
        dep = {'time'};
        
     case 'ratemap'
        dep = {'innerhaircell'};
        
    case 'itd'
        dep = {'crosscorrelation'};
        
    case 'ic'
        dep = {'crosscorrelation'};
        
    case 'ild'
        dep = {'innerhaircell'};
        
    case 'average_deviation'
        dep = {'innerhaircell'};
        
    case 'onset_strength'
        dep = {'ratemap'};
        
    case 'offset_strength'
        dep = {'ratemap'};
        
    case 'synchrony'
        dep = {'autocorrelation'};
        
    % Features
%     case 'crosscorrelation_feature'
%         dep = {'crosscorrelation'};

    case 'spectral_features'
        dep = {'ratemap'};
        
    case 'onset_map'
        dep = {'onset_strength'};
        
    case 'offset_map'
        dep = {'offset_strength'};
        
    case 'pitch'
        dep = {'autocorrelation'};
        
    case 'gabor'
        dep = {'ratemap'};
        
    case 'valid'     % Dummy name to list all currently valid names
        dep = {'time' 'filterbank' 'innerhaircell' 'adaptation' 'ams_features' ...
            'crosscorrelation' 'autocorrelation' 'rms' 'ratemap' ...
            'itd' 'ic' 'ild' ...
            'onset_strength' 'offset_strength' 'onset_map' 'offset_map' ...
            'spectral_features' ...
            'pitch' 'gabor'};

        
    case 'available'    % Lists all currently implemented processors
         dep = {'time' 'filterbank' 'innerhaircell' 'adaptation' 'ams_features' 'crosscorrelation' ...
             'autocorrelation' 'ratemap' 'ild' ...
             'itd' 'ic' 'spectral_features'  ...
             'onset_strength' 'offset_strength' 'pitch' 'onset_map' 'offset_map' 'gabor'};

        
    % Otherwise it's not in the list, generate a list of valid names
    otherwise
        list = getDependencies('available');
        str = [];
        for ii = 1:size(list,2)-1
            str = [str list{ii} ', '];
        end
        str =[str list{end} '.'];
        error(['The label for the signal/cue/feature requested is '...
            'unknown. The valid labels are %s'],str)
end

if strcmp(depth,'full')
    % Add sub-dependencies by recursion
    % TO DO: Do this in a more elegant way for multiple dependencies
    if ~strcmp(dep{1},'time')   % Stop the recursion for time-domain signal
        if size(dep,2)==1
            dep = [dep getDependencies(dep{1})];
        elseif size(dep,2)==2
            % List the higher dependent variables first to maintain
            % computational order
            dep = [dep{1} dep{2} getDependencies(dep{1}) getDependencies(dep{2})];
        end
    end

    % Remove redundant signal/cue/feature by intersecting the dependency list
    % with itself. 'stable' maintains original order.
    dep = intersect(dep,dep,'stable');
end  
    
end


