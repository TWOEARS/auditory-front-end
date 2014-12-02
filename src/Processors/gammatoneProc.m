classdef gammatoneProc < Processor
%GAMMATONEPROC Gammatone auditory filterbank processor.
%   The Gammatone filterbank models the frequency selectivity of the peripheral auditory
%   system according following [1]. It operates on a time-domain signal and returns a
%   time-frequency representation of the signal. 
%
%   GAMMATONEPROC properties:
%       cfHz       - Channels center frequencies (Hz)
%       nERBs      - Distance between neighboring filters in ERBS (see [1])
%       nGamma     - Gammatone order of the filters (2 or 4)
%       bwERBs     - Bandwidth of the filters in ERBs (see [1])
%       lowFreqHz  - Requested center frequency of lowest channel (Hz)
%       highFreqHz - Requested approximate center frequency of highest channel (Hz)
%
%   There are three different ways of setting up a vector of channel center frequencies
%   (cfHz) when instantiating this processor:
%       1- By providing the lower and upper center frequencies (lowFreqHz and highFreqHz),
%          and the distance between neighboring filters (nERBs).
%       2- By providing the lower and upper center frequencies (lowFreqHz and highFreqHz),
%          and the number of channels that the representation should have.
%       3- By directly providing a vector of center frequencies (cfHz).
%   In case of conflicting arguments, cfHz is generated from one of the three method above
%   with priority order 3 > 2 > 1.
%
%   See also: Processor, drnlProc
%
%   Reference:
%   [1] Glasberg, B.R. and Moore, B.C.J. (1990), "Derivation of auditory filter shapes
%       from notched-noise data", Hearing Research 47(1-2), pp. 103-138.
    
    properties
        cfHz            % Filters center frequencies
        nERBs           % Distance between neighboring filters in ERBs
        nGamma          % Gammatone order of the filters
        bwERBs          % Bandwidth of the filters in ERBs
        lowFreqHz       % Lowest center frequency used at instantiation
        highFreqHz      % Highest center frequency used at instantiation
    end
    
    properties (GetAccess = private)
        Filters         % Array of filter objects
    end
        
    methods
        function pObj = gammatoneProc(fs,flow,fhigh,nERBs,nChan,cfHz,bAlign,...
                                        n,bw)
            %gammatoneProc      Construct a gammatone filterbank inheriting
            %                   the "processor" class
            %
            %USAGE
            % -Minimal usage, either (in order of priority)
            %   pObj = gammatoneProc(fs,[],[],[],[],cfHz)
            %   pObj = gammatoneProc(fs,flow,fhigh,[],nChan)
            %   pObj = gammatoneProc(fs,flow,fhigh,nERBs)
            %   pObj = gammatoneProc(fs,flow,fhigh)
            %
            % -Additional arguments:
            %   pObj = gammatoneProc(...,irType,bAlign,n,bw,dur)
            %
            %INPUT ARGUMENTS
            %     fs : Sampling frequency (Hz)
            %   flow : Lowest center frequency for the filterbank (in Hz)
            %  fhigh : Highest center frequency for the filterbank (in Hz)
            %  nERBs : Distance in ERBS between neighboring center
            %          frequencies (default: nERBS = 1)
            %  nChan : Number of channels
            %   cfHz : Vector of channels center frequencies
            %
            % irType : 'FIR' to generate finite impulse response Gammatone
            %          filters or 'IIR' for infinite (default: 'FIR')
            % bAlign : Set to true for phase correction and time alignment
            %          between channels (default: bAlign = false)
            %      n : Filter order (default: n = 4)
            %     bw : Bandwidth of the filters in ERBS 
            %          (default: bw = 1.08 ERBS)
            %    dur : Duration of the impulse response in seconds 
            %          (default: dur = 0.128)
            %
            %OUTPUT ARGUMENTS
            %   pObj : Processor object
            
            % TODO: 
            %  - Implement solution to allow for different impulse response
            %    durations for different filters (if necessary)
            %  - Implement bAlign option
            
            if nargin>0  % Failsafe for constructor calls without arguments
            
            % Checking input arguments
            if nargin < 3 || nargin > 9
                help(mfilename);
                error('Wrong number of input arguments!')
            end
            
            % Set default optional parameter
            if nargin < 7 || isempty(bAlign); bAlign = false; end
            if nargin < 8 || isempty(n); n = 4; end
            if nargin < 9 || isempty(bw); 
                bw = (factorial(n-1))^2/(pi*factorial(2*n-2)*2^(-(2*n-2)));
            end
            
            % Parse mandatory arguments: three scenarios
            
            if ~isempty(cfHz)
                % 3- A vector of channels center frequencies is provided
                
                % Do nothing, we already have a vector of center
                % frequencies in Hz
                
                
            elseif ~isempty(flow)&&~isempty(fhigh)&&~isempty(nChan)
                % 2- Frequency range and number of channels is provided
                
                % Give a warning if conflicting properties were specified
%                 if ~isempty(nERBs)
%                     warning(['Conflicting parameters were provided for '...
%                         'the Gammatone filterbank instantiation. The '...
%                         'filterbank will be generated from the provided'...
%                         ' frequency range and number of channels.']) 
%                 end
                
                % Get vector of center frequencies
                ERBS = linspace(freq2erb(flow),freq2erb(fhigh),nChan);  % In ERBS
                cfHz = erb2freq(ERBS);                                  % In Hz
                
            elseif ~isempty(flow)&&~isempty(fhigh)&&isempty(nChan)&&isempty(cfHz)
                % 3- Frequency range and distance between channels is provided
                
                % Set distance between two channel to default is unspecified
                if nargin < 4 || isempty(nERBs);  nERBs  = 1;     end
                
                % Get vector of center frequencies
                ERBS = freq2erb(flow):double(nERBs):freq2erb(fhigh);    % In ERBS
                cfHz = erb2freq(ERBS);                                  % In Hz
                
            else
                % Else, something is missing in the input
                error('Not enough or incoherent input arguments.')
            end
            
            
            % Number of gammatone filters
            nFilter = numel(cfHz); 
            
            % Instantiating the filters
            pObj.Filters = pObj.populateFilters(cfHz,fs,n,bw,bAlign);
            
            % Setting up additional properties
            % 1- Global properties
            populateProperties(pObj,'Type','Gammatone filterbank',...
                'FsHzIn',fs,'FsHzOut',fs);
            % 2- Specific properties
            pObj.cfHz = cfHz;
            pObj.nERBs = nERBs;
            pObj.nGamma = n;
            pObj.bwERBs = bw;
            pObj.lowFreqHz = flow;
            pObj.highFreqHz = fhigh;
            
            end
        end
        
        function out = processChunk(pObj,in)
            %processChunk       Passes an input signal through the
            %                   Gammatone filterbank
            %
            %USAGE
            %       out = processChunk(pObj,in)
            %       out = pObj.processChunk(in)
            %
            %INPUT ARGUMENTS
            %      pObj : Gammatone filterbank object
            %        in : One-dimensional array containing the input signal
            %
            %OUTPUT ARGUMENTS
            %       out : Multi-dimensional array containing the filterbank
            %             outputs
            %
            %SEE ALSO:
            %       gammatoneProc.m
            
            % TO DO: Indicate that this function is not buit to deal with
            % multiple channels. Multiple channels should be treated with
            % multiple instances of the filterbank.
            
            % Check inputs
            if min(size(in))>1
                error('The input should be a one-dimensional array')
            end
            
            % Turn input into column vector
            in = in(:);
            
            % Get number of channels
            nFilter = size(pObj.Filters,2);
            
            % Pre-allocate memory
            out = zeros(length(in),nFilter);
            
            % Loop on the filters
            for ii = 1:nFilter
                out(:,ii) = pObj.Filters(ii).filter(in);
            end
            
            % TO DO : IMPLEMENT ALIGNMENT CORRECTION
            
        end
        
        function reset(pObj)
            %reset          Order the processor to reset its internal
            %               states, e.g., when some critical parameters in
            %               the processing have been changed
            %USAGE
            %       pObj.reset()
            %       reset(pObj)
            %
            %INPUT ARGUMENT
            %       pObj : Processor object
            
            nFilter = size(pObj.Filters,2);
            
            % Resetting the internal states of the filters
            for ii = 1:nFilter
                pObj.Filters(ii).reset();
            end
            
        end
        
        function hp = hasParameters(pObj,p)
            %hasParameters  This method compares the parameters of the
            %               processor with the parameters given as input
            %
            %USAGE
            %    hp = pObj.hasParameters(p)
            %
            %INPUT ARGUMENTS
            %  pObj : Processor instance
            %     p : Structure containing parameters to test
            
            %NB: Could be moved to private
            
            % There are three ways to initialize a gammatone filterbank, of
            % which only the center frequencies of the channel is in
            % common. Hence only this parameter is checked regarding
            % channel positionning.
            
            p_list = {'fb_cfHz','fb_nGamma','fb_bwERBs'};
            p_list_proc = {'cfHz','nGamma','bwERBs'};
            
            % The center frequency position needs to be computed for
            % scenario where it is not explicitely provided
            if isempty(p.fb_cfHz)&&~isempty(p.fb_nChannels)
                ERBS = linspace(freq2erb(p.fb_lowFreqHz),freq2erb(p.fb_highFreqHz),p.fb_nChannels);    % In ERBS
                p.fb_cfHz = erb2freq(ERBS);                                              % In Hz
            elseif isempty(p.fb_cfHz)&&isempty(p.fb_nChannels)
                ERBS = freq2erb(p.fb_lowFreqHz):double(p.fb_nERBs):freq2erb(p.fb_highFreqHz);   % In ERBS
                p.fb_cfHz = erb2freq(ERBS);                                       % In Hz
            end
            
            
            % Initialization of a parameters difference vector
            delta = zeros(size(p_list,2),1);
            
            % Loop on the list of parameters
            for ii = 1:size(p_list,2)
                try
                    if size(pObj.(p_list_proc{ii}))==size(p.(p_list{ii}))
                        delta(ii) = max(abs(pObj.(p_list_proc{ii}) - p.(p_list{ii})));
                    else
                        delta(ii) = 1;
                    end
                    
                catch err
                    % Warning: something is missing
                    warning('Parameter %s is missing in input p.',p_list{ii})
                    delta(ii) = 1;
                end
            end
            
            % Check if delta is a vector of zeros
            if max(delta)>0
                hp = false;
            else
                hp = true;
            end
            
        end  
        
    end
    
    methods (Access = private)
        function obj = populateFilters(pObj,cfHz,fs,n,bw,bAlign)
            % This function is a workaround to assign an array of objects
            % as one of the processor's property, should remain private

            nFilter = numel(cfHz);
            
            % Preallocate memory by instantiating last filter
            obj(1,nFilter) = gammatoneFilter(cfHz(nFilter),fs,n,...
                                        bw,bAlign);
            % Instantiating remaining filters
            for ii = 1:nFilter-1
                obj(1,ii) = gammatoneFilter(cfHz(ii),fs,n,...
                                        bw,bAlign);
            end                        
            
        end
    end

    methods (Static)
        
        function dep = getDependency()
            dep = 'time';
        end
        
        function values = getParameterValues(request)
            %getParameterValues    Returns the default parameter values for
            %                      this processor, given a specific request
            %
            %USAGE:
            %  values = gammatoneProc.getParameterValues(request)
            %
            %INPUT ARGUMENTS:
            %     request : Structure of non-default requested parameter
            %                values. Returns default values if empty.
            %
            %OUTPUT ARGUMENTS:
            %      values : Map object of parameter values, indexed by
            %                parameter names
            
            if nargin<1 || isempty(request); request = []; end
            
            values = Processor.getParameterValues( 'gammatoneProc',...
                                                    request);
            
            % Because of the three different types of requests for
            % generating the filterbank, we need to ensure consistency of
            % the center frequencies-related parameters:
            
            if ~isempty(values('cfHz'))
                % Highest priority case: a vector of channels center 
                %   frequencies is provided
                centerFreq = values('cfHz');
                
                values('f_low') = centerFreq(1);
                values('f_high') = centerFreq(end);
                values('nChannels') = numel(centerFreq);
                values('nERBs') = 'n/a';
                
                
            elseif ~isempty(values('nChannels'))
                % Medium priority: frequency range and number of channels
                %   are provided
               
                % Build a vector of center ERB frequencies
                ERBS = linspace( freq2erb(values('f_low')), ...
                                freq2erb(values('f_high')), ...
                                values('nChannels') );  
                centerFreq = erb2freq(ERBS);    % Convert to Hz
                
                values('nERBs') = (ERBS(end)-ERBS(1))/values('nChannels');
                values('cfHz') = centerFreq;
                
                
            else
                % Lowest (default) priority: frequency range and distance 
                %   between channels is provided (or taken by default)
                
                % Build vector of center ERB frequencies
                ERBS = freq2erb(values('f_low')): ...
                                double(values('nERBs')): ...
                                            freq2erb(values('f_high'));
                centerFreq = erb2freq(ERBS);    % Convert to Hz
                
                values('nChannels') = numel(centerFreq);
                values('cfHz') = centerFreq;
                
            end
            
        end
        
        function [names, defaultValues, descriptions] = getParameterInfo()
            %getParameterInfo   Returns the parameter names, default values
            %                   and descriptions for that processor
            %
            %USAGE:
            %  [names, defaultValues, description] =  ...
            %                           gammatoneProc.getParameterInfo;
            %
            %OUTPUT ARGUMENTS:
            %         names : Parameter names
            % defaultValues : Parameter default values
            %  descriptions : Parameter descriptions
            
            
            names = {'f_low',...
                    'f_high',...
                    'nERBs',...
                    'nChannels',...
                    'cfHz',...
                    'IRtype',...
                    'n_gamma',...
                    'bwERBs',...
                    'durSec',...
                    'bAlign'};
            
            descriptions = {'Lowest center frequency (Hz)',...
                    'Highest center frequency (Hz)',...
                    'Distance between neighbor filters in ERBs',...
                    'Number of channels',...
                    'Channels center frequencies (Hz)',...
                    'Gammatone filter impulse response type (''IIR'' or ''FIR'')',...
                    'Gammatone rising slope order',...
                    'Bandwidth of the filters (ERBs)',...
                    'Duration of FIR (s)',...
                    'Correction for filter alignment'};
            
            defaultValues = {80,...
                            8000,...
                            1,...
                            [],...
                            [],...
                            'IIR',...
                            4,...
                            1.018,...
                            0.128,...
                            0};
                
        end
        
        function [name,description] = getProcessorInfo
            
            %Returns a very short name and a short description of the processor function
            name = 'Gammatone filterbank';
            description = 'Gammatone filterbank';
            
        end
        
    end
        
end