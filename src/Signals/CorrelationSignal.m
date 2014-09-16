classdef CorrelationSignal < Signal
    % This children class collects all signals resulting from a correlation
    % computation (i.e., auto-correlation, cross-correlation)
    
    properties
        cfHz    % Center frequencies of the frequency channels (Hz)
        lags    % Lags values (in s if specified, else in samples)
    end
    
    methods
        
        function sObj = CorrelationSignal(fs,bufferSize_s,name,cfHz,lags,label,data,canal)
            %CorrelationSignal  Constructor for the correlation children
            %                   signal class
            %
            %USAGE
            %    sObj = CorrelationSignal(fs,name)
            %    sObj = CorrelationSignal(fs,name,cfHz,lags,label,data,canal)
            %
            %INPUT ARGUMENTS
            %       fs : Sampling frequency (Hz)
            %     name : Name tag of the signal, should be compatible with
            %            variable name syntax.
            %     cfHz : Center frequencies of the channels in Hertz.
            %     lags : Vector of lag values (s)
            %    label : Label for the signal, to be used in e.g. figures
            %            (default: label = name)
            %     data : Data matrix to construct an object from existing 
            %            data. Time should span the first dimension,
            %            frequency the second dimension, and lags the third
            %    canal : Flag indicating 'left', 'right', or 'mono'
            %            (default: canal = 'mono')
            %OUTPUT ARGUMENT
            %     sObj : Correlation signal object inheriting the signal class
            
            sObj = sObj@Signal( fs, bufferSize_s, [length(cfHz), length(lags)] );
            
            if nargin>0     % Safeguard for Matlab empty calls
                
            % Check input arguments
            if nargin<2||isempty(name)
                name = 'correlation';
                warning(['A name tag should be assigned to the signal. '...
                    'The name %s was chosen by default'],name)
            end
            if nargin<7; canal = 'mono'; end
            if nargin<6||isempty(data); data = []; end
            if nargin<5||isempty(label)
                label = name;
            end
            if nargin<4||isempty(lags); lags = []; end
            if nargin<3||isempty(cfHz); cfHz = []; end
            if nargin<1||isempty(fs)
%                 error('The sampling frequency needs to be provided')
                fs = [];
            end
            
            % N.B: The dimensionality of provided data (argument data)
            % cannot be verified here. If used outside of the manager
            % class, appropriate dimensionality of the data is left to the
            % user's responsibility.
            
            % Populate object properties
            populateProperties(sObj,'Label',label,'Name',name,...
                'Dimensions','nSample x nFilters x nLags');
            sObj.cfHz = cfHz;
            sObj.setData( data );
            sObj.Canal = canal;
            sObj.lags = lags;
                
            end
        end
        
        function h = plot(sObj)
            % Unavailable at the moment
            warning('The plotting functionality for this type of signal is not yet implemented. Sorry!')
        end
        
    end
    
end