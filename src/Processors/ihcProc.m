classdef ihcProc < Processor
%IHCPROC Inner hair-cell processor.
%   The Inner hair-cell processor extracts the envelope of the output of
%   the individual Basilar Membrane (BM) filterbank outputs. This is
%   typically done by half-wave rectification combined with low-pass
%   filtering. The detailed extraction method can be specified as an input
%   parameter (see constructor below, and [1-4]).
%
%   ADAPTATIONPROC properties:
%       method              - IHC model to specify envelope extraction method
%
%   See also: Processor, gammatoneProc, drnlProc
%
%   Reference:
%   [1] Dau, T., Puschel, D., & Kohlrausch, A. (1996). 
%       A quantitative model of the "effective" signal processing 
%       in the auditory system. I. Model structure. 
%       Journal of the Acoustical Society of America, 99(6), 3615-3622. 
%   [2] Joergensen, S. and Dau, T. (2011). Predicting speech intelligibility 
%       based on the signal-to-noise envelope power ratio after 
%       modulation-frequency selective processing. Journal of the Acoustical 
%       Society of America, 130(3), 1475?1487.
%   [3] Breebaart, J., van de Par, S., and Kohlrausch, A. (2001).
%       Binaural processing model based on contralateral inhibition. I. 
%       Model structure. Journal of the Acoustical Society of America, 110(2), 
%       pp. 1074?1088.
%   [4] Bernstein, L. R., van de Par, S., and Trahiotis, C. (1999).
%       The normalized interaural correlation: Accounting for N_oS_pi 
%       thresholds obtained with Gaussian and ¡°low-noise¡±masking noise.
%       Journal of the Acoustical Society of America, 106(2), pp. 870?876.
    
     properties
         method        % Label for the IHC model used
     end
     
     properties (GetAccess = private)
         IHCFilter     % Filter involved in the extraction, if any
     end
     
     methods
         function pObj = ihcProc(fs,method)
             %ihcProc   Construct a inner haircell (IHC) envelope
             %                  extractor
             %
             %USAGE
             %   pObj = ihcProc(fs,method)
             %
             %INPUT ARGUMENTS
             %     fs : Sampling frequency (Hz)
             % method : Envelope extraction method
             %      'hilbert'       Hilbert transform
             %      'halfwave'      Half-wave rectification
             %      'fullwave'      Full-wave rectification
             %      'square'        Squared
             %      'dau'           Half-wave rectification and low-pass
             %                      filtering at 1000 Hz (see reference [1] above)
             %      'joergensen'    Hilbert transform and low-pass
             %                      filtering at 150 Hz (see [2] above)
             %      'breebart'      Half-wave rectification and low-pass
             %                      filtering at 770 Hz (see [3] above)
             %      'bernstein'     Half-wave rectification, compression
             %                      and low-pass filtering at 425 Hz (see [4] above)
             %   
             %N.B: The constructor does not instantiate the lowpass filters
             %needed for some of the methods.
                          
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
             pObj.method = method;
             
             % Instantiate a low-pass filter if needed
             switch pObj.method
                 
                 case 'joergensen'
                     % First order butterworth filter @ 150Hz
                     pObj.IHCFilter = bwFilter(pObj.FsHzIn,1,150);

                 case 'dau'
                     % Second order butterworth filter @ 1000Hz
                     pObj.IHCFilter = bwFilter(pObj.FsHzIn,2,1000);

                 case 'breebart'
                     % First order butterworth filter @ 2000Hz cascaded 5
                     % times
                     pObj.IHCFilter = bwFilter(pObj.FsHzIn,1,2000,5);

                 case 'bernstein'
                     % Second order butterworth filter @ 425Hz
                     pObj.IHCFilter = bwFilter(pObj.FsHzIn,2,425);

                 otherwise
                     pObj.IHCFilter = [];
             end
            
         end
         
         function out = processChunk(pObj,in)
                        
            % Carry out the processing for the chosen IHC method
            switch pObj.method
                case 'none'
                    out = in;

                case 'halfwave'
                    % Half-wave rectification
                    out = max(in,0);

                case 'fullwave'
                    % Full-wave rectification
                    out = abs(in);

                case 'square'
                    out = abs(in).^2;

                case 'hilbert'
                    out = abs(hilbert(in));

                case 'joergensen'
                    out = pObj.IHCFilter.filter(abs(hilbert(in)));

                case 'dau'
                    out = pObj.IHCFilter.filter(max(in,0));

                case 'breebart'
                    out = pObj.IHCFilter.filter(max(in,0));

                case 'bernstein'
                    env = max(abs(hilbert(in)).^(-.77).*in,0).^2;
                    out = pObj.IHCFilter.filter(env);

                otherwise
                    error('%s: Method ''%s'' is not supported!',upper(mfilename),pObj.IHCMethod)
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
             if ~isempty(pObj.IHCFilter)
                 pObj.IHCFilter.reset
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
            
            p_list = {'ihc_method'};
            p_list_proc = {'method'};
            
            % Initialization of a parameters difference vector
            delta = zeros(size(p_list,2),1);
            
            % Loop on the list of parameters
            for ii = 1:size(p_list,2)
                try
                    delta(ii) = ~strcmp(pObj.(p_list_proc{ii}),p.(p_list{ii}));
                    
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
                         % TODO: CAN'T SERIES THE FILTERS ATM

                     case 'bernstein'
                         % Second order butterworth filter @ 425Hz
                         obj(1,ii) = bwFilter(pObj.FsHzIn,2,425);

                 end
             end
             
         end
     end
end