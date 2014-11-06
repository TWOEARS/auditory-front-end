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
        
        function h = plot(sObj,h0,feature,overlay)
            %plot   Plots the requested spectral features
            %
            %USAGE:
            %     sObj.plot
            % h = sObj.plot(mObj,h0,feature)
            %
            %INPUT ARGUMENTS:
            %    sObj : Spectral features signal instance
            %    mObj : Optional handle to the manager which computed the
            %           signal. Allows, when provided, to superimpose the 
            %      h0 : Handle to already existing figure or subplot
            % feature : Name of a specific feature to plot
            
            % Access the ratemap representation, if handle to the manager
            % was provided
            if nargin>1 && ~isempty(mObj)
                p_sf = sObj.findProcessor(mObj);
                p_rm = p_sf.Dependencies{1};
                rMap = p_rm.Output.Data(:);
                fHz = p_rm.Output.cfHz;
                bPlotRatemap = true;
            else
                bPlotRatemap = false;
            end
             
            % Manage handles
            if nargin < 3 || isempty(h0)
                    h = figure;             % Generate a new figure
                elseif get(h0,'parent')~=0
                    % Then it's a subplot
                    figure(get(h0,'parent')),subplot(h0)
                    h = h0;
                else
                    figure(h0)
                    h = h0;
            end
            
            % Number of subplots
            nFeatures = size(sObj.fList,2);
            nSubplots = ceil(sqrt(nFeatures));
            
            % Time axis
            tSec = 0:1/sObj.FsHz:(size(sObj.Data(:,:),1)-1)/sObj.FsHz;
            
            % Plots
            for ii = 1 : nFeatures
                ax(ii) = subplot(nSubplots,nSubplots,ii);
                switch sObj.fList{ii}
                    case {'variation' 'hfc' 'brightness' 'flatness' 'entropy'}
                        if bPlotRatemap
                            imagesc(tSec,(1:size(fHz,2))/size(fHz,2),10*log10(rMap'));axis xy;
                            hold on;
                        end
                        plot(tSec,sObj.Data(:,ii),'k--','linewidth',2)
                        
                        xlabel('Time (s)')
                        ylabel('Normalized frequency')
                    case {'irregularity' 'skewness' 'kurtosis' 'flux' 'decrease' 'crest'}
                        plot(tSec,sObj.Data(:,ii),'k--','linewidth',2)
                        xlim([tSec(1) tSec(end)])

                        xlabel('Time (s)')
                        ylabel('Feature magnitude')

                    case {'rolloff' 'spread' 'centroid'}
                        if bPlotRatemap
                            imagesc(tSec,fHz,10*log10(rMap'));axis xy;
                            hold on;
                        end
                        plot(tSec,sObj.Data(:,ii),'k--','linewidth',2)

                        xlabel('Time (s)')
                        ylabel('Frequency (Hz)')
                        
                    otherwise
                        error('Feature is not supported!')
                end
                title(['Spectral ',sObj.fList{ii}])
            end
            linkaxes(ax,'x');
            set(gca,'xLim',[0 tSec(end)])
%             set(h,'units','normalized','outerposition',[0 0 1 1])
            
        end
        
        
        
        
    end
    
    
    
    
    
    
    
    
    
    
    
    
end