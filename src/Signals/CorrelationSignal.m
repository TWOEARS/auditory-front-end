classdef CorrelationSignal < Signal
    % This children class collects all signals resulting from a correlation
    % computation (i.e., auto-correlation, cross-correlation)
    
    properties (SetAccess=protected)
        cfHz    % Center frequencies of the frequency channels (Hz)
        lags    % Lags values (in s if specified, else in samples)
    end
    
    methods
        
        function sObj = CorrelationSignal(fs,bufferSize_s,name,cfHz,lags,label,data,channel)
            %CorrelationSignal  Constructor for the correlation children
            %                   signal class
            %
            %USAGE
            %    sObj = CorrelationSignal(fs,name)
            %    sObj = CorrelationSignal(fs,name,cfHz,lags,label,data,channel)
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
            %  channel : Flag indicating 'left', 'right', or 'mono'
            %            (default: channel = 'mono')
            %OUTPUT ARGUMENT
            %     sObj : Correlation signal object inheriting the signal class
            
            sObj = sObj@Signal( fs, bufferSize_s, [length(cfHz), length(lags)] );
            
            if nargin>0     % Safeguard for Matlab empty calls
                
            % Check input arguments
            if nargin<3||isempty(name)
                name = 'correlation';
                warning(['A name tag should be assigned to the signal. '...
                    'The name %s was chosen by default'],name)
            end
            if nargin<8; channel = 'mono'; end
            if nargin<7||isempty(data); data = []; end
            if nargin<6||isempty(label)
                label = name;
            end
            if nargin<5||isempty(lags); lags = []; end
            if nargin<4||isempty(cfHz); cfHz = []; end
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
            sObj.Channel = channel;
            sObj.lags = lags;
                
            end
        end
        
        function h = plot(sObj,h0,p,frameNb,varargin)
            %plot       This method plots the data from a correlation signal object
            %
            %USAGE
            %       sObj.plot
            %       sObj.plot(h_prev,p,frameNb)
            %       h = sObj.plot(...)
            %
            %INPUT ARGUMENT
            %  h_prev : Handle to an already existing figure or subplot
            %           where the new plot should be placed
            %       p : Structure of non-default plot parameters (generated
            %           from genParStruct.m)
            % frameNb : Specify a given time frame to plot. If none specified, the summary
            %           correlation will be plotted as a 2D image.
            %
            %OUTPUT ARGUMENT
            %       h : Handle to the newly created figure
            %
            %OPTIONAL ARGUMENTS
            % 'noTitle' - Flag to avoid displaying a title
            
            % TODO: Add an option to plot the correlation in a given frame instead of
            % the summary
            
            % Manage plotting parameters
            if nargin < 3 || isempty(p) 
                % Get default plotting parameters
                p = getDefaultParameters([],'plotting');
            else
                p.fs = sObj.FsHz;   % Add the sampling frequency to satisfy parseParameters
                p = parseParameters(p);
            end
            
            % Manage optional arguments
            if nargin>3 && ~isempty(varargin)
                opt = struct;
                for ii = 1:2:size(varargin,2)
                    opt.(varargin{ii}) = varargin{ii+1};
                end
            else
                opt = [];
            end
            
            % Compute the summary correlation
            scorr = squeeze(mean(sObj.Data(:),2));
            
            % Time axis
            t = 0:1/sObj.FsHz:(size(sObj.Data(:),1)-1)/sObj.FsHz;
            
            % Manage handles
            if nargin < 2 || isempty(h0)
                    h = figure;             % Generate a new figure
                elseif get(h0,'parent')~=0
                    % Then it's a subplot
                    figure(get(h0,'parent')),subplot(h0)
                    h = h0;
                else
                    figure(h0)
                    h = h0;
            end
            if nargin<4 || isempty(frameNb)
                
                % Set the colormap
                try
                    colormap(p.colormap)
                catch
                    warning('No colormap %s is available, using ''jet''.',p.colormap)
                    colormap('jet')
                end

                % Plot
                imagesc(t,sObj.lags,scorr.');
                axis xy

                if p.bColorbar
                    colorbar
                end

                xlabel('Time (s)','fontsize',p.fsize_label,'fontname',p.ftype)
                ylabel('Lag period (s)','fontsize',p.fsize_label,'fontname',p.ftype)

                % Set up a title
                if ~strcmp(sObj.Channel,'mono')
                    pTitle = [sObj.Label ' summary -' sObj.Channel];
                else
                    pTitle = [sObj.Label ' summary'];
                end
                
                if ~isempty(opt) && isfield(opt,'noTitle')
                    if opt.noTitle ~= 1
                        title(pTitle,'fontsize',p.fsize_title,'fontname',p.ftype)
                    end
                end
            
            else
                
                ax(1) = subplot(4,1,[1:3]);
                waveplot(permute(sObj.Data(frameNb,:,:),[3 1 2]),sObj.lags*1E3,...
                    sObj.cfHz,p.wavPlotZoom,1)
                xlabel('')
                hy = ylabel('Center frequency (Hz)');
%                 hypos = get(hy,'position');
%                 hypos(1) = -2.15;
%                 set(hy,'position',hypos);
                if ~isempty(opt) && isfield(opt,'noTitle')
                    if opt.noTitle ~= 1
                        title(sObj.Label,'fontsize',p.fsize_title,'fontname',p.ftype)
                    end
                else
                    title(sObj.Label,'fontsize',p.fsize_title,'fontname',p.ftype)
                end
                
                ax(2) = subplot(4,1,4);
                plot(sObj.lags*1E3,mean(permute(sObj.Data(frameNb,:,:),[3 1 2]),3),...
                                        'k','linewidth',1.25)
                grid on
                xlim([sObj.lags(1)*1E3 sObj.lags(end)*1E3])
                ylim([0 1])
                xlabel('Lag period (ms)')
                ylabel('Summary')
                
            end
            
        end
        
    end
    
end