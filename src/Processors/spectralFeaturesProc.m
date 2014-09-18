classdef spectralFeaturesProc < Processor
    
    properties
        requestList     % Cell array of requested spectral features
        cfHz            % Row vector of audio center frequencies
    end
    
    properties (GetAccess = private)
        eps             % Factor used to prevent division by 0 (hard-coded)
        br_cf           % Cutoff frequency for brightness feature
        hfc_cf          % Cutoff frequency for high frequency content
        flux_buffer     % Buffered last frame of previous chunk for spectral flux
        var_buffer      % Buffered last frame for spectral variation
        ro_eps          % Epsilon value for spectral rolloff (hard-coded)
        ro_thres        % threshold value for spectral rolloff
        bUseInterp      % Flag indicating use of interpolation for spectral rolloff (hard-coded)
    end
    
    methods
        function pObj = spectralFeaturesProc(fs,cfHz,requests,br_cf,hfc_cf,ro_thres)
            %spectralFeaturesProc   Instantiate a processor for spectral
            %                       features extraction
            %
            %USAGE:
            %   pObj = spectralFeaturesProc(fs,cfHz)
            %   pObj = spectralFeaturesProc(fs,cfHz,requests)
            %
            %INPUT ARGUMENTS:
            %       fs : Sampling frequency of the input signal (ratemap)
            %     cfHz : Vector of audio center frequencies (Hz)
            % requests : Cell array of requests, valid requests as follow
            %            - 'all'          : All of the following (default)
            %            - 'centroid'     : Spectral centroid
            %            - 'crest'        : Spectral crest measure
            %            - 'spread'       : Spectral spread
            %            - 'entropy'      : Spectral entropy
            %            - 'brightness'   : Spectral brightness
            %            - 'hfc'          : Spectral high-frequency content
            %            - 'decrease'     : Spectral decrease
            %            - 'flatness'     : Spectral flatness
            %            - 'flux'         : Spectral flux
            %            - 'kurtosis'     : Spectral kurtosis
            %            - 'skewness'     : Spectral skewness
            %            - 'irregularity' : Spectral irregularity
            %            - 'rolloff'      : Spectral rolloff
            %            - 'variation'    : Spectral variation
            %
            %OUTPUT ARGUMENT:
            %     pObj : Processor instance
            %
            %TODO: error messages to be changed to warnings
            
            % Failsafe for Matlab empty calls
            if nargin>0
            
            if nargin<5||isempty(ro_thres);ro_thres = 0.85;end
            if nargin<4||isempty(hfc_cf);hfc_cf = 4000;end
            if nargin<3||isempty(br_cf);br_cf=1500;end
                
            % Check request validity...
            
            available = {'all' 'centroid' 'crest' 'spread' 'entropy' ...
                'brightness' 'hfc' 'decrease' 'flatness' 'flux' ... 
                'kurtosis' 'skewness' 'irregularity' 'rolloff' ...
                'variation'};
            
            % Check if a single request was given but not as a cell array
            if ischar(requests)
                requests = {requests};
            end
            
            % Check that requests is a cell of strings
            if ~iscellstr(requests)
                error('Requests for spectral features processor should be provided as a cell array of strings.')
            end
            
            % Check for typos/incorrect feature name
            if ~isequal(union(available,requests,'stable'),available)
                error(['Incorrect request name. Valid names are as follow: '...
                    strjoin(available,', ')])
            end
            
            % Change the requests to actual names if 'all' was requested
            if ismember('all',requests)
                requests = setdiff(available,{'all'},'stable');
            end
            
            % Check if provided brightness cutoff frequency is in a valid
            % range
            if (br_cf<cfHz(1)||br_cf>cfHz(end))&&ismember('brightness',requests)
                error('Brightness cutoff frequency should be in Nyquist range')
            end
            
            % Check if provided hfc cutoff frequency is in a valid range
            if (hfc_cf<cfHz(1)||hfc_cf>cfHz(end))&&ismember('hfc',requests)
                error('High frequency content cutoff frequency should be in Nyquist range')
            end
            
            % Ready to populate the processor properties
            pObj.Type = 'Spectral features extractor';
            pObj.FsHzIn = fs;
            pObj.FsHzOut = fs;
            pObj.cfHz = cfHz(:).';
            pObj.requestList = requests;
            pObj.br_cf = br_cf;
            pObj.hfc_cf = hfc_cf;
            pObj.flux_buffer = [];
            pObj.var_buffer = [];
            pObj.ro_thres = ro_thres;
            
            % Hard-coded properties (for the moment)
            pObj.eps = 1E-15;
            pObj.ro_eps = 1E-10;
            pObj.bUseInterp = true;
            
            end
        end
            
        function out = processChunk(pObj,in)
            %processChunk       Apply the processor to a new chunk of input
            %                   signal
            %
            %USAGE
            %   out = pObj.processChunk(in)
            %
            %INPUT ARGUMENT
            %    in : New chunk of input data
            %
            %OUTPUT ARGUMENT
            %   out : Corresponding output
            %
            %TODO: Spectral spread is dependent on centroid, don't compute
            %it twice
            
            % Number of spectral features to extract
            n_feat = size(pObj.requestList,2);
            
            % Output initialization
            out = zeros(size(in,1),n_feat);
            
            % Size of input chunk
            [nFrames, nFreq] = size(in);
                       
            % Main loop on all the features
            for ii = 1:n_feat
                
                % Switch among the requested features
                switch pObj.requestList{ii}
                    
                    case 'centroid'     % Spectral centroid
                        % Spectral center of gravity of the spectrum
                        out(:,ii) = sum(repmat(pObj.cfHz,[nFrames 1]).*in,2)./(sum(in,2)+pObj.eps);
                        
                    case 'crest'        % Spectral crest
                        % Ratio of maximum to average in every frame
                        out(:,ii) = max(in,[],2)./(mean(in,2)+pObj.eps);
                        
                    case 'decrease'     % Spectral decrease
                        
                        % Vector of inverse frequency bin index (corrected for 0)
                        kinv = 1./[1 ;(1:nFreq-1)'];
                        
                        % Spectral decrease
                        out(:,ii) = ((in-repmat(in(:,1),[1 nFreq]))*kinv)./(sum(in(:,2:end),2)+pObj.eps);
                        
                    case 'spread'       % Spectral spread (bandwidth)
                        % Average deviation to the centroid weigthed by
                        % amplitude
                        
                        % Dependent on the spectral centroid
                        centroid = sum(repmat(pObj.cfHz,[nFrames 1]).*in,2)./(sum(in,2)+pObj.eps);
                    
                        % Temporary nominator
                        nom = (repmat(pObj.cfHz,[nFrames 1]) - repmat(centroid,[1 nFreq])).^2 .* in;
                        
                        % Spectrum bandwidth
                        out(:,ii) = sqrt(sum(nom,2)./(sum(in,2)+pObj.eps));
                        
                    case 'brightness'   % Spectral brightness
                        % Ratio of energy above cutoff to total energy in
                        % each frame
                        out(:,ii) = sum(in(:,pObj.cfHz>pObj.br_cf),2)./(sum(in,2)+pObj.eps);
                        
                    case 'hfc'          % Spectral high frequency content
                        % Ratio of energy above cutoff to total energy in
                        % each frame (higher cutoff than brightness)
                        out(:,ii) = sum(in(:,pObj.cfHz>pObj.hfc_cf),2)./(sum(in,2)+pObj.eps);
                        
                    case 'entropy'      % Spectral entropy
                        
                        % Normalized spectrum
                        specN = in./(repmat(sum(in,2),[1 nFreq])+pObj.eps);
                        % Entropy
                        out(:,ii) = -sum(specN .* log(specN+pObj.eps),2)./log(nFreq);
                        
                    case 'flatness'     % Spectral flatness (SFM)
                        % Ratio of geometric mean to arithmetic mean across
                        % frequencies
                        out(:,ii) = exp(mean(log(in),2))./(mean(in,2)+pObj.eps);
                        
                    case 'flux'         % Spectral flux
                        
                        % Compressed power spectrum
                        pSpec = 10*log10(in+pObj.eps);
                        
                        % If the buffer is empty, use the first frame of
                        % the current input
                        if isempty(pObj.flux_buffer)
                            pObj.flux_buffer = pSpec(1,:);
                        end
                        
                        % Compute delta across frames, including buffer
                        deltaSpec = diff([pObj.flux_buffer; pSpec],1,1);
                        
                        % Take the norm across frequency
                        out(:,ii) = sqrt(mean(power(deltaSpec,2),2));
                        
                        % Update the buffer
                        pObj.flux_buffer = pSpec(end,:);
                        
                    case 'kurtosis'
                        
                        % Mean and standard deviation across frequency
                        mu_x  = mean(abs(in),2);
                        std_x = std(abs(in),0,2);
                        
                        % Remove mean from input
                        X = in - repmat(mu_x,[1 nFreq]);
                        
                        % Kurtosis
                        out(:,ii) = mean((X.^4)./(repmat(std_x + pObj.eps, [1 nFreq]).^4),2);
                        
                    case 'skewness'
                        
                        % Mean and standard deviation across frequency
                        mu_x  = mean(abs(in),2);
                        std_x = std(abs(in),0,2);
                        
                        % Remove mean from input
                        X = in - repmat(mu_x,[1 nFreq]);
                        
                        % Kurtosis
                        out(:,ii) = mean((X.^3)./(repmat(std_x + pObj.eps, [1 nFreq]).^3),2);
                        
                    case 'irregularity'
                        
                        % Compressed spectrum
                        pSpec = 10*log10(in+pObj.eps);
                        
                        % 2-Norm of spectrum difference across frequency
                        out(:,ii) = sqrt(mean(power(diff(pSpec,1,2),2),2));
                        
                    case 'rolloff'
                        % Extrapolated frequency threshold at each frame
                        % for which pObj.ro_thresh % of the energy is at 
                        % lower frequencies and the remaining above.
                        
                        % Spectral energy across frequencies multiplied by threshold parameter
                        spec_sum_thres = pObj.ro_thres * sum(in,2);
                        % Cumulative sum (+ epsilon ensure that cumsum increases monotonically)
                        spec_cumsum = cumsum(in + pObj.ro_eps,2);
                        
                        % Loop over number of frames
                        for jj = 1 : nFrames

                            % Use interpolation
                            if pObj.bUseInterp
                                if spec_sum_thres(jj) > 0
                                    % Detect spectral roll-off
                                    out(jj,ii) = interp1(spec_cumsum(jj,:),pObj.cfHz,spec_sum_thres(jj),'linear','extrap');
                                end
                            else
                                % The feature range of this code is limited to the vector fHz.

                                % Detect spectral roll-off
                                r = find(spec_cumsum(jj,:) > spec_sum_thres(jj),1);

                                % If roll-off is found ...
                                if ~isempty(r)
                                    % Get frequency bin
                                    out(jj,ii) = pObj.cfHz(r(1));
                                end
                            end
                        end
                        
                    case 'variation'
                        
                        % Initialize the buffer if empty
                        if isempty(pObj.var_buffer)
                            pObj.var_buffer = in(1,:);
                        end
                        
                        % Spectrum "shifted" one frame in the past
                        past_spec = [pObj.var_buffer;in(1:end-1,:)];
                        
                        % Cross-product
                        xprod = sum(in .* past_spec,2);
                        % Auto-product
                        aprod = sqrt(sum(in.^2,2)) .* sqrt(sum(past_spec.^2,2));
                        
                        % Noralized cross-correlation
                        out(:,ii) = 1-(xprod./(aprod+pObj.eps));
                        
                        % Update the buffer
                        pObj.var_buffer = in(end,:);
                        
                    otherwise
                        % This should NEVER be reached in a practical case
                        error('Invalid request name')
                end
                
            end
            
            
        end
            
        function reset(pObj)
            %reset      Reset the internal states of the processor
            %
            %USAGE
            %   pObj.reset
            %
            %INPUT ARGUMENT
            % pObj : Spectral features processor instance
            
            % Reset the two buffers
            pObj.flux_buffer = [];
            pObj.var_buffer = [];
            
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
            %
            %TODO: Find a good way to implement this method, taking into
            %account the requests
            
            % Temporary
            hp = 1;
            warning('The method hasParameters() of spectral features processor is not implemented yet. Returning TRUE')
            
            
        end
    end
    
    
    
end