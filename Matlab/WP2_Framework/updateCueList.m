function newList = updateCueList(listFeat,listCues,DEP)

newCues = cell(size(listFeat));

for ii = 1 : numel(listFeat);
    newCues{ii} = DEP.features.(listFeat{ii}){2};
end

newCues = [newCues{:}];

newList = [listCues newCues];

newList = unique(newList);