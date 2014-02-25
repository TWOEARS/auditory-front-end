function [newList,newDep] = updateFeatureList(listFeat,allFeat,dependencies)

% Update feature list to consider proper order of processing

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/23
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 3
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Check if all features are supported
msg = verifyList(listFeat,allFeat);

if ~isempty(msg)
    error('FEATURES %s are not supported.',msg);
end
      
nElements = numel(listFeat);
bDep      = zeros(nElements,1);

for ii = 1 : nElements

    cellElement = dependencies{selectCells(allFeat,listFeat{ii})};
    
    % Check if all dependencies are supported
    if ~isempty(cellElement)
        msg = verifyList(cellElement,allFeat);
        
        if ~isempty(msg)
           error('DEPENDENCIES %s are not supported.',msg);
        end
    end
    
    bDep(ii) = length(cellElement);
end

% Potentially too large, trim afterwards
newList = cell(1,nElements+sum(bDep));
newDep  = repmat(cell(1),[1 nElements+sum(bDep)]);

% All features without dependencies
idxNoDependencies = find(~bDep);

% Loop over number of features without dependencies
for ii = 1 : numel(idxNoDependencies)
    newList{ii} = listFeat{idxNoDependencies(ii)};
    newDep{ii}  = dependencies{selectCells(allFeat,newList{ii})};
end

% All features with dependencies
idxDependencies = find(bDep);

% Initialize counter
iter = 1 + sum(~bDep);

% Loop over number of features with dependencies
for ii = 1 : numel(idxDependencies)
    
    % Add dependencies
    currDep = dependencies{selectCells(allFeat,listFeat{idxDependencies(ii)})};

    for jj = 1 : numel(currDep)
        newList{iter} = currDep{jj};
        newDep{iter}  = dependencies{selectCells(allFeat,newList{iter})};
        % TODO: Check if newDep exists in the new list! If not, add it
        iter          = iter + 1;
    end
    
    % Add actual feature
    newList{iter} = listFeat{idxDependencies(ii)};
    newDep{iter}  = dependencies{selectCells(allFeat,newList{iter})};
end

bKeep = false(numel(newList),1);

% Delete empty cells
for ii = 1 : numel(newList)
    if isempty(newList{ii})
        bKeep(ii) = false;
    else
        bKeep(ii) = true;
    end
end

% Remove double entries
[tmp,uqiIdx] = unique(newList(bKeep));
uniqueIdx    = sort(uqiIdx,'ascend');

% Final list
newList = newList(uniqueIdx);
newDep  = newDep(uniqueIdx);