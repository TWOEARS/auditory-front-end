classdef drnlProc < Processor
    
    properties
        % Firstly follow Jepsen et al. 2008 and then accept MAP1_14-style
        % manual parameter input
        cfHz                % Characteristic Frequencies 
        % NOTE: parameter cfHz here is DIFFERENT FROM cfHz as used in
        % gammatoneProc! - cfHz in gammatoneProc means CENTER FREQUENCY
        % cfHz is used just to follow the framework convention - e.g., some
        % processors after the gammatone filterbank stage expect 'cfHz' for
        % internal operations, and this should be the 'BM characteristic
        % frequency' when the gammatone filterbank is replaced by DRNL 
        % filterbank. See the constructor for the difference in the naming
        % convention: Characteristic Frequencies are denoted by cf, Center
        % Frequencies are denoted by fc
        
        mocIpsi             % ipsilateral MOC factors (nonlinear path gain)
        mocContra           % contralateral MOC factors (nonlinear path gain)
        model               % DRNL model (to be extended)       
        
        % Parameters of DRNL filterbank blocks (- could be made private but
        % put here for testing/checking after calculation)
        
        % linear path
        gainLinearPath  
        fcLinPathGammatoneFilter            % linear path GT filter centre frequency (Hz)
        nCascadeLinPathGammatoneFilter      % linear path GT filter # of cascades
        bwLinPathGammatoneFilter            % linear path GT filter bandwidth                   
        cutoffLinPathLowPassFilter          % linear path LP filter cutoff frequency (Hz)
        nCascadeLinPathLowPassFilter        % linear path LP filter # of cascades
        
        % nonlinear path: has two [cascaded] GT filter stages before and
        % after nonlinearity       
        fcNonlinPathGammatoneFilter         % nonlinear path GT filter centre frequency
        nCascadeNonlinPathGammatoneFilter   % nonlinear path GT filter # of cascades
        bwNonlinPathGammatoneFilter         % nonlinear path GT filter bandwidth
        % nonlinearity section - the parameters a, b, and c may have 
        % different definitions depending on the implementation model (CASP? MAP?)
        aNonlinPath                         % nonlinear path parameter 'a'
        bNonlinPath                         % parameter 'b'
        cNonlinPath                         % parameter 'c'
        % 
        nCascadeNonlinPathGammatoneFilter2  % nonlinear path GT filter AFTER BROKEN STICK STAGE, # of cascades
        cutoffNonlinPathLowPassFilter       % nonlinear path LPF cutoff
        nCascadeNonlinPathLowPassFilter     % nonlinear path LPF # of cascades

    end
    
    properties % (GetAccess = private)
        GTFilters_lin           % GT filters for linear path
        GTFilters_nlin          % GT filters for nonlinear path 
        GTFilters_nlin2         % GT filters for nonlinear path, AFTER BROKEN STICK STAGE
        LPFilters_lin           % Low Pass Filters for linear path
        LPFilters_nlin          % Low Pass Filters for nonlinear path
        
    end
        
    methods
%         function pObj = drnlProc(cf, fs, mocIpsi, mocContra, model)
        function pObj = drnlProc(fs, flow, fhigh, nERBs, nChan, cfHz, ...
                mocIpsi, mocContra, model)
            % drnlProc      Construct a DRNL filterbank inheriting
            %                   the "processor" class
            %
            % USAGE
            % - Minimal usage, either (in order of priority)
            %    pObj = drnlProc(fs,[],[],[],[],cfHz)
            %    pObj = drnlProc(fs,flow,fhigh,[],nChan)
            %    pObj = drnlProc(fs,flow,fhigh,nERBs)
            %    pObj = drnlProc(fs,flow,fhigh)
            %
            % - Additional arguments:
            %    pObj = drnlProc(fs,..., cfHz, mocIpsi, mocContra, model)
            %
            % INPUT ARGUMENTS
            %       fs : Sampling frequency (Hz)
            %     flow : Lowest characteristic frequency for the filterbank (in Hz)
            %    fhigh : Highest characteristic frequency for the filterbank (in Hz)
            %    nERBs : Distance in ERBS between neighboring characteristic
            %               frequencies (default: nERBS = 1)
            %    nChan : Number of characteristic frequency channels
            %     cfHz : Vector of channel characteristic frequencies
            %   mocIpsi: Ipsilateral MOC feedback factor as a nonlinear gain
            %               Can be given as a scalar (across all freq.
            %               channels) or a vector (individual gain per
            %               freq. channel)
            % mocContra: Contralateral MOC feedback factor, format same as mocIpsi    
            %     model: implementation model
            %               'CASP' (default) is based on Jepsen et al. 2008 
            %               JASA paper and 'MAP' is based on
            %               MAP1_14h (Ray Meddis, paper to follow)
            %
            % OUTPUT ARGUMENTS
            %    pObj: Processor object
            
%             if nargin>0
            % Checking input arguments - should be between 3 and 9,
            % otherwise error so if nargin>0 not necessary
            narginchk(3, 9)
            
            if nargin < 9 || isempty(model); model = 'CASP'; end
            if nargin < 8 || isempty(mocContra); mocContra = 1; end
            if nargin < 7 || isempty(mocIpsi); mocIpsi = 1; end
            
            % Parse mandatory arguments: three scenarios
            
            if ~isempty(cfHz)
                % 1- A vector of channels center frequencies is provided
                
                % Do nothing, we already have a vector of center
                % frequencies in Hz          
                
            elseif ~isempty(flow)&&~isempty(fhigh)&&~isempty(nChan)
                % 2- Frequency range and number of channels is provided
                
                % Give a warning if conflicting properties were specified
%                 if ~isempty(nERBs)
%                     warning(['Conflicting parameters were provided for '...
%                         'the DRNL filterbank instantiation. The '...
%                         'filterbank will be generated from the provided'...
%                         ' frequency range and number of channels.']) 
%                 end
                
                % Get vector of center frequencies
                ERBS = linspace(freq2erb(flow),freq2erb(fhigh),nChan);  % In ERBS
                cfHz = erb2freq(ERBS);                                  % In Hz
                
            elseif ~isempty(flow)&&~isempty(fhigh)&&isempty(nChan)&&isempty(cfHz)
                % 3- Frequency range and distance between channels is provided
                
                % Set distance between two channel to default is unspecified
                if nargin < 4 || isempty(nERBs);  nERBs  = 1;     end
                
                % Get vector of center frequencies
                ERBS = freq2erb(flow):double(nERBs):freq2erb(fhigh);    % In ERBS
                cfHz = erb2freq(ERBS);                                  % In Hz
                
            else
                % Else, something is missing in the input
                error('Not enough or incoherent input arguments.')
            end
                       
            % set parameters given as input
            pObj.cfHz = cfHz;
            
            % mocIpsi, mocContra can be a scalar or vector with the same
            % length as cfHz (individual nonlinear gain per channel)
            if isscalar(mocIpsi)            % single mocIpsi across all channels
                pObj.mocIpsi = mocIpsi*ones(size(cfHz));
            else                            % mocIpsi given as vector
                if size(mocIpsi) ~= size(cfHz)
                    error('mocIpsi must be a scalar or of the same dimension as cfHz');
                else
                    pObj.mocIpsi = mocIpsi;
                end
            end
            if isscalar(mocContra)          % single mocIpsi across all channels
                pObj.mocContra = mocContra*ones(size(cfHz));
            else                            % mocIpsi given as vector
                if size(mocContra) ~= size(cfHz)
                    error('mocContra must be a scalar or of the same dimension as cfHz');
                else
                    pObj.mocContra = mocContra;
                end
            end

            pObj.model = model;
            
            % set the other internal parameters and initialise (depending
            % on model)
            switch model
                case 'CASP'
                    % grab default DRNL parameters here
                    % the default parameters follow Jepsen model's definition
                    % linear path
                    pObj.gainLinearPath = 10.^(4.20405 -.47909*log10(cfHz)); %g
                    pObj.fcLinPathGammatoneFilter = 10.^(-0.06762+1.01679*log10(cfHz)); % Hz, CF_lin
                    pObj.nCascadeLinPathGammatoneFilter = 2; % number of cascaded gammatone filters
                    pObj.bwLinPathGammatoneFilter = 10.^(.03728+.75*log10(cfHz)); % Hz, bwLinPathGammatoneFilter
                    pObj.cutoffLinPathLowPassFilter = 10.^(-0.06762+1.01*log10(cfHz)); % Hz, LP_lin cutoff
                    pObj.nCascadeLinPathLowPassFilter = 4; % no. of cascaded LP filters
                    % nonlinsear path
                    pObj.fcNonlinPathGammatoneFilter = 10.^(-0.05252+1.01650*log10(cfHz)); % Hz, CF_nlin
                    pObj.nCascadeNonlinPathGammatoneFilter = 2; % number of cascaded gammatone filters
                    % RCK 21.10.2014, the 2008 paper uses 0.77 for m
                    % instead of 0.70 below for BW_nlin
                    pObj.bwNonlinPathGammatoneFilter = 10.^(-0.03193+.70*log10(cfHz)); % Hz, bwNonlinPathGammatoneFilter
                    % Warning: note that cfHz can be a vector now!!
                    for ii=1:length(cfHz)                  
                        if cfHz(ii)<=1000
                            % SE 03.02.2011, the 2008 paper states <= 1500 Hz
                            % 06/04/2011 CI: answer from Morten regarding the discontinuity:
                            % This is imprecisely described in the paper. It was simulated as
                            % described with parameter a, having the value for 1500 Hz, for CFs
                            % above 1000 Hz. I do recognize the discontinuity in the derived
                            % parameter, but I think this is not critical
                            pObj.aNonlinPath(ii) = 10.^(1.40298+.81916*log10(cfHz(ii))); % a, the 1500 assumption is no good for compressionat low freq filters
                            pObj.bNonlinPath(ii) = 10.^(1.61912-.81867*log10(cfHz(ii))); % b [(m/s)^(1-c)]
                        else
                            pObj.aNonlinPath(ii) = 10.^(1.40298+.81916*log10(1500)); % a, the 1500 assumption is no good for compressionat low freq filters
                            pObj.bNonlinPath(ii) = 10.^(1.61912-.81867*log10(1500)); % b [(m/s)^(1-c)]
                        end
                    end
                    pObj.nCascadeNonlinPathGammatoneFilter2 = 2; % number of cascaded gammatone filters AFTER BROKEN STICK NONLINEARITY STAGE
                    pObj.cNonlinPath = 10^(-.60206); % c, compression coeff
                    pObj.cutoffNonlinPathLowPassFilter = 10.^(-0.05252+1.01*log10(cfHz)); % LP_nlincutoff
                    pObj.nCascadeNonlinPathLowPassFilter = 1; % no. of cascaded LP filters in nlin path
                    
                    % CASP2008 uses LPF cutoff frequencies for the GTF
                    % centre frequencies (first parameter in function)
                    % cutoff frequency and bandwidth are in Hz (note the
                    % difference from gammatoneProc.m where the bandwidth
                    % is given in ERBs)
                    pObj.GTFilters_lin = pObj.populateGTFilters(pObj.cutoffLinPathLowPassFilter, fs,...
                        pObj.bwLinPathGammatoneFilter, pObj.nCascadeLinPathGammatoneFilter);
                    pObj.GTFilters_nlin = pObj.populateGTFilters(pObj.cutoffNonlinPathLowPassFilter, fs,...
                        pObj.bwNonlinPathGammatoneFilter, pObj.nCascadeNonlinPathGammatoneFilter); 
                    pObj.GTFilters_nlin2 = pObj.populateGTFilters(pObj.cutoffNonlinPathLowPassFilter, fs,...
                        pObj.bwNonlinPathGammatoneFilter, pObj.nCascadeNonlinPathGammatoneFilter2); 
                    
                case 'MAP'
                    % set parameters based on MAP1_14h implementation
                    % (MAPparamsNormal)
                    % linear path parameters
                    pObj.gainLinearPath = 500; % linear path gain g, grabbed from MAP1.14h
                    pObj.fcLinPathGammatoneFilter = 0.62*cfHz + 266; % Hz, CF_lin,  grabbed from MAP1.14h
                    pObj.nCascadeLinPathGammatoneFilter = 3; % number of cascaded gammatone filters (termed "Order" in MAP? - needs double checking)
                    pObj.bwLinPathGammatoneFilter = 0.2*cfHz + 235; % Hz, bwLinPathGammatoneFilter, MAP1.14h defines in a new way
                    % the following two parameters do not appear in MAP1_14h 
                    % (LPF parameters) but appear in previous versions
                    pObj.cutoffLinPathLowPassFilter = 10^(-0.06762+1.01*log10(cfHz)); % Hz, LP_lin cutoff
                    pObj.nCascadeLinPathLowPassFilter = 4; % no. of cascaded LP filters

                    % nonlinear path parameters
                    pObj.fcNonlinPathGammatoneFilter = cfHz; % Hz, CF_nlin, grabbed from MAP
                    pObj.nCascadeNonlinPathGammatoneFilter = 3; % number of cascaded gammatone filters (termed "Order" in MAP? - needs double checking)
                    pObj.bwNonlinPathGammatoneFilter = 0.14*cfHz + 180; % Hz, bwNonlinPathGammatoneFilter, MAP defines in a new way
                    % broken stick compression - note that MAP has changed the
                    % formula from CASP2008 version!! 
                    pObj.aNonlinPath = 4e3*ones(size(cfHz)); % a
                    pObj.bNonlinPath = 10^(1.61912-.81867*log10(cfHz)); % b [(m/s)^(1-c)]
                    pObj.cNonlinPath = .25; % c, compression coeff
                    pObj.nCascadeNonlinPathGammatoneFilter2 = 3; % number of cascaded gammatone filters AFTER BROKEN STICK NONLINEARITY STAGE
                    % the following two parameters do not appear in MAP1_14h 
                    % (LPF parameters) but appear in previous versions
                    pObj.cutoffNonlinPathLowPassFilter = 10^(-0.05252+1.01*log10(cfHz)); % LP_nlincutoff
                    pObj.nCascadeNonlinPathLowPassFilter = 3; % no. of cascaded LP filters in nlin path 
                    
                    % initialise GTFs (using corresponding centre freqs)
                    pObj.GTFilters_lin = pObj.populateGTFilters(pObj.fcLinPathGammatoneFilter, fs,...
                        pObj.bwLinPathGammatoneFilter, pObj.nCascadeLinPathGammatoneFilter);
                    pObj.GTFilters_nlin = pObj.populateGTFilters(pObj.fcNonlinPathGammatoneFilter, fs,...
                        pObj.bwNonlinPathGammatoneFilter, pObj.nCascadeNonlinPathGammatoneFilter); 
                    pObj.GTFilters_nlin2 = pObj.populateGTFilters(pObj.fcNonlinPathGammatoneFilter, fs,...
                        pObj.bwNonlinPathGammatoneFilter, pObj.nCascadeNonlinPathGammatoneFilter2); 
                    
                otherwise
                    error('Model not recognised - CASP or MAP supported only');
            end

            % Instantiating the LPFs
            pObj.LPFilters_lin = pObj.populateLPFilters(pObj.cutoffLinPathLowPassFilter, fs, pObj.nCascadeLinPathLowPassFilter);
            pObj.LPFilters_nlin = pObj.populateLPFilters(pObj.cutoffNonlinPathLowPassFilter, fs, pObj.nCascadeNonlinPathLowPassFilter);           
                        
            % Setting up global properties
            populateProperties(pObj,'Type','drnl filterbank',...
                'Dependencies',getDependencies('drnl'),...
                'FsHzIn',fs,'FsHzOut',fs);
            
%             end
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
            
            % The current implementation of the DRNL works with
            % dboffset=100, so we must change to this setting.
            % The output is always the same, so there is no need for changing back.

            % Obtain the dboffset currently used
            dboffset=dbspl(1);

            % Switch signal to the correct scaling
            in=gaindb(in, dboffset-100);

            % Turn input into column vector
            in = in(:);
            
            % Get number of channels (CFs)
            nFilter = length(pObj.cfHz);
            
            % Pre-allocate memory
            out_lin = zeros(length(in),nFilter);
            out_nlin = zeros(length(in),nFilter);
            
            % Loop through the CF channels (places on BM)
            % depending on the number of CF elements, all the parameters
            % (a, b, g, BW, etc.) can be single values or vectors
            % TODO: modify calculation when model = 'MAP'
            for ii = 1:nFilter
                % linear path
                % apply linear gain
                out_lin(:, ii) = in.*pObj.gainLinearPath(ii);
                % linear path GT filtering - cascaded "nCascadeLinPathGammatoneFilter" times
                % already (when the filter objects were initiated)
                    out_lin(:, ii) = ...
                        pObj.GTFilters_lin(ii).filter(out_lin(:, ii));
                % linear path LP filtering - cascaded "nCascadeLinPathLowPassFilter" times
                    out_lin(:, ii) = ...
                        pObj.LPFilters_lin(ii).filter(out_lin(:, ii));
                
                % nonlinear path
                % MOC attenuation applied (as gain factor)
                out_nlin(:, ii) = in.*pObj.mocIpsi(ii).*pObj.mocContra(ii);
                % nonlinear path GT filtering - cascaded "nCascadeNonlinPathGammatoneFilter"
                % times
                    out_nlin(:, ii) = ...
                        pObj.GTFilters_nlin(ii).filter(out_nlin(:, ii));
                % broken stick nonlinearity
                % refer to (Lopez-Poveda and Meddis, 2001) 
                % note that out_nlin(:, ii) is a COLUMN vector!
                % TODO: implement MAP version using switch-case
                y_decide = [pObj.aNonlinPath(ii).*abs(out_nlin(:, ii)) ...
                    pObj.bNonlinPath(ii).*abs(out_nlin(:, ii)).^pObj.cNonlinPath];
                out_nlin(:, ii) = sign(out_nlin(:, ii)).*min(y_decide, [], 2);
                % nonlinear path GT filtering again afterwards - cascaded
                % "nCascadeNonlinPathGammatoneFilter2" times
                    out_nlin(:, ii) = ...
                        pObj.GTFilters_nlin2(ii).filter(out_nlin(:, ii));
                % nonlinear path LP filtering - cascaded "nCascadeNonlinPathLowPassFilter" times
                    out_nlin(:, ii) = ...
                        pObj.LPFilters_nlin(ii).filter(out_nlin(:, ii));
                
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
            nFilter = numel(pObj.cfHz);
            
            % Resetting the internal states of the internal filters
            for ii = 1:nFilter
                pObj.GTFilters_lin(ii).reset();
                pObj.GTFilters_nlin(ii).reset();
                pObj.GTFilters_nlin2(ii).reset();
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
            
            % There are three ways to initialize filterbank, which all 
            % generate cfHz in common
            % Hence only this parameter is checked regarding
            % channel positionning.
            
            p_list = {'drnl_cfHz','drnl_mocIpsi','drnl_mocContra'};
            p_list_proc = {'cfHz','mocIpsi','mocContra'};
            
            % The center frequency position needs to be computed for
            % scenario where it is not explicitely provided
            if isempty(p.drnl_cfHz)&&~isempty(p.drnl_nChannels)
                ERBS = linspace(freq2erb(p.drnl_lowFreqHz),freq2erb(p.drnl_highFreqHz),p.drnl_nChannels);    % In ERBS
                p.drnl_cfHz = erb2freq(ERBS);                                              % In Hz
            elseif isempty(p.drnl_cfHz)&&isempty(p.drnl_nChannels)
                ERBS = freq2erb(p.drnl_lowFreqHz):double(p.drnl_nERBs):freq2erb(p.drnl_highFreqHz);   % In ERBS
                p.drnl_cfHz = erb2freq(ERBS);                                       % In Hz
            end
            
            % Initialization of a parameters difference vector
            delta = zeros(size(p_list,2),1);
            
            % Loop on the list of parameters
            for ii = 1:size(p_list,2)
                try
                    if size(pObj.(p_list_proc{ii}))==size(p.(p_list{ii}))
                        delta(ii) = max(abs(pObj.(p_list_proc{ii}) - p.(p_list{ii})));
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
        function obj = populateGTFilters(pObj,cfHz,fs,bwHz,cascadeOrder)
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
            
            theta = 2*pi*cfHz(:)/fs;        % convert cfHz to column
            phi   = 2*pi*bwHz(:)/fs;        % bw should be in Hz!!!
            alpha = -exp(-phi).*cos(theta);

            b1 = 2*alpha;
            b2 = exp(-2*phi);
            a0 = abs( (1+b1.*cos(theta)-1i*b1.*sin(theta)+b2.*cos(2*theta)-1i*b2.*sin(2*theta)) ./ (1+alpha.*cos(theta)-1i*alpha.*sin(theta))  );
            a1 = alpha.*a0;

            % adapt to matlab filter terminology
            B=[a0, a1];
            A=[ones(length(theta), 1), b1, b2];
            
            % Preallocate memory by instantiating last filter
            obj(1,nFilter) = genericFilter(B(nFilter,:), A(nFilter, :), fs, [], cascadeOrder);
            % Instantiating remaining filters
            for ii = 1:nFilter-1
                obj(1,ii) = genericFilter(B(ii,:), A(ii,:), fs, [], cascadeOrder);
            end                                  
            
%             % Use gammatoneFilter object instead of genericFilter
%             % In this case bw is fixed as 1.08 ERBs
% 
%             % default parameters for gammatone filters
%             % or maybe consider ignoring these and call gammatoneFilter with only
%             % necessary parameters (fc, fs)
%             irType = 'IIR';     % filter type
%             n = 4;              % filter order
%             bw = 1.08;          % bandwidth in ERBs
%             bAlign = false;
%             durSec = 0.128;

%             % Preallocate memory by instantiating last filter
%             obj(1,nFilter) = gammatoneFilter(cfHz(nFilter),fs,irType,n,...
%                                         bw(nFilter),bAlign,durSec,cascadeOrder);
%             % Instantiating remaining filters
%             for ii = 1:nFilter-1
%                 obj(1,ii) = gammatoneFilter(cfHz(ii),fs,irType,n,...
%                                         bw(ii),bAlign,durSec,cascadeOrder);
%             end                        
            
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