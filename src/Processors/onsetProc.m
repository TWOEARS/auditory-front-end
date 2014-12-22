classdef onsetProc < Processor
%ONSETPROC Onset processor.
%   The onset processor detects the signal onsets by measuring the
%   frame-based increase in the energy of the ratemap representation, and
%   computes the onset strength as a function of time frame and frequency
%   channel [1,2].
%
%   ONSETPROC properties:
%       maxOnsetdB      - Upper limit for onset strength in dB
%
%   See also: Processor, ratemapProc, offsetProc
%
%   Reference:
%   [1] Bregman, A. S. (1990), Auditory scene analysis: The perceptual 
%       organization of sound, the MIT Press, Cambridge, MA, USA.
%   [2] Klapuri, A. (1999), "Sound onset detection by applying psychoacoustic 
%       knowledge," in Proceedings of the IEEE International Conference on 
%       Acoustics, Speech and Signal Processing (ICASSP), pp. 3089-3092.   
    
    properties (SetAccess = protected)
        maxOnsetdB      % Upper limit for onset value
    end
    
    properties (GetAccess = private)
        buffer          % Buffered last frame of the previous chunk
    end
    
    methods
        function pObj = onsetProc(fs,p)
            %onsetProc      Instantiates an onset detector
            %
            %USAGE:
            %       pObj = onsetProc(fs,p)
            %
            %INPUT ARGUMENTS:
            %  fs : Sampling frequency (Hz)
            %   p : Non-default parameters
            %
            %OUTPUT ARGUMENTS:
            %       pObj : Processor instance
            
            if nargin>0
                
            if nargin<2||isempty(p)
                p = getDefaultParameters(fs,'processing');
            else
                p.fs = fs;
                p = parseParameters(p);
            end
                
            pObj.Type = 'Onset detection';
            pObj.FsHzIn = fs;
            pObj.FsHzOut = fs;
            pObj.maxOnsetdB = p.ons_maxOnsetdB;
            
            % Initialize an empty buffer
            pObj.buffer = [];
            
            end
            
        end
        
        function out = processChunk(pObj,in)
            %processChunk   Requests the processing for a new chunk
            %
            %USAGE:
            %   out = pObj.processChunk(in)
            %
            %INPUT ARGUMENTS:
            %   in : Input signal (ratemap)
            %
            %OUTPUT ARGUMENTS:
            %  out : Output signal
            
            % Initialize a buffer if empty
            if isempty(pObj.buffer)
                pObj.buffer = 10*log10(in(1,:));
            end
            
            % Concatenate the input with the buffer
            bufIn = cat(1,pObj.buffer,10*log10(in));
            
            % Compute onset
            onset = diff(bufIn);
            
            % Discard offsets and limit onset strength
            out = min(max(onset,0),pObj.maxOnsetdB);
           
            % Update the buffer
            pObj.buffer = 10*log10(in(end,:));
            
        end
        
        function reset(pObj)
            %reset      Resets the internal buffers of the processor
            %
            %USAGE:
            %   pObj.reset()
            %
            %INPUT PARAMETERS:
            %   pObj : Processor instance
            
            % Reset the buffer
            pObj.buffer = [];
            
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
            
            % Only one parameter to test for
            hp = isequal(pObj.maxOnsetdB,p.ons_maxOnsetdB);
            
        end
        
    end
    
    
    
    
end