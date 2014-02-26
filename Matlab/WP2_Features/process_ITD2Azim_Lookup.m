function [azim,SET] = process_ITD2Azim_Lookup(CUE,SET)

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
if nargin ~= 2
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Determine input size
[nFilter,nFrames] = size(CUE.data);

% Allocate memory
azim = zeros(nFilter,nFrames);


%% MAP ITD TO AZIMUTH
% 
% 
% % Loop over number of auditory filters
% for ii = 1 : nFilter
%     % Fit polynomial
%     [p,S,MU] = polyfit(P.set.mapping.azimuth,P.set.mapping.itd(:,ii),P.set.polyOrder);
%     itdPolyTemplate(:,ii)  = polyval(p,P.set.mapping.azimuth,S,MU);
% end


% % Loop over number of auditory filters
% for ii = 1 : nFilter
%     % Fit polynomial
%     if P.set.bFitPoly
%         [p,S,MU] = polyfit(P.set.mapping.azimuth,P.set.mapping.itd(:,ii),P.set.polyOrder);
%         itdPoly  = polyval(p,P.set.mapping.azimuth,S,MU);
%         
%         % Warp cross-correlation function from ITD to azimuth
%         azim(ii,:) = interp1(itdPoly,P.set.mapping.azimuth,CUE.data(ii,:));
%     else
%         % Warp cross-correlation function from ITD to azimuth
%         azim(ii,:) = interp1(P.set.mapping.itd(:,ii),P.set.mapping.azimuth,CUE.data(ii,:));
%     end
% end


% HAGEN's version
% 
% Loop over number of auditory filters
for ii = 1 : nFilter
    if SET.bFitPoly
        [p,S,MU] = polyfit(SET.mapping.itd(:,ii),SET.mapping.azimuth,SET.polyOrder);
        azim(ii,:) = polyval(p,CUE.data(ii,:),S,MU);
    else
        azim(ii,:) = interp1(SET.mapping.itd(:,ii),SET.mapping.azimuth,CUE.data(ii,:));
    end
end

azim(azim > max(SET.mapping.azimuth)) = NaN;
azim(azim < min(SET.mapping.azimuth)) = NaN;


% % Loop over the number of files
%     for jj = 1 : nFilter
%         % Interpolate to 'rangeAzInterp'
%         itd2AzimInterp(:,jj) = interp1(azimRange,itd2Azim(:,jj),set.rangeAzim);
%         
%         % Ensure that mapping is monotonic by using a polynomial fit
%         itd2AzimPoly(:,jj) = polyval(polyfit(set.rangeAzim,itd2AzimInterp(:,jj).',set.polyOrder),set.rangeAzim);
%     end
    