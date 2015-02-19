classdef preProc < Processor
%PREPROC Pre-processor.
%   Prior to computing any of the supported auditory representations, 
%   the input signal stored in the data object can be pre-processed with 
%   one of the following elements:
%       1. Direct current (DC) bias removal
%       2. Pre-emphasis
%       3. Root mean square (RMS) normalization [1] 
%       4. Level scaling to a pre-defiend sound pressure level (SPL) reference
%       5. Middle ear filtering [2] 
%
%   PREPROC properties:
%       bRemoveDC       - Flag to activate DC removal filter
%       cutoffHzDC      - Cutoff frequency in Hz of the high-pass filter
%         
%       bPreEmphasis    - Flag to activate pre-emphasis filter
%       coefPreEmphasis - Coefficient of first-order high-pass filter
%         
%       bNormalizeRMS   - Flag to activate RMS normalization
%       bBinauralRMS    - Flag to link RMS normalization across both ears
%       intTimeSecRMS   - Time constant used for RMS estimation
%         
%       bLevelScaling   - Flag to apply level sacling to given reference
%       refSPLdB        - Reference dB SPL to correspond to input RMS of 1
%         
%       bMiddleEarFiltering - Flag to apply middle ear filtering
%       middleEarModel      - Middle ear filter model
%
%   See also: Processor
%
%   Reference:
%   [1] Tchorz, J. and Kollmeier, B. (2003), "SNR estimation based on 
%       amplitude modulation analysis with applications to noise suppression," 
%       IEEE Transactions on Audio, Speech, and Language Processing 11(3),
%       pp. 184?192.
%   [2] Goode, R. L., Killion, M., Nakamura, K., and Nishihara, S. (1994), 
%       "New knowledge about the function of the human middle ear: 
%       development of an improved analog model." The American journal of 
%       otology 15(2), pp. 145?154.
    
    properties (SetAccess = protected)
        bRemoveDC
        cutoffHzDC
        
        bPreEmphasis
        coefPreEmphasis
        
        bNormalizeRMS
        bBinauralRMS
        intTimeSecRMS
        
        bLevelScaling
        refSPLdB
        
        bMiddleEarFiltering
        middleEarModel
        
    end
    
    properties (Access = private)
        dcFilter_l
        dcFilter_r
        preEmphFilter_l
        preEmphFilter_r
        agcFilter_l
        agcFilter_r
        epsilon = 1E-8;
        midEarFilter_l
        midEarFilter_r
        bUnityComp
        meFilterPeakdB
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
            pObj.bBinauralRMS = p.pp_bBinauralRMS;
            pObj.intTimeSecRMS = p.pp_intTimeSecRMS;
            pObj.bLevelScaling = p.pp_bLevelScaling;
            if numel(p.pp_refSPLdB)>2
                fprintf('More than two refSPLdB values given - only the first two will be used (L/R)');
            end
            pObj.refSPLdB = p.pp_refSPLdB;
            pObj.bMiddleEarFiltering = p.pp_bMiddleEarFiltering;
            pObj.middleEarModel = p.pp_middleEarModel;
            pObj.bUnityComp = p.pp_bUnityComp;
            if pObj.bUnityComp
                switch pObj.middleEarModel
                    case 'jepsen'
                        pObj.meFilterPeakdB = 55.9986;
                    case 'lopezpoveda'
                        pObj.meFilterPeakdB = 66.2888;
                end
            else
                pObj.meFilterPeakdB = 0;
            end
            
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
                switch pObj.middleEarModel
                    case 'jepsen'
                        model = 'jepsenmiddleear';
                    otherwise
                        model = pObj.middleEarModel;
                end
                a = 1;
                b = middleearfilter(fs, model);
                pObj.midEarFilter_l = genericFilter(b,a,fs);
                pObj.midEarFilter_r = genericFilter(b,a,fs);
            else
                pObj.midEarFilter_l = [];
                pObj.midEarFilter_r = [];
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
                if ~isempty(normFactor_r) && pObj.bBinauralRMS
                    normFactor_l = max(normFactor_l,normFactor_r);
                    normFactor_r = normFactor_l;
                end
                
                % Apply normalization
                data_l = data_l./normFactor_l;
                if ~isempty(normFactor_r)
                    data_r = data_r./normFactor_r;
                else
                    data_r = [];
                end
                
            end
            
            if pObj.bLevelScaling
                current_dboffset = dbspl(1);
                if isscalar(pObj.refSPLdB)
                    data_l = gaindb(data_l, current_dboffset-pObj.refSPLdB);
                    data_r = gaindb(data_r, current_dboffset-pObj.refSPLdB);
                else
                    data_l = gaindb(data_l, current_dboffset-pObj.refSPLdB(1));
                    data_r = gaindb(data_r, current_dboffset-pObj.refSPLdB(2));
                end
            end
            
            if pObj.bMiddleEarFiltering
                data_l = pObj.midEarFilter_l.filter(data_l)* 10^(pObj.meFilterPeakdB/20);
                data_r = pObj.midEarFilter_r.filter(data_r)* 10^(pObj.meFilterPeakdB/20);
                
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
                    (pObj.bBinauralRMS ~= p.pp_bBinauralRMS))) ...
                    || ~(pObj.bPreEmphasis == p.pp_bPreEmphasis)
                hp = 0;
                return
            end
            
            if ((pObj.bLevelScaling && p.pp_bLevelScaling) && ...
                    ~isequal(pObj.refSPLdB, p.pp_refSPLdB)) ...
                    || ~(pObj.bLevelScaling == p.pp_bLevelScaling)
                hp = 0;
                return
            end
            
            if ((pObj.bMiddleEarFiltering && p.pp_bMiddleEarFiltering) && ...
                    ~strcmp(pObj.middleEarModel,p.pp_middleEarModel)) ...
                    || ~(pObj.bMiddleEarFiltering == p.pp_bMiddleEarFiltering)
                hp = 0;
                return
            end

            % Special section for unity gain compensation
            if ((pObj.bMiddleEarFiltering && p.pp_bMiddleEarFiltering) && ...
                    pObj.bUnityComp ~= p.pp_bUnityComp)
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
                pObj.midEarFilter_l.reset;
                pObj.midEarFilter_r.reset;
            end
            
        end
    
        
        
    end
    
end