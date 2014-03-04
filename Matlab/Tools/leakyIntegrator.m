function [out,states] = leakyIntegrator(in,fs,decaySec,states)
%leakyIntegrator   Apply leaky integration.
%
%USAGE
%      [OUT,STATES] = integrator(DATA,FS,TAU,STATES)
%
%INPUT ARGUMENTS
%     DATA : input data [nSampels x nChannels]
%       FS : sampling frequency of input data in Hertz
%      TAU : time constant of leaky integrator in seconds
%   STATES : filter states [1 x nChannels] 
%            (default, STATES = zeros(1,nChannels))
%
%OUTPUT ARGUMENTS
%      OUT : output data [nSamples x nChannels]
%   STATES : integrator filter states [1 x nChannels]

%   Developed with Matlab 7.5.0.342 (R2007b). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2007-2008 
%              TUe Eindhoven and Philips Research  
%              t.may@tue.nl      tobias.may@philips.com
%
%   History :   
%   v.0.1   2008/07/29
%   v.0.2   2009/05/17 added 3Dim input support
%   ***********************************************************************


% Check for proper input arguments
errMessage = nargchk(2,4,nargin);

% Display error message
if ~isempty(errMessage); 
    % Display help file with html link ... or conventional help message
    if   exist('showHelp.m','file'); showHelp(mfilename); 
    else help(mfilename); end
    % Display error message
    error(errMessage); 
end

% Set default values
if nargin < 4 || isempty(states);
    dim = size(in); states = zeros([1 dim(2:end)]); 
end    
if nargin < 3 || isempty(decaySec); decaySec = 8e-3; end

% Check dimension of filter states 
% if ~isequal(length(states),size(in,2))
%     error('Filter states dimension mismatch!')
% end

% Filter deacy
intDecay = exp(-(1/(fs*decaySec)));
% Integration gain
intGain = 1-intDecay;

% Apply integration filter
[out,states] = filter(intGain, [1 -intDecay], in, states);