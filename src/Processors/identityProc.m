classdef identityProc < Processor
%IDENTITYPROC A processor that copies the input directly to the output.
%   Used mainly for place holder, e.g., for instantiating arrays of processors in the 
%   manager. 
    
    methods
        function pObj = identityProc(fs)
            pObj.Type = 'Empty processor';
            pObj.FsHzIn = fs;
            pObj.FsHzOut = fs;

            % Hide the processor from the list of processors
            pObj.bHidden = 1;
        end
        
        function out = processChunk(pObj,in)
            out = in;
        end
        
        function reset(pObj)
            % EMPTY
        end
        
        function hp = hasParameters(pObj,p)
            % This processor has no parameter, so return Yes
            hp = true;
        end
        
    end
end