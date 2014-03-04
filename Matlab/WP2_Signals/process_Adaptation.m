function [data,SET] = process_Adaptation(data,SET)
%process_Adaptation   Adaptation loops.
% 
%USAGE
%   [data,SET] = process_Adaptation(data,SET)
%
%INPUT PARAMETERS
%       data : input signal [nSamples x nFilters x 2]
%        SET : settings initialized by init_WP2
% 
%OUTPUT PARAMETERS
%       data : processed input signal [nSamples x nFilter x 2]

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May, Nicolas Le Goff © 2013,2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%              nlg@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/26
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 2
    help(mfilename);
    error('Wrong number of input arguments!')
end


%% NEURAL ADAPTATION
%
%   load minlim.mat; % table of min vals
%         MinSig=zeros(length(MidEarSig),nchannels);
%         for n = 1 : size(fc,2)
%             [~,lookupnum] = min(abs(minlim(:,1) - fc(n)));
%             MinSig(:,n) = max(ExpSig(:,n),minlim(lookupnum,2));
%         end
%   output = AdaptLoops(MinSig,fs,10,2e-7,[0.005 0.050 0.129 0.253 0.500]);
