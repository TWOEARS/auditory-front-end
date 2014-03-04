function env = ihcenvelope(input,fs,method)
% 
%USAGE
%    env = ihcenvelope(periphery,fs,method)
%
%INPUT PARAMETERS
% 
%OUTPUT PARAMETERS
% 

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to:
%   
%   Authors :  Tobias May © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
% 
%   History :  
%   v.0.1   2014/02/21
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin ~= 3
    help(mfilename);
    error('Wrong number of input arguments!')
end


%% INNER HAIR CELL PROCESSING
% 
% 
% Select method
switch lower(method)
    case {'' 'nothing' false}
        env = input;
        
    case 'halfwave'
        % Half-wave rectification
        env = max(input,0);
        
    case 'fullwave'
        % Full-wave rectification
        env = abs(input);
        
    case 'square'
        env = abs(input).^2;
        
    case 'hilbert'
        env = abs(hilbert(input));
        
    case 'joergensen'
        cutoffHz = 150;
        [b, a]   = butter(1, cutoffHz * 2 / fs);
        
        env = filter(b,a,abs(hilbert(input)));
        
    case 'dau'
        cutoffHz = 1000;
        [b, a]   = butter(2, cutoffHz * 2 / fs);
        
        % Half-wave rectification
        env = max(input,0);
        
        % LP filter
        env = filter(b,a,env);
        
    case 'breebart'
        cutoffHz = 2000;
        [b, a]   = butter(1, cutoffHz * 2 / fs);
        
        % Half-wave rectification
        env = max(input,0);
        
        % LP filter
        for ii = 1 : 5; env = filter(b,a,env); end
        
    case 'bernstein'
        cutoffHz = 425;
        [b, a]   = butter(2, cutoffHz * 2 / fs);
        
        env = max(abs(hilbert(input)).^(-.77).*input,0).^2;
        
        % LP filter
        env = filter(b,a,env);
    otherwise
        error('%s: Method is not supported!',upper(mfilename))
end