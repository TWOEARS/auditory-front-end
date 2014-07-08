classdef IHCenvelopeProc < Processor
    
     properties
         IHCMethod      % Label for the IHC model used
%          nChannels      % Number of channels
     end
     
     properties (GetAccess = private)
         IHCFilters     % Filters involved in the extraction, if any
     end
     
     methods
         function pObj = IHCenvelopeProc(fs,method)
             %IHCenvelopeProc   Construct a inner haircell (IHC) envelope
             %                  extractor
             %
             %USAGE
             %   pObj = IHCenvelopeProc(fs,method)
             %
             %INPUT ARGUMENTS
             %     fs : Sampling frequency (Hz)
             % method : Envelope extraction method, among 'halfwave',
             %          'fullwave', 'square', 'hilbert', 'joergensen',
             %          'dau', 'breebart', 'berstein'
             %
             %N.B: The constructor does not instantiate the lowpass filters
             %needed for some of the methods.
             
             % TO DO: Detail the help file more 
             
             % List of valid methods
             validMeth = {'none',...
                         'halfwave',...
                         'fullwave',...
                         'square',...
                         'hilbert',...
                         'joergensen',...
                         'dau',...
                         'breebart',...
                         'bernstein'};
             
             % Check method name
             if ~ismember(method,validMeth)
                 error('Invalid name for envelope extraction method')
             end
             
             % Populate the object's properties
             % 1- Global properties
             populateProperties(pObj,'Type','IHC envelope extractor',...
                 'Dependencies',getDependencies('innerhaircell'),...
                 'FsHzIn',fs,'FsHzOut',fs);
             % 2- Specific properties
             pObj.IHCMethod = method;
             
             % Set up a flag if filters are needed
             if ismember(method,{'joergensen','dau','breebart','bernstein'})
                 pObj.IHCFilters = 1;
             else
                 pObj.IHCFilters = [];
             end
            
         end
         
         function out = processChunk(pObj,in)
                        
            % Number of channels in input
            nChannels = size(in,2);
            
            % Check if filters are needed
            if ~isempty(pObj.IHCFilters)
                % Check if enough instances exist
                if size(pObj.IHCFilters,2)~=nChannels
                    % Then instantiate the filters
                    pObj.IHCFilters = pObj.populateFilters(nChannels,pObj.IHCMethod);
                end
            end
            
            % Initialize output
            out = zeros(size(in));
            
            % Do the processing for each channel
            for ii = 1:nChannels
                switch pObj.IHCMethod
                    case 'none'
                        out(:,ii) = in(:,ii);

                    case 'halfwave'
                        % Half-wave rectification
                        out(:,ii) = max(in(:,ii),0);

                    case 'fullwave'
                        % Full-wave rectification
                        out(:,ii) = abs(in(:,ii));

                    case 'square'
                        out(:,ii) = abs(in(:,ii)).^2;

                    case 'hilbert'
                        out(:,ii) = abs(hilbert(in(:,ii)));

                    case 'joergensen'
                        out(:,ii) = pObj.IHCFilters(ii).filter(abs(hilbert(in(:,ii))));

                    case 'dau'
                        out(:,ii) = pObj.IHCFilters(ii).filter(max(in(:,ii),0));
                        
                    case 'breebart'
                        out(:,ii) = pObj.IHCFilters(ii).filter(max(in(:,ii),0));
                        
                    case 'bernstein'
                        env = max(abs(hilbert(in(:,ii))).^(-.77).*in(:,ii),0).^2;
                        out(:,ii) = pObj.IHCFilters(ii).filter(env);
                        
                    otherwise
                        error('%s: Method is not supported!',upper(mfilename))
                end
            end
                 
             
         end
         
         function reset(pObj)
             %reset     Resets the internal states of the IHC envelope
             %          extractor
             %
             %USAGE
             %      pObj.reset
             %
             %INPUT ARGUMENTS
             %  pObj : Inner haircell envelope extractor processor instance
             
             % A reset is needed only if the extractor involves filters
             if ~isempty(pObj.IHCFilters)
                 for ii = 1:size(pObj.IHCFilters,2)
                     pObj.IHCFilters(ii).reset
                 end
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
            
            %NB: Could be moved to private
            
            % The IHC processor has the following parameters to be
            % checked: IHCMethod
            
            p_list = {'IHCMethod'};
            
            % Initialization of a parameters difference vector
            delta = zeros(size(p_list,2),1);
            
            % Loop on the list of parameters
            for ii = 1:size(p_list,2)
                try
                    delta(ii) = ~strcmp(pObj.(p_list{ii}),p.(p_list{ii}));
                    
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
         function obj = populateFilters(pObj,nChannels,method)
             % This function creates an array of filter objects to be used
             % for envelope extraction. It returns the array instead of
             % directly setting up the property in pObj as a workaround to
             % a bug
             
             % Preallocate memory
             obj(1,nChannels) = bwFilter();
             
             % Instantiate one filter per channel
             for ii = 1:nChannels
                 switch method
                     case 'joergensen'
                         % First order butterworth filter @ 150Hz
                         obj(1,ii) = bwFilter(pObj.FsHzIn,1,150);

                     case 'dau'
                         % Second order butterworth filter @ 1000Hz
                         obj(1,ii) = bwFilter(pObj.FsHzIn,2,1000);

                     case 'breebart'
                         % First order butterworth filter @ 2000Hz
                         obj(1,ii) = bwFilter(pObj.FsHzIn,5,2000);
                         % TO DO: CAN'T SERIES THE FILTERS ATM

                     case 'bernstein'
                         % Second order butterworth filter @ 425Hz
                         obj(1,ii) = bwFilter(pObj.FsHzIn,2,425);

                 end
             end
             
         end
     end
end