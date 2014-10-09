classdef drnlProc < Processor
    
    properties
        % Firstly follow Jepsen et al. 2008 and then accept MAP1_14-style
        % manual parameter input
        CF              % Characteristic Frequencies
        % Parameters of DRNL filterbank blocks
        % linear path
        Fc_lin          % linear path GT filter centre frequency
        nGTfilt_lin     % linear path GT filter # of cascades
        BW_lin          % linear path GT filter bandwidth
        g               % linear path gain
        LP_lin_cutoff
        nLPfilt_lin
        % nonlinear path
        Fc_nlin         % nonlinear path GT filter centre frequency
        nGTfilt_nlin    % nonlinear path GT filter # of cascades
        BW_nlin         % nonlinear path GT filter bandwidth
        a
        b
        c
        LP_nlin_cutoff
        nLPfilt_nlin

    end
    
    properties % (GetAccess = private)
        GTFilters_lin           % GT filters for linear path
        GTFilters_nlin          % GT filters for nonlinear path 
        LPFilters_lin                 % Low Pass Filters for linear path
        LPFilters_nlin                % Low Pass Filters for nonlinear path
        
    end
        
    methods
        function pObj = drnlProc(CF, fs, DRNLParams)
          
            if nargin>0
            % Checking input arguments
            narginchk(1, 3)
            
            % Check whether CF is in a valid format (cannot be empty)
            validateattributes(CF, {'numeric'}, {'nonempty'}, mfilename, 'CF', 1)
            
            if exist('DRNLParams', 'var') && ~isempty(DRNLParams)      % this means nargin == 3
                % linear path parameters
                pObj.Fc_lin = DRNLParams.linCFp*CF + DRNLParams.linCFq; % Hz, CF_lin,  grabbed from MAP1.14h
                pObj.nGTfilt_lin = DRNLParams.linOrder; % number of cascaded gammatone filters (termed "Order" in MAP? - needs double checking)
                pObj.BW_lin = DRNLParams.linBWp*CF + DRNLParams.linBWq; % Hz, BW_lin, MAP1.14h defines in a new way
                pObj.g = DRNLParams.g; % linear path gain g, grabbed from MAP1.14h
                % the following two parameters do not appear in MAP 
                % (LPF parameters)
                pObj.LP_lin_cutoff = 10^(-0.06762+1.01*log10(CF)); % Hz, LP_lin cutoff
                pObj.nLPfilt_lin = 4; % no. of cascaded LP filters
                
                % nonlinear path parameters
                pObj.Fc_nlin = DRNLParams.nonlinCFs; % Hz, CF_nlin, grabbed from MAP
                pObj.nGTfilt_nlin = DRNLParams.nonlinOrder; % number of cascaded gammatone filters (termed "Order" in MAP? - needs double checking)
                pObj.BW_nlin = DRNLParams.nlBWp*CF + DRNLParams.nlBWq; % Hz, BW_nlin, MAP defines in a new way
                % broken stick compression - note that MAP has changed the
                % formula!! currently disregard MAP and keep the Jepsen
                % model (confusing but reserved for future revision)
                pObj.a = DRNLParams.a.*ones(size(CF)); % a, the 1500 assumption is no good for compressionat low freq filters
                pObj.b = 10^(1.61912-.81867*log10(CF)); % b [(m/s)^(1-c)]
                pObj.c = DRNLParams.c; % c, compression coeff
                % the following two parameters do not appear in MAP 
                % (LPF parameters)
                pObj.LP_nlin_cutoff = 10^(-0.05252+1.01*log10(CF)); % LP_nlincutoff
                pObj.nLPfilt_nlin = 1; % no. of cascaded LP filters in nlin path            
            end   
                
            % Set default optional parameter
            if nargin < 3 || isempty(DRNLParams)        % nargin=3 with empty DRNLParams, or nargin=<2
                % grab default DRNL parameters here
                % the default parameters follow Jepsen model's definition
                pObj.Fc_lin = 10.^(-0.06762+1.01679*log10(CF)); % Hz, CF_lin
                pObj.nGTfilt_lin = 2; % number of cascaded gammatone filters
                pObj.BW_lin = 10.^(.03728+.75*log10(CF)); % Hz, BW_lin
                pObj.g = 10.^(4.20405 -.47909*log10(CF)); %g
                pObj.LP_lin_cutoff = 10.^(-0.06762+1.01*log10(CF)); % Hz, LP_lin cutoff
                pObj.nLPfilt_lin = 4; % no. of cascaded LP filters
                
                pObj.Fc_nlin = 10.^(-0.05252+1.01650*log10(CF)); % Hz, CF_nlin
                pObj.nGTfilt_nlin = 2; % number of cascaded gammatone filters
                pObj.BW_nlin = 10.^(-0.03193+.70*log10(CF)); % Hz, BW_nlin
                if CF<=1000
                    % SE 03.02.2011, the 2008 paper states <= 1500 Hz
                    % 06/04/2011 CI: answer from Morten regarding the discontinuity:
                    % This is imprecisely described in the paper. It was simulated as
                    % described with parameter a, having the value for 1500 Hz, for CFs
                    % above 1000 Hz. I do recognize the discontinuity in the derived
                    % parameter, but I think this is not critical
                    pObj.a = 10.^(1.40298+.81916*log10(CF)); % a, the 1500 assumption is no good for compressionat low freq filters
                    pObj.b = 10.^(1.61912-.81867*log10(CF)); % b [(m/s)^(1-c)]
                else
                    pObj.a = 10.^(1.40298+.81916*log10(1500)).*ones(size(CF)); % a, the 1500 assumption is no good for compressionat low freq filters
                    pObj.b = 10.^(1.61912-.81867*log10(1500)).*ones(size(CF)); % b [(m/s)^(1-c)]
                end
                pObj.c = 10^(-.60206); % c, compression coeff
                pObj.LP_nlin_cutoff = 10.^(-0.05252+1.01*log10(CF)); % LP_nlincutoff
                pObj.nLPfilt_nlin = 1; % no. of cascaded LP filters in nlin path            
            end
            
            if nargin < 2 || isempty(fs); fs = 44100; end
                       
%             % Number of DRNL filterbank "channel"s (determined by number of CFs
%             % provided)
%             nFilter = numel(CF); 
            
            % default parameters for gammatone filters
            % or maybe consider ignoring these and call gammatoneFilter with only
            % necessary parameters (fc, fs)
            irType = 'IIR';     % filter type
            n = 4;              % filter order
            bw = 1.08;          % bandwidth in ERBs
            bAlign = false;
            durSec = 0.128;
            
            % Instantiating the gammatone filters
            % NOTE: the upper two lines use Fc_lin and Fc_nlin for the
            % centre frequencies of the GTfilters (as supposed). 
            % But in CASP2008 script
            % LP_lin_cutoff and LP_nlin_cutoff were used as the centre
            % frequencies instead of the actually calculated centre
            % frequencies. 
%             pObj.GTFilters_lin = pObj.populateGTFilters(pObj.Fc_lin,fs,...
%                 irType,n,bw,bAlign,durSec);
%             pObj.GTFilters_nlin = pObj.populateGTFilters(pObj.Fc_nlin,fs,...
%                 irType,n,bw,bAlign,durSec);

            % the following two lines use LPF cutoff frequencies as the
            % gammatone centre frequencies (as seen in CASP2008 script)
%             pObj.GTFilters_lin = pObj.populateGTFilters(pObj.LP_lin_cutoff,fs,...
%                 irType,n,bw,bAlign,durSec);
%             pObj.GTFilters_nlin = pObj.populateGTFilters(pObj.LP_nlin_cutoff,fs,...
%                 irType,n,bw,bAlign,durSec); 
            
            % Directly copying CASP2008, including the implementation of
            % GTF - here use BW_lin and BW_nlin as the bandwidth parameter 
            % (in Hz) instead of bw in ERBs
            pObj.GTFilters_lin = pObj.populateGTFilters(pObj.LP_lin_cutoff, fs,...
                irType, n, pObj.BW_lin, bAlign, durSec, pObj.nGTfilt_lin);
            pObj.GTFilters_nlin = pObj.populateGTFilters(pObj.LP_nlin_cutoff, fs,...
                irType, n, pObj.BW_nlin, bAlign, durSec, pObj.nGTfilt_nlin); 
            
            % Instantiating the LPFs
            pObj.LPFilters_lin = pObj.populateLPFilters(pObj.LP_lin_cutoff, fs, pObj.nLPfilt_lin);
            pObj.LPFilters_nlin = pObj.populateLPFilters(pObj.LP_nlin_cutoff, fs, pObj.nLPfilt_nlin);           
                        
            % Setting up additional properties
            % 1- Global properties
            populateProperties(pObj,'Type','drnl filterbank',...
                'Dependencies',getDependencies('drnl'),...
                'FsHzIn',fs,'FsHzOut',fs);
            
            % 2- Specific properties
            pObj.CF = CF;
            
            end
        end
      
        function out = processChunk(pObj,in)
            %processChunk       Passes an input signal through the
            %                   DRNL filterbank
            %
            %USAGE
            %       out = processChunk(pObj,in)
            %       out = pObj.processChunk(in)
            %
            %INPUT ARGUMENTS
            %      pObj : DRNL filterbank object
            %        in : One-dimensional array containing the input signal
            %
            %OUTPUT ARGUMENTS
            %       out : Multi-dimensional array containing the filterbank
            %             outputs
            %
            %SEE ALSO:
            %       drnlProc.m
            
            % TO DO: Indicate that this function is not buit to deal with
            % multiple channels. Multiple channels should be treated with
            % multiple instances of the filterbank.
            
            % Check inputs
            if min(size(in))>1
                error('The input should be a one-dimensional array')
            end
            
            % Turn input into column vector
            in = in(:);
            
            % Get number of channels (CFs)
%             nFilter = size(pObj.Filters,2);
            nFilter = numel(pObj.CF);
            
            % Pre-allocate memory
%             out = zeros(length(in),nFilter);      % not necessary
            out_lin = zeros(length(in),nFilter);
            out_nlin = zeros(length(in),nFilter);
            
            % Loop through the CF channels (places on BM)
            % depending on the number of CF elements, all the parameters
            % (a, b, g, BW, etc.) can be single values or vectors
            % TODO: modify calculation when DRNLParams were given following
            % MAP specification
            for ii = 1:nFilter
                % linear path
                % apply linear gain
                out_lin(:, ii) = in.*pObj.g(ii);
                % linear path GT filtering - cascaded "nGTfilt_lin" times
                for jj = 1:1% pObj.nGTfilt_lin
                    out_lin(:, ii) = ...
                        pObj.GTFilters_lin(ii).filter(out_lin(:, ii));
                end
                % linear path LP filtering - cascaded "nLPfilt_lin" times
                for jj=1:1%pObj.nLPfilt_lin
                    out_lin(:, ii) = ...
                        pObj.LPFilters_lin(ii).filter(out_lin(:, ii));
                end
                
                % nonlinear path
                out_nlin(:, ii) = in;
                % nonlinear path GT filtering - cascaded "nGTfilt_nlin"
                % times
                for jj = 1:1% pObj.nGTfilt_nlin
                    out_nlin(:, ii) = ...
                        pObj.GTFilters_nlin(ii).filter(out_nlin(:, ii));
                end               
                % broken stick nonlinearity
                % refer to (Lopez-Poveda and Meddis, 2001) 
                % note that out_nlin(:, ii) is a COLUMN vector!
                y_decide = [pObj.a(ii).*abs(out_nlin(:, ii)) ...
                    pObj.b(ii).*abs(out_nlin(:, ii)).^pObj.c];
                
                out_nlin(:, ii) = sign(out_nlin(:, ii)).*min(y_decide, [], 2);
                % nonlinear path GT filtering again afterwards
                for jj = 1:1% pObj.nGTfilt_nlin
                    out_nlin(:, ii) = ...
                        pObj.GTFilters_nlin(ii).filter(out_nlin(:, ii));
                end  
                % nonlinear path LP filtering - cascaded "nLPfilt_nlin" times
                for jj=1:1%pObj.nLPfilt_nlin
                    out_nlin(:, ii) = ...
                        pObj.LPFilters_nlin(ii).filter(out_nlin(:, ii));
                end                
                
            end
            % now add the outputs
            out = out_lin + out_nlin;
        end
        
        function reset(pObj)
            %reset          Order the processor to reset its internal
            %               states, e.g., when some critical parameters in
            %               the processing have been changed
            %USAGE
            %       pObj.reset()
            %       reset(pObj)
            %
            %INPUT ARGUMENT
            %       pObj : Processor object
            
            % number of "CF" channels - check whether this can vary!!!
            nFilter = numel(pObj.CF);
            
            % Resetting the internal states of the internal filters
            for ii = 1:nFilter
                pObj.GTFilters_lin(ii).reset();
                pObj.GTFilters_nlin(ii).reset();
                pObj.LPFilters_lin(ii).reset();
                pObj.LPFilters_nlin(ii).reset();
            end
            
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
            
            % input to the processor: CF(s) and DRNLParams structure
            % DRNLParams are fixed from physiological data or determined
            % from CF - so check CF only at this stage
            
            p_list = {'CF'};
            
            % Initialization of a parameters difference vector
            delta = zeros(size(p_list,2),1);
            
            % Loop on the list of parameters
            for ii = 1:size(p_list,2)
                try
                    if size(pObj.(p_list{ii}))==size(p.(p_list{ii}))
                        delta(ii) = max(abs(pObj.(p_list{ii}) - p.(p_list{ii})));
                    else
                        delta(ii) = 1;
                    end
                    
                catch err
                    % Warning: something is missing
                    warning('Parameter %s is missing in input p.',p_list{ii})
                    delta(ii) = 1;
                end
            end
            
            % Check if delta is a vector of zeros
            if max(delta)>0
                hp = false;
            else
                hp = true;
            end
            
        end  
        
    end
    
    methods (Access = private)
        function obj = populateGTFilters(pObj,cfHz,fs,irType,n,bw,bAlign,durSec,cascadeOrder)
            % This function is a workaround to assign an array of objects
            % as one of the processor's property, should remain private
  
            nFilter = numel(cfHz);
         
            % Use genericFilter object to exactly copy CASP2008
            % implementation
            % In this case only cfHz, fs, and bw are necessary
            % bw here should indicate the bandwidth in Hz (compare to the
            % use of bw below)
            % Also note that bw is supposed to be a function of cf (could
            % be a vector!)
            
%             theta = 2*pi*cfHz(:)/fs;        % convert cfHz to column
%             phi   = 2*pi*bw(:)/fs;             % bw should be in Hz!!!
%             alpha = -exp(-phi).*cos(theta);
% 
%             b1 = 2*alpha;
%             b2 = exp(-2*phi);
%             a0 = abs( (1+b1.*cos(theta)-1i*b1.*sin(theta)+b2.*cos(2*theta)-1i*b2.*sin(2*theta)) ./ (1+alpha.*cos(theta)-1i*alpha.*sin(theta))  );
%             a1 = alpha.*a0;
% 
%             % adapt to matlab filter terminology
%             B=[a0, a1];
%             A=[ones(length(theta), 1), b1, b2];
%             
%             % Preallocate memory by instantiating last filter
%             obj(1,nFilter) = genericFilter(B(nFilter,:), A(nFilter, :), fs);
%             % Instantiating remaining filters
%             for ii = 1:nFilter-1
%                 obj(1,ii) = genericFilter(B(ii,:), A(ii,:), fs);
%             end                                  
            
%             % Use gammatoneFilter object instead of genericFilter
%             % In this case bw is fixed as 1.08 ERBs
% 
%             % Preallocate memory by instantiating last filter
            obj(1,nFilter) = gammatoneFilter(cfHz(nFilter),fs,irType,n,...
                                        bw(nFilter),bAlign,durSec,cascadeOrder);
            % Instantiating remaining filters
            for ii = 1:nFilter-1
                obj(1,ii) = gammatoneFilter(cfHz(ii),fs,irType,n,...
                                        bw(ii),bAlign,durSec,cascadeOrder);
            end                        
            
        end
        
        function obj = populateLPFilters(pObj,cfHz,fs,cascadeOrder)
            % This function is a workaround to assign an array of objects
            % as one of the processor's property, should remain private

            nFilter = numel(cfHz);

            % remember! cfHz can be a vector!
            % so convert cfHz to a column vector first before proceeding
            theta = pi*cfHz(:)/fs;
            % now theta is a column vector regardless of what cfHz was

            C = 1./(1+sqrt(2)*cot(theta)+(cot(theta)).^2);
            D = 2*C.*(1-(cot(theta)).^2);
            E = C.*(1-sqrt(2)*cot(theta)+(cot(theta)).^2);

            B = [C, 2*C, C];
            A = [ones(length(theta), 1), D, E];
                                    
            % Preallocate memory by instantiating last filter
            obj(1,nFilter) = genericFilter(B(nFilter,:), A(nFilter, :), fs,[],cascadeOrder);
            % Instantiating remaining filters
            for ii = 1:nFilter-1
                obj(1,ii) = genericFilter(B(ii,:), A(ii,:), fs,[],cascadeOrder);
            end                        
            
%             % use bwFilter instead of genericFilter
%             cfHz = cfHz(:);
%             nFilter = numel(cfHz);
%             bwFilter_order = 2;         % default LPF order
%             obj(1,nFilter) = bwFilter(fs, bwFilter_order, cfHz(nFilter));
%             for ii = 1:nFilter-1
%                 obj(1,ii) = bwFilter(fs, bwFilter_order, cfHz(ii));
%             end
            

        end
    end
        
end