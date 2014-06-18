function azEst = selectAzimuth(azimuth,salience,nSources)

% Rank evidence
[salience,newIdx] = sort(salience,'descend'); %#ok

% Restrict number of ITD estimates
nEst = min(numel(newIdx),nSources);

% Azimuth estimate
azEst = azimuth(newIdx(1:nEst));