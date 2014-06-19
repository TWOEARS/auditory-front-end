function inoutsig = envextract(inoutsig,fs,cutofffreq,order)
%ENVEXTRACT   Extract envelope of input signal
%   Usage:  outsig=envextract(insig,fs);
%
%   ENVEXTRACT(insig,fs,cutoff) extract the envelope of an input signal
%   insig sampled with a sampling frequency of fs Hz. The envelope
%   extraction is performed by half-wave rectification followed by low pass
%   filtering to a a cutoff frequency specified by the parameter cutofffreq.
%
%   ENVEXTRACT(insig,fs) does the same assuming a cutoff frequency of 1000 Hz.
%   
%   This method is described in XXX
%

% Copyright (C) 2009 CAHR.
% This file is part of CASP version 0.01
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% ------ Checking of input parameters --------------------------------

% error(nargchk(2,4,nargin));

% if nargin==2
%   cutofffreq=1000;
%   order =2;
% end;

% if ~isnumeric(inoutsig)
%   error('%s: The input signal must be numeric.',upper(mfilename));
% end;
% 
% if ~isnumeric(fs) || ~isscalar(fs) || fs<=0
%   error('%s: fs must be a positive scalar.',upper(mfilename));
% end;
% 
% if ~isnumeric(cutofffreq) || ~isscalar(cutofffreq) || cutofffreq<0
%   error('%s: cutofffreq must be a non-negative scalar.',upper(mfilename));
% end;

% ------ Computation -------------------------------------------------
  
% Calculate filter coefficients for the low-pass filtering following
% half-wave rectification. 2nd order butterworth
[b, a] = butter(order, cutofffreq*2/fs);


% 'haircell' envelope extraction. Part 1: Half-wave rectification
inoutsig = max( inoutsig, 0 );
  
% 'haircell' envelope extraction. Part 2: Low-pass filtering
inoutsig = filter(b,a, inoutsig);
