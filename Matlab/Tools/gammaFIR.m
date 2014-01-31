% [out, env, cfHz] = gammaFB(in, fs, flow, fhigh, nERBs, bAlign)
%
% Calculates gammatone filters for defined frequency range [flow fhigh] and
% filters the input signal. The impulse responses of the filters are
% normalized such that the peak of the magnitude frequency response is 1 /
% 0dB. 
%
% ----------------------------     INPUTS:     ------------------------------
% in            ...input signal vector
% fs            ...sampling rate
% flow          ...scalar specifying the lowest filter center frequency
% fhigh         ...scalar specifying the highest filter center frequency
% nERBs         ...scalar specifying the number of filters per ERB
% bAlign        ...if true, the temporal outputs will be time-aligned
%
% ----------------------------     OUTPUTS:     ------------------------------
% out           ...length(in) x length(cfHz) matrix containing temporal outputs
%                   of the filterbank
% env           ...length(in) x length(cfHz) matrix containing envelope outputs
%                   of the filterbank
% cfHz          ...center frequencies of the filterbank, in Hertz
function P = gammaFIR(fs, flow, fhigh, nERBs, bAlign)

% Check for proper input arguments
if nargin < 3 || nargin > 5
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default parameter
if nargin < 5 || isempty(bAlign); bAlign = false; end
if nargin < 4 || isempty(nERBs);  nERBs  = 1;     end

% ERBs vector, with a spacing of nERBs
ERBS = freq2erb(flow):double(nERBs):freq2erb(fhigh); 

% Conversion from ERB to Hz
cfHz = erb2freq(ERBS);			 

% Number of gammatone filters
nFilter = numel(cfHz);      

% Gammatone filter order
n = 4;        

% Rectangular bandwidth of the auditory filter
ERB = 24.7 + 0.108 * cfHz;      

% Parameter determining the duration of the IR (bandwidth)
b = 1.018 * ERB;              

% Normalization constant
a = 6./(-2*pi*b).^4;        

% Phase compensation
if bAlign
    % Time delay
    tc = (n-1)./(2*pi*b);
    
    % Phase compensation factor
    phase = -2 * pi * cfHz .* tc;
    
    % Integer delay
    delay = round(tc.*fs);
else
    phase = zeros(1,nFilter);
    delay = zeros(1,nFilter);
end

% Restrict Gammatone impulse response for efficient computation.
% Instead of re-computing the IR for every audio signal, the
% impulse response could also be pre-computed.
lengthIRSec = 128E-3;

% Number of IR samples
N = 2^nextpow2(lengthIRSec*fs);

% Time vector
t = (0:N-1)'/fs;

tm  = repmat(t,1,nFilter);
am  = repmat(a,N,1);
bm  = repmat(b,N,1);
fcm = repmat(cfHz,N,1);
Env = (tm.^(n-1))./am.*exp(-2*pi*tm.*bm) / (fs/2);
IR  = Env.*cos(2*pi*tm.*fcm+repmat(phase,N,1));

% Create output structure
P = struct('label','gammatone parameter structure','fs',fs,...
           'flow',flow,'fhigh',fhigh,'nERBs',nERBs,'nFilter',nFilter,...
           'order',n,'bAlign',bAlign,'lengthIRSec',lengthIRSec,...
           'cfHz',cfHz,'delay',delay,'IR',IR);
