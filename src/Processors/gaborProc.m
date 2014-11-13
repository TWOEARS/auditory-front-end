classdef gaborProc < Processor
    
    properties
        maxDynamicRangeDB   % Used to limit the dynamic range of input ratemap
        nFeat               % Number of Gabor features
    end
    
    methods
        function pObj = gaborProc(fs,p,nChanIn)
            %gaborProc    Constructs an Gabor features extractor
            %
            %USAGE
            %   pObj = gaborProc(fs,p,nChanIn)
            %
            %INPUT PARAMETERS
            %      fs : Sampling frequency in Hz
            %       p : Structure of non-default parameters
            % nChanIn : Number of channels in input ratemap
            %
            %OUTPUT PARAMETER
            % pObj : Processor object
            
            if nargin > 0
                
            % Checking input parameter
            if nargin<2||isempty(p)
                p = getDefaultParameters(fs,'processing');
            end
            if isempty(fs)
                error('Sampling frequency needs to be provided')
            end
                
            % Populate properties
            pObj.maxDynamicRangeDB = p.gb_maxDynamicRangeDB;
            pObj.nFeat = size(gbfb(ones(nChanIn,1)),1);

            pObj.Type = 'Gabor features extractor';
            pObj.FsHzIn = fs;
            pObj.FsHzOut = fs;
                
            end
        end
        
        function out = processChunk(pObj,in)
            %processChunk       Requests the processing for a new chunk of
            %                   signal
            %
            %USAGE:
            %    out = processChunk(in)
            %
            %INPUT ARGUMENTS:
            %   pObj : Processor instance
            %     in : Input chunk
            %
            %OUTPUT ARGUMENT:
            %    out : Processor output for that chunk
            
            % Maximum ratemap power
            max_pow = max(in(:));
            
            % Minimum ratemap floor to limit dynamic range
            min_pow = db2pow(-(pObj.maxDynamicRangeDB + (0 - pow2db(max_pow))));
            
            % Apply static compression
            in = pow2db(in + min_pow);

            % Compute Gabor features
            gb_feat = gbfb(in.');
            
            % Normalize features
            out = normalizeData(gb_feat','meanvar');
            
        end
        
        function reset(pObj)
            % Nothing to reset for that processor at the moment..
            
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
            
            hp = isequal(pObj.maxDynamicRangeDB,p.gb.maxDynamicRangeDB);
            
            
        end
    end
    
end