classdef onsetProc < Processor
    
    properties 
        maxOnsetdB      % Upper limit for onset value
    end
    
    properties (GetAccess = private)
        buffer          % Buffered last frame of the previous chunk
    end
    
    methods
        function pObj = onsetProc(fs,maxOnsetdB)
            %onsetProc      Instantiates an onset detector
            %
            %USAGE:
            %       pObj = onsetProc(maxOnsetdB)
            %
            %INPUT ARGUMENTS:
            % maxOnsetdB : Upper limit for the onset value in dB 
            %              (default: maxOnsetdB = 30)
            %
            %OUTPUT ARGUMENTS:
            %       pObj : Processor instance
            
            if nargin>0
                
            if nargin<2||isempty(maxOnsetdB);maxOnsetdB=30;end
                
            pObj.Type = 'Onset detection';
            pObj.FsHzIn = fs;
            pObj.FsHzOut = fs;
            pObj.maxOnsetdB = maxOnsetdB;
            
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
            onset = diff(cat(1,pObj.buffer,10*log10(in)));
            
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