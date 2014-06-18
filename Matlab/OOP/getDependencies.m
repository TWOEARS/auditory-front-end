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
        
    case 'gammatone'
        dep = {'time'};
        
    case 'innerhaircell'
        dep = {'gammatone'};
        
    case 'crosscorrelation'
        dep = {'innerhaircell'};
     
    case 'autocorrelation'
        dep = {'innerhaircell'};
        
    % Cues
    case 'rms'
        dep = {'time'};
        
     case 'ratemap_magnitude'
        dep = {'innerhaircell'};
    
    case 'ratemap_power'
        dep = {'innerhaircell'};
        
    case 'itd_xcorr'
        dep = {'crosscorrelation'};
        
    case 'ic_xcorr'
        dep = {'crosscorrelation'};
        
    case 'ild'
        dep = {'innerhaircell'};
        
    case 'average_deviation'
        dep = {'innerhaircell'};
        
    case 'onset_strength'
        dep = {'ratemap_power'};
        
    case 'offset_strength'
        dep = {'ratemap_power'};
        
    case 'synchrony'
        dep = {'autocorrelation'};
        
    case 'sacf'
        dep = {'autocorrelation'};
        
    % Features
    case 'ratemap_feature'
        dep = {'ratemap_magnitude'};
        
    case 'azimuth'
        dep = {'itd_xcorr'};
        
    case 'azimuth_hist'
        dep = {'azimuth' 'ic_xcorr'};
        
    case 'source_position'
        dep = {'azimuth_hist'};
        
    case 'pitch'
        dep = {'sacf'};
        
    case 'valid'     % Dummy name to list all currently valid names
        dep = {'time' 'gammatone' 'innerhaircell' 'crosscorrelation' ...
            'autocorrelation' 'rms' 'ratemap_magnitude' 'ratemap_power' ...
            'itd_xcorr' 'ic_xcorr' 'ild' 'average_deviation' ...
            'onset_strength' 'offset_strength' 'synchrony' 'sacf' ...
            'ratemap_feature' 'azimuth' 'azimuth_hist' 'source_position'...
            'pitch'};
        
    case 'available'    % Lists all currently implemented processors
         dep = {'time' 'gammatone' 'innerhaircell' 'crosscorrelation' ...
             'autocorrelation' 'ratemap_magnitude' 'ratemap_power' 'ild' ...
             'itd_xcorr' 'ic_xcorr'};
        
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


