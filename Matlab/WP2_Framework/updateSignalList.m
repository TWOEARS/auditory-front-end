function listSignalsOrder = updateSignalList(listCues,DEP)

listSignals = cell(size(listCues));

for ii = 1 : numel(listCues);
    listSignals{ii} = DEP.cues.(listCues{ii}){2};
end


listSignals = [listSignals{:}];

listSignals = unique(listSignals);


nSignals = numel(listSignals);

nIterS = 1;
newSig = {};

% Import feature-related dependencies
for ii = 1 : nSignals
    
    currSigFeat = DEP.signals.(listSignals{ii});
    
    if isempty(currSigFeat) || any(strcmp(newSig,currSigFeat))
        bIterS = false;
    else
        bIterS = true;
    end
    
    while bIterS
        
        idxNewS = [];
        
        for ff = 1 : numel(currSigFeat)
            
            newSig{nIterS} = currSigFeat{ff};
            
            idxNewS = [idxNewS; nIterS];
            
            nIterS = nIterS + 1;
        end
        
        newSigDep = newSig(idxNewS);
        
        if isempty(newSigDep)
            bIterS = false;
        else
            currSigFeat = {};
            % Get new dependencies
            for ff = 1 : numel(newSigDep)
                currSigFeat = DEP.signals.(newSigDep{ff});
            end
            
            if isempty(currSigFeat) || any(strcmp(newSig,currSigFeat))
                bIterS = false;
            end
        end
    end
end

listSignals = [listSignals newSig];

listSignals = unique(listSignals);


% Organize signals according to their dependencies
listSignalsOrder = cell(size(listSignals));

% Find independent feature
nIter = 0;
for ii = 1 : numel(listSignals)
    if isempty(DEP.signals.(listSignals{ii})) || strcmp(listSignals{ii},DEP.signals.(listSignals{ii}))
        nIter = nIter + 1;
        listSignalsOrder{nIter} = listSignals{ii};
    end
end

listSignals = setdiff(listSignals,listSignalsOrder(1:nIter));

while ~isempty(listSignals)
    % Select feature where its dependency is already on the list
    for ii = 1 : numel(listSignals)
        if any(strcmp(listSignalsOrder(1:nIter),DEP.signals.(listSignals{ii})))
            nIter = nIter + 1;
            listSignalsOrder{nIter} = listSignals{ii};
        end
    end
    listSignals = setdiff(listSignals,listSignalsOrder(1:nIter));
end

