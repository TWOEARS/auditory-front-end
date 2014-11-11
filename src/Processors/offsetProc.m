classdef offsetProc < Processor
    
    properties (SetAccess = protected)
        maxOffsetdB      % Upper limit for onset value
        minValuedB      % Lower limit for the representation below which onset are discarded
    end
    
    properties (GetAccess = private)
        buffer          % Buffered last frame of the previous chunk
    end
    
    methods
        function pObj = offsetProc(fs,p)
            %onsetProc      Instantiates an offset detector
            %
            %USAGE:
            %       pObj = onsetProc(fs,p)
            %
            %INPUT ARGUMENTS:
            %  fs : Sampling frequency (Hz)
            %   p : Non-default parameters
            %
            %OUTPUT ARGUMENTS:
            %        pObj : Processor instance
            
            if nargin>0
                
            if nargin<2||isempty(p)
                p = getDefaultParameters(fs,'processing');
            else
                p.fs = fs;
                p = parseParameters(p);
            end
                
            pObj.Type = 'Offset detection';
            pObj.FsHzIn = fs;
            pObj.FsHzOut = fs;
            pObj.maxOffsetdB = p.ofs_maxOffsetdB;
            pObj.minValuedB = p.ofs_minValuedB;
            
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
            
            % Compute offset
            offset = diff(bufIn);
            
            % Discard onsets and limit onset strength
            out = min(abs(min(offset,0)),abs(pObj.maxOffsetdB));
            
            % Discard offsets if the representation is below a threshold
            if ~isempty(pObj.minValuedB)
                bSet2zero = bufIn(1:end-1,:)  < pObj.minValuedB;
                out(bSet2zero) = 0;
            end
            
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