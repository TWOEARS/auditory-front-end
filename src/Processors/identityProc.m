classdef identityProc < Processor
    % A processor that does not do anything. Used for e.g., instantiating
    % arrays of processors in the manager. Processor parent class cannot be
    % used for that purpose as it is abstract.
    
    methods
        function pObj = identityProc(fs)
            pObj.Type = 'Empty processor';
            pObj.FsHzIn = fs;
            pObj.FsHzOut = fs;
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