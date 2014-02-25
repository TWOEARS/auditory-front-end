function [out,STATES] = process_Periphery(earsignals,STATES)
%
%USAGE
%   [out,STATES] = PeripheralProcessing(earsignals,STATES)
%
%INPUT PARAMETERS
%   earsignals : binaural signals [nSamples x 2]
%       STATES : settings initialized by init_WP2
% 
%OUTPUT PARAMETERS
%          out : Peripheral internal representations [nSamples x nFilter x 2]

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May, Nicolas Le Goff © 2013,2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%              nlg@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/01/31
%   v.0.2   2014/02/24 added STATES to output (for block-based processing)
%   ***********************************************************************


%% 1. CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 2
    help(mfilename);
    error('Wrong number of input arguments!')
end

% error('%s: The input signal must be numeric.',upper(mfilename));

% Determine size of input
[nSamples,nChannels] = size(earsignals);

% Short-cut to gammatone struct
GT   = STATES.signals.periphery.gammatone;
IHC  = STATES.signals.periphery.ihc;
fsHz = STATES.signals.fsHz;

% Allocate memory
out = zeros(nSamples,GT.nFilter,nChannels);
% out.env   = zeros(nSamples,P.gammatone.nFilter,nChannels);
% out.adapt = zeros(nSamples,P.gammatone.nFilter,nChannels);


%% 2. DECOMPOSE INPUT INTO INDIVIDUAL FREQUENCY CHANNELS
% 
% 
% Gammatone filtering
out(:,:,1) = gammaFB(earsignals(:,1),fsHz,GT);
out(:,:,2) = gammaFB(earsignals(:,2),fsHz,GT);


%% 3. EXTRACT INNER HAIR CELL ENVELOPE
%
% 
% Hair cell processing
out(:,:,1) = ihcenvelope(out(:,:,1),fsHz,IHC.method);
out(:,:,2) = ihcenvelope(out(:,:,2),fsHz,IHC.method);


%% 4. NEURAL ADAPTATION
%
%   load minlim.mat; % table of min vals
%         MinSig=zeros(length(MidEarSig),nchannels);
%         for n = 1 : size(fc,2)
%             [~,lookupnum] = min(abs(minlim(:,1) - fc(n)));
%             MinSig(:,n) = max(ExpSig(:,n),minlim(lookupnum,2));
%         end
%   output = AdaptLoops(MinSig,fs,10,2e-7,[0.005 0.050 0.129 0.253 0.500]);