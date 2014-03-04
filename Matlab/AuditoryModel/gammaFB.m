function [out, env] = gammaFB(in, fs, G)

% Check for proper input arguments
if nargin < 2 || nargin > 3
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default parameter
if nargin < 3 || isempty(G); G = gammaFIR(fs,100,8E3); end

% Ensure input is a column vector
in = in(:); 

% Determine length of input signal
nSamples = length(in);

% Find maximum delay
maxDelay = max(G.delay);

% Zero-padding
in = [in(:); zeros(maxDelay,1)];

% Filter input signal using FFTFILT
bm = fftfilt(G.IR,repmat(in,1,G.nFilter));

% Basilar membrane displacement
if G.bAlign
    % Allocate memory
    out = zeros(nSamples,G.nFilter);
    
    % Align channels
    for ii = 1:nFilter
        out(:,ii) = bm(G.delay(ii)+1:end-(maxDelay-G.delay(ii)),ii);
    end
else
    out = bm;
end

% Envelope
if nargout > 1
   env = abs(hilbert(out)); 
end