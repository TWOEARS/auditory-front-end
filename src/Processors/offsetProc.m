classdef offsetProc < Processor
    
    properties 
        maxOffsetdB      % Upper limit for onset value
    end
    
    properties %(GetAccess = private)
        buffer          % Buffered last frame of the previous chunk
    end
    
    methods
        function pObj = offsetProc(fs,maxOffsetdB)
            %onsetProc      Instantiates an offset detector
            %
            %USAGE:
            %       pObj = onsetProc(maxOffsetdB)
            %
            %INPUT ARGUMENTS:
            % maxOffsetdB : Upper limit for the offset value in dB 
            %               (default: maxOnsetdB = 30)
            %
            %OUTPUT ARGUMENTS:
            %        pObj : Processor instance
            
            if nargin>0
                
            if nargin<2||isempty(maxOffsetdB);maxOffsetdB=30;end
                
            pObj.Type = 'Offset detection';
            pObj.FsHzIn = fs;
            pObj.FsHzOut = fs;
            pObj.maxOffsetdB = maxOffsetdB;
            
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
            offset = diff(cat(1,pObj.buffer,10*log10(in)));
            
            % Discard onsets and limit onset strength
            out = min(abs(min(offset,0)),abs(pObj.maxOffsetdB));
            
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
            hp = isequal(pObj.maxOffsetdB,p.ofs_maxOffsetdB);
            
        end
        
    end
    
    
    
    
end