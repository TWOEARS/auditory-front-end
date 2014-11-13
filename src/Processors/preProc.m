classdef preProc < Processor
    
    properties (SetAccess = protected)
        bRemoveDC
        cutoffHzDC
        
        bPreEmphasis
        coefPreEmphasis
        
        bNormalizeRMS
        bBinauralAGC
        intTimeSecRMS
        
        bApplyLevelScaling
        refSPLdB
        
        bMiddleEarFiltering
        midEarFilterModel
    end
    
    properties (Access = private)
        dcFilter_l
        dcFilter_r
        preEmphFilter_l
        preEmphFilter_r
        agcFilter_l
        agcFilter_r
        epsilon = 1E-8;
        midEarFilter
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
            pObj.bBinauralAGC = p.pp_bBinauralAGC;
            pObj.intTimeSecRMS = p.pp_intTimeSecRMS;
            pObj.bApplyLevelScaling = p.pp_bApplyLevelScaling;
            pObj.refSPLdB = p.pp_refSPLdB;
            pObj.bMiddleEarFiltering = p.pp_bMiddleEarFiltering;
            pObj.midEarFilterModel = p.pp_midEarFilterModel;
            
            if pObj.bRemoveDC
                pObj.dcFilter_l = bwFilter(fs,4,pObj.cutoffHzDC,[],'high');
                pObj.dcFilter_r = bwFilter(fs,4,pObj.cutoffHzDC,[],'high');
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
            
            if pObj.bNormalizeRMS
                a = [1 -exp(-1/(pObj.intTimeSecRMS*fs))];
                b = sum(a);
                pObj.agcFilter_l = genericFilter(b,a,fs);
                pObj.agcFilter_r = genericFilter(b,a,fs);
            else
                pObj.agcFilter_l = [];
                pObj.agcFilter_r = [];
            end
            
            if pObj.bMiddleEarFiltering
                a = 1;
                b = middleearfilter(fs, pObj.midEarFilterModel);
                pObj.midEarFilter = genericFilter(b,a,fs);
            else
                pObj.midEarFilter = [];
            end
            
            pObj.Type = 'Pre-processor';
            pObj.FsHzIn = fs;
            pObj.FsHzOut = fs;
            
            pObj.isBinaural = true;
            pObj.hasTwoOutputs = true;
                
            end
    
        end
        
        function [out_l, out_r] = processChunk(pObj,in_l,in_r)
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
            if pObj.bNormalizeRMS
                % Initialize the filter states if empty
                if ~pObj.agcFilter_l.isInitialized  %isempty(pObj.agcFilter_l.States)
                    % Mean square of input over the time constant
                    sm_l = mean(data_l(1:min(size(data_l,1),round(pObj.intTimeSecRMS*pObj.FsHzIn))).^2);
                    sm_r = mean(data_r(1:min(size(data_r,1),round(pObj.intTimeSecRMS*pObj.FsHzIn))).^2);
                    
                    % Initial filter states
                    s0_l = exp(-1/(pObj.intTimeSecRMS*pObj.FsHzIn))*sm_l;
                    s0_r = exp(-1/(pObj.intTimeSecRMS*pObj.FsHzIn))*sm_r;
                    
                    pObj.agcFilter_l.reset(s0_l)
                    pObj.agcFilter_r.reset(s0_r)
                end
                
                % Estimate normalization constants
                normFactor_l = sqrt(pObj.agcFilter_l.filter(data_l.^2))+pObj.epsilon;
                normFactor_r = sqrt(pObj.agcFilter_r.filter(data_r.^2))+pObj.epsilon;
                
                % Preserve multi-channel differences
                if ~isempty(normFactor_r) && pObj.bBinauralAGC
                    normFactor_l = max(normFactor_l,normFactor_r);
                    normFactor_r = normFactor_l;
                end
                
                
                
                % Apply normalization
                data_l = data_l./normFactor_l;
                if ~isempty(normFactor_r)
%                     figure,plot(normFactor_r),title('preProc')
                    data_r = data_r./normFactor_r;
                else
                    data_r = [];
                end
                
            end
            
            if pObj.bApplyLevelScaling
                current_dboffset = dbspl(1);
                data_l = gaindb(data_l, current_dboffset-pObj.refSPLdB);
                data_r = gaindb(data_r, current_dboffset-pObj.refSPLdB);
            end
            
            if pObj.bMiddleEarFiltering
                data_l = pObj.midEarFilter.filter(data_l);
                data_r = pObj.midEarFilter.filter(data_r);
            end
            
            % Return the output
            out_l = data_l;
            out_r = data_r;
            
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
            
            % We want to look at the flags values, and bypass the parameter value if the
            % flag is set to false.
            
            if pObj.bRemoveDC && p.pp_bRemoveDC
                if pObj.cutoffHzDC ~= p.pp_cutoffHzDC
                    hp = 0;
                    return
                end
            end
            
            if ((pObj.bRemoveDC && p.pp_bRemoveDC) && (pObj.cutoffHzDC ~= p.pp_cutoffHzDC)) ...
                    || ~(pObj.bRemoveDC == p.pp_bRemoveDC)
                hp = 0;
                return
            end
            
            if ((pObj.bPreEmphasis && p.pp_bPreEmphasis) && (pObj.coefPreEmphasis ~= p.pp_coefPreEmphasis)) ...
                    || ~(pObj.bPreEmphasis == p.pp_bPreEmphasis)
                hp = 0;
                return
            end
            
            if ((pObj.bNormalizeRMS && p.pp_bNormalizeRMS) && ...
                    ((pObj.intRimeSecRMS ~= p.pp_intRimeSecRMS) || ...
                    (pObj.bBinauralAGC ~= p.pp_bBinauralAGC))) ...
                    || ~(pObj.bPreEmphasis == p.pp_bPreEmphasis)
                hp = 0;
                return
            end
            
            if ((pObj.bApplyLevelScaling && p.pp_bApplyLevelScaling) && ...
                    (pObj.refSPLdB ~= p.pp_refSPLdB)) ...
                    || ~(pObj.bApplyLevelScaling && p.pp_bApplyLevelScaling)
                hp = 0;
                return
            end
            
            if ((pObj.bMiddleEarFiltering && p.pp_bMiddleEarFiltering) && ...
                    (pObj.midEarFilterModel ~= p.pp_midEarFilterModel)) ...
                    || ~(pObj.bMiddleEarFiltering && p.pp_bMiddleEarFiltering)
                hp = 0;
                return
            end
            
            hp = 1;
            
        end
        
        function reset(pObj)
            %reset     Resets the internal states of the pre-processor
            %
            %USAGE
            %      pObj.reset
            %
            %INPUT ARGUMENTS
            %  pObj : Pre-processor instance
            
            if pObj.bRemoveDC
                pObj.dcFilter_l.reset;
                pObj.dcFilter_r.reset;
            end
            if pObj.bPreEmphasis
                pObj.preEmphFilter_l.reset;
                pObj.preEmphFilter_r.reset;
            end
            if pObj.bNormalizeRMS
                pObj.agcFilter_l.reset;
                pObj.agcFilter_r.reset;
            end
            if pObj.bMiddleEarFiltering
                pObj.midEarFilter.reset;
            end
            
        end
    
        
        
    end
    
end