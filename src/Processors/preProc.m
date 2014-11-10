classdef preProc < Processor
    
    properties (SetAccess = protected)
        bRemoveDC
        cutoffHzDC
        
        bPreEmphasis
        coefPreEmphasis
        
        bNormalizeRMS
        intTimeSecRMS
    end
    
    properties (Access = private)
        dcFilter_l
        dcFilter_r
        preEmphFilter_l
        preEmphFilter_r
    end
    
    
    methods
        function pObj = preProc(fs,p)
            %preProc    Instantiates a pre-processor
            %
            %USAGE:
            %   pObj = preProc(fs);
            %   pObj = preProc(fs,p);
            %
            %INPUT ARGUMENTS:
            %   fs : Sampling frequency (Hz)
            %    p : Structure of non-default parameters
            %
            %OUTPUT ARGUMENTS:
            % pObj : Pre-processor instance
            
            if nargin > 0
                
            if isempty(fs)
                error('Sampling frequency needs to be provided')
            end
            if nargin<2||isempty(p)
                p = getDefaultParameters(fs,'processing');
            else
                p = parseParameters(p);
            end
            
            pObj.bRemoveDC = p.pp_bRemoveDC;
            pObj.cutoffHzDC = p.pp_cutoffHzDC;
            pObj.bPreEmphasis = p.pp_bPreEmphasis;
            pObj.coefPreEmphasis = p.pp_coefPreEmphasis;
            pObj.bNormalizeRMS = p.pp_bNormalizeRMS;
            pObj.intTimeSecRMS = p.pp_intTimeSecRMS;
            
            if pObj.bRemoveDC
                pObj.dcFilter_l = bwFilter(fs,4,pObj.cutoffHzDC,[],[],'high');
                pObj.dcFilter_r = bwFilter(fs,4,pObj.cutoffHzDC,[],[],'high');
            else
                pObj.dcFilter_l = [];
                pObj.dcFilter_r = [];
            end
            
            if pObj.bPreEmphasis
                pObj.preEmphFilter_l = genericFilter([1 -abs(pObj.coefPreEmphasis)],1,fs);
                pObj.preEmphFilter_r = genericFilter([1 -abs(pObj.coefPreEmphasis)],1,fs);
            else
                pObj.preEmphFilter_l = [];
                pObj.preEmphFilter_r = [];
            end
            
            pObj.Type = 'Pre-processor';
            pObj.FsHzIn = fs;
            pObj.FsHzOut = fs;
            
            pObj.isBinaural = true;
            pObj.hasTwoOutputs = true;
                
            end
    
        end
        
        function [out_l out_r] = processChunk(pObj,in_l,in_r)
            %processChunk       Apply the processor to a new chunk of input signal
            %
            %USAGE
            %   [out_l out_r] = pObj.processChunk(in_l,in_r)
            %
            %INPUT ARGUMENT
            %    in_l : New chunk of input data from left channel
            %    in_r : New chunk of input data from right channel
            %
            %OUTPUT ARGUMENT
            %   out_l : Corresponding output (left channel)
            %   out_r : Corresponding output (right channel)
            
            if nargin < 3 || isempty(in_r)
                in_r = [];
            end
            
            % 0- Initialization
            data_l = in_l;
            data_r = in_r;
            
            % 1- DC-removal filter
            if pObj.bRemoveDC
                data_l = pObj.dcFilter_l.filter(data_l);
                data_r = pObj.dcFilter_r.filter(data_r);
            end
            
            % 2- Pre-whitening
            if pObj.bPreEmphasis
                data_l = pObj.preEmphFilter_l.filter(data_l);
                data_r = pObj.preEmphFilter_r.filter(data_r);
            end
            
            % 3- Automatic gain control
            
            
            
    
        
        
    end
    
end