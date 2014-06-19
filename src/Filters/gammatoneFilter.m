classdef gammatoneFilter < filterObj
    
    properties
        CenterFrequency     % Center frequency for the filter (Hz)
        FilterOrder         % Gammatone slope order
        IRtype              % 'FIR' or 'IIR'
        IRduration          % Duration of the impulse response for truncation (s)
        delay               % Delay in samples for time alignment
    end   
    
    methods
        function obj = gammatoneFilter(cf,fs,type,n,bwERB,do_align,durSec)
            %gammatoneFilter    Construct a gammatone filter object
            %
            %USAGE
            %           F = gammatoneFilter(fc,fs)
            %           F = gammatoneFilter(fc,fs,type,n,bw,do_align,durSec)
            % 
            %INPUT ARGUMENTS
            %          cf : center frequency of the filter (Hz)
            %          fs : sampling frequency (Hz)
            %        type : 'fir' for finite impulse response or 'iir' for
            %               infinite (default: type = 'fir')
            %           n : Gammatone rising slope order (default, n=4)
            %          bw : Bandwidth of the filter in ERBS 
            %               (default: bw = 1.08 ERBS) 
            %    do_align : If true, applies phase compensation and compute
            %               delay for time alignment (default : false)
            %      durSec : Duration of the impulse response in seconds 
            %               (default: durSec = 0.128)
            %
            %OUTPUT
            %           F : Gammatone filter object
            
            % TO DO : Instantiating an IIR gammatone filter should not
            % populate the IRDuration property
            % TO DO : Add more code commenting/references for 'iir' case
            
            if nargin > 0   % Prevent error when constructors is called 
                            %   without arguments
                % Check for input arguments
                if nargin < 2 || nargin > 7
                    error('Wrong number of input arguments')
                end
                
                % Set default parameters
                if nargin < 7 || isempty(durSec)
                    durSec = 0.128;
                end
                if nargin < 6 || isempty(do_align)
                    do_align = false;
                end
                if nargin < 5 || isempty(bwERB)
                    bwERB = 1.018;
                end
                if nargin < 4 || isempty(n)
                    n = 4;
                end
                if nargin < 3 || isempty(type)
                    type = 'FIR';
                end
                
                % One ERB value in Hz at this center frequency
                ERBHz = 24.7 + 0.108 * cf;

                % Bandwidth of the filter in Hertz
                bwHz = bwERB * ERBHz;
                
                switch type
                    case 'FIR'
                        
                        % Phase and delay compensation
                        if do_align
                            % Time delay in seconds
                            delaySec = (n-1)/(2*pi*bwHz);
                            % Time delay in samples
                            delaySpl = round(delaySec*fs);

                            % Phase compensation factor
                            phase = -2 * pi * cf * delaySec;
                        else
                            delaySpl = 0;
                            phase = 0;
                        end

                        % Impulse response duration in samples
                        N = 2^nextpow2(durSec*fs);

                        % Time vector for impulse response computation
                        t = (0:N-1)'/fs;

                        % Gammatone envelope
                        env = t.^(n-1).*exp(-2*pi*t*bwHz)/(fs/2);

                        % Full impulse response
                        b = env.*cos(2*pi*t*cf+phase);
                        
                        % Normalization constant
                        a = 6./(-2*pi*bwHz).^4;
                        
                        % The transfer function is real-valued
                        realTF = true;
                        
                    case 'IIR'
                        
                        btmp=1-exp(-2*pi*bwHz/fs);
                        atmp=[1, -exp(-(2*pi*bwHz + 1i*2*pi*cf)/fs)];

                        b=1;
                        a=1;

                        for jj=1:n
                          b=conv(btmp,b);
                          a=conv(atmp,a);
                        end
                        
                        delaySpl = 0;
                        
                        % The transfer function is complex-valued
                        realTF = false;
                        
                        
                    otherwise
                        error('Specified gammatone impulse response type is invalid')
                end
                
                % Populate filter Object properties
                %   1- Global properties
                obj = populateProperties(obj,'Type','Gammatone Filter',...
                    'Structure','Direct-Form II Transposed','FsHz',fs,...
                    'b',b,'a',a,'RealTF',realTF);
                %   2- Specific properties
                obj.CenterFrequency = cf;
                obj.FilterOrder = n;
                obj.IRduration = durSec;
                obj.delay = delaySpl;
                obj.IRtype = type;
                
            end
        end
        
    end
end
    