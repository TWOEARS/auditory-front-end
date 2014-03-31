function newListOrder = updateCueList(listFeat,listCues,DEP)

% Get all feature-related cue dependencies
newCues = cell(size(listFeat));

for ii = 1 : numel(listFeat);
    newCues{ii} = DEP.features.(listFeat{ii}){2};
end

newCues = [newCues{:}];

newList = [listCues newCues];

newList = unique(newList);

nCues = numel(newList);

nIterC = 1;
newCue = {};
newCueDep = {};

% Import cue-related dependencies
for ii = 1 : nCues
    
    currDepCue = DEP.cues.(newList{ii}){1};
    
    if isempty(currDepCue) || any(strcmp(newCueDep,currDepCue))
        bIterC = false;
    else
        bIterC = true;
    end
    
    while bIterC
        
        idxNewC = [];
        
        for cc = 1 : numel(currDepCue)
            
            newCue{nIterC} = currDepCue{cc};
            
            idxNewC = [idxNewC; nIterC];
            
            nIterC = nIterC + 1;
        end
        
        newCueDep = newCue(idxNewC);
        
        if isempty(newCueDep)
            bIterC = false;
        else
            currDepCue = {};
            % Get new dependencies
            for cc = 1 : numel(newCueDep)
                currDepCue = DEP.cues.(newCueDep{cc}){1};
            end
            
            if isempty(currDepCue) || any(strcmp(newCueDep,currDepCue))
                bIterC = false;
            end
        end
    end
end

newList = [newList newCue];

newList = unique(newList);

% Organize cues according to their dependencies
newListOrder = cell(size(newList));

% Find independent cues
nIter = 0;
for ii = 1 : numel(newList)
    if isempty(DEP.cues.(newList{ii}){1})
        nIter = nIter + 1;
        newListOrder{nIter} = newList{ii};
    end
end

newList = setdiff(newList,newListOrder(1:nIter));

while ~isempty(newList)
    % Select cues where its dependency is already on the list
    for ii = 1 : numel(newList)
        if any(strcmp(newListOrder(1:nIter),DEP.cues.(newList{ii}){1}))
            nIter = nIter + 1;
            newListOrder{nIter} = newList{ii};
        end
    end
    newList = setdiff(newList,newListOrder(1:nIter));
end

