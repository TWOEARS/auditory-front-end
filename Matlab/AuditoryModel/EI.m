function z = EI( l, r , fs , tau , alpha)
% ==========================================================
% ei.m: single EI-cell output as a function of time
%
% Usage: y = ei( l , r, fs, tau, alpha)
%
% l,r	    : input signals, these must be a [n by 1] matrix
% fs        : sampling rate of input signals
% tau       : characteristic delay in seconds (positive: left is leading)
% alfa       : characteristic IID in dB (positive: left is louder)
%
% y	        : EI-type cell output as a function of time

% parameters:
tc          = 30e-3;            % Temporal smoothing constant

% Calibration
a           = 0.1;           % RHO=0.64
b           = 0.0001;         % RHO=1

% apply characteristic ITD:
n = round( abs(tau) * fs );
if tau > 0,    
    l = [ones(n,1).*l(1) ; l(1:end-n)];
else
    r = [ones(n,1).*r(1) ; r(1:end-n)];    
end

% apply characteristic IID:
l = l + alpha/2;
r = r - alpha/2;

% compute instanteneous EI output:
x = (l - r).^2;

%keyboard
%% temporal smoothing:
A=[1 -exp(-1/(fs*tc))];
B=1-exp(-1/(fs*tc));
y= filtfilt(B,A,x);


%% binaural compression
z = a * log( b * y + 1);