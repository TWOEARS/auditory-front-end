classdef FeatureSignal < Signal
    
    properties (SetAccess=protected)
        fList       % Ordered list of the features (cell array of strings)
    end
    
    
    methods
        
        function sObj = FeatureSignal(fs,fList,bufferSize_s,name,label,channel)
            %SpectralFeaturesSignal     Constructor for the spectral
            %                           features signal class
            %
            %USAGE:
            %   sObj = SpectralFeaturesSignal(fs,fList)
            %   sObj = SpectralFeaturesSignal(fs,fList,name,label,channel)
            %
            %INPUT ARGUMENTS
            %     fs : Sampling frequency (Hz) of the spectral features
            %  fList : Ordered cell array of features names. fList{ii} is
            %          the name of the feature containted in the ii-th 
            %          column of the signal's data.
            %   name : Name tag of the signal, should be compatible with
            %          the global request name syntax.
            %  label : Label for the signal
            % channel : Flag indicating 'left', 'right', or 'mono' (default)
            %
            %OUTPUT ARGUMENT:
            %   sObj : Instant of the signal object
            
            sObj = sObj@Signal( fs, bufferSize_s, size(fList,2) );

            if nargin>0     % Failsafe for Matlab empty calls
                
            % Check input arguments
            if nargin<6||isempty(channel);channel='mono';end
            if nargin<4||isempty(name);name='feature_signal';end
            if nargin<5||isempty(label);label=name;end
            
            if nargin<3||isempty(fList)
                error('The list of features name has to be provided to instantiate a feature signal.')
            end
            
            if nargin<1||isempty(fs)
                error('The sampling frequency of the features has to be provided to instantiate a feature signal.')
            end
            
            % Populate object properties
            sObj.Label = label;
            sObj.Name = name;
            sObj.Dimensions = ['nSamples x ' num2str(size(fList,2)) 'features'];
            sObj.Channel = channel;
            sObj.fList = fList;
            
                
            end
            
        end
        
        function h = plot(sObj,h0,feature,varargin)
            %plot   Plots the requested spectral features
            %
            %USAGE:
            %     sObj.plot
            % h = sObj.plot(mObj,h0,feature)
            %
            %INPUT ARGUMENTS:
            %    sObj : Spectral features signal instance
            %      h0 : Handle to already existing figure or subplot
            % feature : Name of a specific feature to plot
            %
            %OUTPUT ARGUMENTS:
            %       h : Handle to the figure
            %
            %OPTIONAL ARGUMENTS:
            % Keyvalues:
            % 'overlay'  - Handle to a signal object to plot together with the feature
            % 'pitchRange' - Vector of valid pitch range
            % 'confThresh' - Confidence threshold in percent of the maximum
            % 'lagDomain'  - True for plotting 1/pitch (i.e., in the lag domain)
            
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
            
            % Manage parameters
            % TODO: Do we want to use common plot parameters (e.g., fontsize)
            
            % Manage optional arguments
            if nargin>3 && ~isempty(varargin)
                opt = struct;
                for ii = 1:2:size(varargin,2)
                    opt.(varargin{ii}) = varargin{ii+1};
                end
            else
                opt = [];
            end
            
            if nargin<3||isempty(feature)
                feature = sObj.fList;
            end
            
            if ~iscell(feature)
                feature = {feature};
            end
            
            % Number of subplots
            nFeatures = size(feature,2);
            
            
            % Time axis
            tSec = 0:1/sObj.FsHz:(size(sObj.Data(:,:),1)-1)/sObj.FsHz;
            
            % Plots
            for ii = 1 : nFeatures
                
                % Find the feature
                jj = find(ismember(sObj.fList,feature{ii}),1);
                
                if ~isempty(jj)
                    
                    % Create a subplot if more than one representation is needed
                    if nFeatures > 1
                        nSubplots = ceil(sqrt(nFeatures));
                        ax(ii) = subplot(nSubplots,nSubplots,ii);
                    end
                    
                    % Raw plot
                    hp = plot(tSec,sObj.Data(:,jj));
                     
                    % Some feature dependent styling below
                    switch feature{ii}
                        % Spectral features...
                        case {'variation' 'hfc' 'brightness' 'flatness' 'entropy'}
                            
                            if ~isempty(opt) && isfield(opt,'overlay')
                                hold on;
                                imagesc(tSec,(1:size(fHz,2))/size(fHz,2),10*log10(overlay.Data(:)'));axis xy;
                            end
                             
                            % Linestyle
                            set(hp,'LineStyle','--','LineWidth',2,'Color','k')

                            xlabel('Time (s)')
                            ylabel('Normalized frequency')
                            title(['Spectral ',sObj.fList{ii}])
                            
                        case {'irregularity' 'skewness' 'kurtosis' 'flux' 'decrease' 'crest'}

                            % Linestyle
                            set(hp,'LineStyle','--','LineWidth',2,'Color','k')
                            
                            xlim([tSec(1) tSec(end)])

                            xlabel('Time (s)')
                            ylabel('Feature magnitude')
                            title(['Spectral ',sObj.fList{ii}])

                        case {'rolloff' 'spread' 'centroid'}
                            
                            if ~isempty(opt) && isfield(opt,'overlay')
                                imagesc(tSec,fHz,10*log10(overlay.Data(:)'));axis xy;
                                hold on;
                            end
                            
                            % Linestyle
                            set(hp,'LineStyle','--','LineWidth',2,'Color','k')

                            xlabel('Time (s)')
                            ylabel('Frequency (Hz)')
                            title(['Spectral ',sObj.fList{ii}])
                            
                        % Pitch features
                        case 'pitch'
                        
                            if ~isempty(opt) && isfield(opt,'lagDomain')
                                if opt.lagDomain
                                    % Plot in terms of lag period
                                    set(hp,'YData',1./get(hp,'YData'));
                                end
                            end
                            
                            % Linestyle
                            set(hp,'marker','o','markerfacecolor','k','color','k','linestyle','none')
                            
                            xlabel('Time (s)')
                            ylabel('Frequency (Hz)')
                            title('Estimated pitch contour')
                            
                            if ~isempty(opt) && isfield(opt,'pitchRange')
                                ylim(opt.pitchRange)
                            end
                            
                        case 'rawPitch'
                            
                            if ~isempty(opt) && isfield(opt,'lagDomain')
                                if opt.lagDomain
                                    % Plot in terms of lag period
                                    set(hp,'YData',1./get(hp,'YData'));
                                end
                            end
                            
                            % Linestyle
                            set(hp,'marker','x','markerfacecolor','k','color','k',...
                                'linestyle','none','markersize',8,'linewidth',2)
                            
                            % Valid pitch indication
                            if ~isempty(opt) && isfield(opt,'pitchRange')
                                rangeLags = 1./opt.pitchRange;
                                plot([tSec(1) tSec(end)],[rangeLags(1) rangeLags(1)],'w--','linewidth',2)
                                plot([tSec(1) tSec(end)],[rangeLags(2) rangeLags(2)],'w--','linewidth',2)
                            end
                    
                        case 'confidence'
                            
                            set(hp,'LineStyle','-','color','k','linewidth',1.25)
                            
                            % Plot the maximum
                            [maxVal,maxIdx] = max(sObj.Data(:,jj));
                            hold on
                            plot(tSec(maxIdx),maxVal,'rx','linewidth',2,'markersize',12);
                            
                            % And the threshold if available
                            if ~isempty(opt) && isfield(opt,'confThres')
                                plot([tSec(1) tSec(end)],[opt.confThres opt.confThres],'--k','linewidth',2);
                                hl = legend({'SACF magnitude' 'global maximum' 'confidence threshold'},'location','southeast');
                            else
                                hl = legend({'SACF magnitude' 'global maximum'},'location','southeast');
                            end
                            
                            hlpos = get(hl,'position');
                            hlpos(1) = hlpos(1) * 0.85;
                            hlpos(2) = hlpos(2) * 1.35;
                            set(hl,'position',hlpos);
%                             grid on;
                            xlabel('Time (s)')
                            ylabel('Magnitude')
                            ylim([0 1])
                            title('Confidence measure')
                    end
                    
                    
                else
                    warning('There is no feature names %s in the signal',feature{ii})
                end
                
                
                
                
            end
            if nFeatures > 1
                linkaxes(ax,'x');
            end
            set(gca,'xLim',[0 tSec(end)])
%             set(h,'units','normalized','outerposition',[0 0 1 1])
            
        end
        
        
        
        
    end
    
    
    
    
    
    
    
    
    
    
    
    
end