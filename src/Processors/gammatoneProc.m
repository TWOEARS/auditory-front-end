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
    
    properties (Dependent = true)
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
        function pObj = gammatoneProc(fs,parObj)
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
            
            if nargin<2; parObj = Parameters; end
            if nargin<1; fs = []; end
            
            % Call super-constructor
            pObj = pObj@Processor(fs,fs,'gammatoneProc',parObj);
            
            if nargin>0
                % Instantiate filters
                pObj.Filters = pObj.populateFilters;
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
        
        function verifyParameters(pObj)
            % This method extends the list of parameters by computing the values of the
            % missing ones
            
            % Add missing parameter values
            pObj.extendParameters;
            
            % Solve the conflicts between center frequencies, number of channels, and
            % distance between channels
            if ~isempty(pObj.parameters.map('cfHz'))
                % Highest priority case: a vector of channels center 
                %   frequencies is provided
                centerFreq = pObj.parameters.map('cfHz');
                
                pObj.parameters.map('f_low') = centerFreq(1);
                pObj.parameters.map('f_high') = centerFreq(end);
                pObj.parameters.map('nChannels') = numel(centerFreq);
                pObj.parameters.map('nERBs') = 'n/a';
                
                
            elseif ~isempty(pObj.parameters.map('nChannels'))
                % Medium priority: frequency range and number of channels
                %   are provided
               
                % Build a vector of center ERB frequencies
                ERBS = linspace( freq2erb(pObj.parameters.map('f_low')), ...
                                freq2erb(pObj.parameters.map('f_high')), ...
                                pObj.parameters.map('nChannels') );  
                centerFreq = erb2freq(ERBS);    % Convert to Hz
                
                pObj.parameters.map('nERBs') = (ERBS(end)-ERBS(1)) ...
                                                / pObj.parameters.map('nChannels');
                pObj.parameters.map('cfHz') = centerFreq;
                
                
            else
                % Lowest (default) priority: frequency range and distance 
                %   between channels is provided (or taken by default)
                
                % Build vector of center ERB frequencies
                ERBS = freq2erb(pObj.parameters.map('f_low')): ...
                                double(pObj.parameters.map('nERBs')): ...
                                            freq2erb(pObj.parameters.map('f_high'));
                centerFreq = erb2freq(ERBS);    % Convert to Hz
                
                pObj.parameters.map('nChannels') = numel(centerFreq);
                pObj.parameters.map('cfHz') = centerFreq;
                
            end
            
        end
        
    end
    
    % "Getter" methods
    methods
        function cfHz = get.cfHz(pObj)
            cfHz = pObj.parameters.map('cfHz');
        end
        
        function nERBs = get.nERBs(pObj)
            nERBs = pObj.parameters.map('nERBs');
        end
        
        function nGamma = get.nGamma(pObj)
            nGamma = pObj.parameters.map('n_gamma');
        end
        
        function bwERBs = get.bwERBs(pObj)
            bwERBs = pObj.parameters.map('bwERBs');
        end
        
        function lowFreqHz = get.lowFreqHz(pObj)
            lowFreqHz = pObj.parameters.map('f_low');
        end
        
        function highFreqHz = get.highFreqHz(pObj)
            highFreqHz = pObj.parameters.map('f_high');
        end
        
    end
    
    
    methods (Access = private)
        function obj = populateFilters(pObj)
            % This function is a workaround to assign an array of objects
            % as one of the processor's property, should remain private

            fs = pObj.FsHzIn;
            cfHz = pObj.parameters.map('cfHz');
            n = pObj.parameters.map('n_gamma');
            bw = pObj.parameters.map('bwERBs');
            bAlign = pObj.parameters.map('bAlign');
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