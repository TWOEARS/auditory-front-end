function out = PeripheralProcessing(earsignals,fs,P)
%
%USAGE
%        out = PeripheralProcessing(earsignals,fs,P)
%
%INPUT PARAMETERS
% earsignals : binaural signals [nSamples x 2]
%         fs : sampling frequency in Hertz
%          P : peripheral parameter structure (initialized by init_WP2.m)
% 
%OUTPUT PARAMETERS
%        out : Peripheral internal representations [nSamples x nFilter x 2]

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May, Nicolas Le Goff © 2013,2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%              nlg@elektro.dtu.dk
%              
% 
%   History :  
%   v.0.1   2014/01/31
%   ***********************************************************************


%% 1. CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 3
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Determine size of input
[nSamples,nChannels] = size(earsignals);


%% 2. DECOMPOSE INPUT INTO INDIVIDUAL FREQUENCY CHANNELS
% 
% 
if P.bCompute
    % Allocate memory
    out = zeros(nSamples,P.gammatone.nFilter,nChannels);
    
    % Gammatone filtering
    
    out(:,:,1) = gammaFB(earsignals(:,1),fs,P.gammatone);
    out(:,:,2) = gammaFB(earsignals(:,2),fs,P.gammatone);
else
    out = permute(earsignals,[1 3 2]);
end

%% 3. HAIRCELL TRANSDUCTON
%
% EnvExtSig = EnvExtract(FiltSig,fs,1000,2);


%% 4. NEURAL ADAPTATION
%
%   load minlim.mat; % table of min vals
%         MinSig=zeros(length(MidEarSig),nchannels);
%         for n = 1 : size(fc,2)
%             [~,lookupnum] = min(abs(minlim(:,1) - fc(n)));
%             MinSig(:,n) = max(ExpSig(:,n),minlim(lookupnum,2));
%         end
%   output = AdaptLoops(MinSig,fs,10,2e-7,[0.005 0.050 0.129 0.253 0.500]);
