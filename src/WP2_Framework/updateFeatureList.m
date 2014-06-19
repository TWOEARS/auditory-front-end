function newListOrder = updateFeatureList(listFeat,DEP)

nFeatures = numel(listFeat);

nIterF = 1;
newFeat = {};
newFeatDep = {};

% Import feature-related dependencies
for ii = 1 : nFeatures
    
    currDepFeat = DEP.features.(listFeat{ii}){1};
    
    if isempty(currDepFeat) || any(strcmp(newFeatDep,currDepFeat))
        bIterF = false;
    else
        bIterF = true;
    end
    
    while bIterF
        
        idxNewF = [];
        
        for ff = 1 : numel(currDepFeat)
            
            newFeat{nIterF} = currDepFeat{ff};
            
            idxNewF = [idxNewF; nIterF];
            
            nIterF = nIterF + 1;
        end
        
        newFeatDep = newFeat(idxNewF);
        
        if isempty(newFeatDep)
            bIterF = false;
        else
            currDepFeat = {};
            % Get new dependencies
            for ff = 1 : numel(newFeatDep)
                currDepFeat = DEP.features.(newFeatDep{ff}){1};
            end
            
            if isempty(currDepFeat) || any(strcmp(newFeatDep,currDepFeat))
                bIterF = false;
            end
        end
    end
end

newList = [listFeat newFeat];

newList = unique(newList);

% Organize features according to their dependencies
newListOrder = cell(size(newList));

% Find independent feature
nIter = 0;
for ii = 1 : numel(newList)
    if isempty(DEP.features.(newList{ii}){1})
        nIter = nIter + 1;
        newListOrder{nIter} = newList{ii};
    end
end

newList = setdiff(newList,newListOrder(1:nIter));

while ~isempty(newList)
    % Select feature where its dependency is already on the list
    for ii = 1 : numel(newList)
        if any(strcmp(newListOrder(1:nIter),DEP.features.(newList{ii}){1}))
            nIter = nIter + 1;
            newListOrder{nIter} = newList{ii};
        end
    end
    newList = setdiff(newList,newListOrder(1:nIter));
end

