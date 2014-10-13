function [b,a,bw] = createFB_Mod(fs,cfMod,Q,bDown2DC,bUp2Nyquist)


%   Developed with Matlab 8.3.0.532 (R2014a). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2014
%              Technical University of Denmark (DTU)
%              tobmay@elektro.dtu.dk
%
%   History :
%   v.0.1   2013/07/06
%   v.0.2   2014/07/10 incorporated flag "bUp2Nyquist"
%   ***********************************************************************


%% ***********************  CHECK INPUT ARGUMENTS  ************************
% 
% 
% Check for proper input arguments
if nargin < 1 || nargin > 5
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default values
if nargin < 5 || isempty(bUp2Nyquist); bUp2Nyquist = false;      end
if nargin < 4 || isempty(bDown2DC);    bDown2DC    = true;       end
if nargin < 3 || isempty(Q);           Q           = 1;          end
if nargin < 2 || isempty(cfMod);       cfMod       = pow2(0:10); end


% ==============================
% Modulation filterbank settings
% ==============================
% 
% 
% Order of low-pass filter
nLP = 1;

% Order of band-pass filter
nBP = 2;

% Number of modulation filter
nFilter = numel(cfMod);

% Replicate Q
if isscalar(Q)
    Q = repmat(Q,[nFilter 1]);
else
    if nFilter ~= numel(Q)
        error('Q factor and cfMod must be of equal size.')
    end
end

% Allocate memory
[w0,bw,f1,f2] = deal(zeros(nFilter,1));
[b,a]         = deal(cell(nFilter,1));
wn            = zeros(nFilter,2);

% Loop over number of modulation filters
for ii = 1 : nFilter
    
    % Center frequency (0,1), whereas 1 => fs/2
    w0(ii) = cfMod(ii)/(fs/2);
    
    % Check if center frequency is valid
    if w0(ii) >= 1
        error('Center frequencies must be smaller than fs/2')
    end
    
    % Filter bandwidth
    bw(ii) = w0(ii) / Q(ii);

    % Passband frequencies 
    f1(ii) = cfMod(ii) * (sqrt(1+(1/(4*Q(ii)^2))) - (1/(2*Q(ii))));
    f2(ii) = cfMod(ii) * (sqrt(1+(1/(4*Q(ii)^2))) + (1/(2*Q(ii))));

    % Passband frequencies (0,1), whereas 1 => fs/2
    wn(ii,:) = [f1(ii) f2(ii)]/(fs/2);

    % Check if passband frequencies wn(ii,:) are valid
    if any(wn(ii,:) >= 1)
        error('Passband frequencies must be smaller than fs/2')
    end
    
    % Derive filter coefficients
    if ii == 1 && bDown2DC
        [b{ii},a{ii}] = butter(nLP,w0(ii),'low');
    elseif ii == nFilter && bUp2Nyquist
        [b{ii},a{ii}] = butter(nLP,w0(ii),'high');
    else
        % Filter order is 2 * nBP, thus / 2 
        [b{ii},a{ii}] = butter(nBP/2,wn(ii,:),'bandpass');
    end
end

% Plot filter transfer function
if nargout == 0 
    
    fnts = 12;
    lineWidth = 2;
    strCol = {[0 0 0 ] [0.45 0.45 0.45]};
    figure; hold on;
    for ii = 1:nFilter
        [TF,freqs] = freqz(b{ii},a{ii},96E3,fs);
        plot(freqs,20*log10(abs(TF)),'linewidth',lineWidth,'color',strCol{1+mod(ii-1,2)});
    end
    
    set(gca,'xscale','log')
    title('Modulation filterbank')
    xlabel('Frequency (Hz)','FontSize',fnts)
    ylabel('Filter attenuation (dB)','FontSize',fnts)
    xlim([0 max(400,4*max(cfMod))])
    ylim([-20 5])
end
