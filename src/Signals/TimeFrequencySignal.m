classdef TimeFrequencySignal < Signal
    % This children signal class regroups all signal that are some sort of
    % time frequency representation (e.g., spectrograms, filterbank
    % outputs, etc...)
    
    properties
        cfHz        % Center frequencies of the frequency channels
    end
       
    properties (GetAccess = protected)
%         isSigned    % True for representations that are multi-channel 
                    % waveforms (e.g., a filterbank output) as opposed to
                    % spectrograms. Used for plotting only.
    end
    
    methods 
        function sObj = TimeFrequencySignal(fs,bufferSize_s,name,cfHz,label,data,channel)
            %TimeFrequencySignal    Constructor for the "time-frequency
            %                       representation" children signal class
            %
            %USAGE 
            %     sObj = TimeFrequencySignal(fs,name)
            %     sObj = TimeFrequencySignal(fs,name,cfHz,label,data,channel)
            %
            %INPUT ARGUMENTS
            %       fs : Sampling frequency (Hz)
            %     name : Name tag of the signal, should be compatible with
            %            variable name syntax.
            %     cfHz : Center frequencies of the channels in Hertz.
            %    label : Label for the signal, to be used in e.g. figures
            %            (default: label = name)
            %     data : Data matrix to construct an object from existing 
            %            data. Time should span lines and frequency spans
            %            columns.
            %   channel : Flag indicating 'left', 'right', or 'mono'
            %            (default: channel = 'mono')
            %OUTPUT ARGUMENT
            %     sObj : Time-frequency representation signal object 
            %            inheriting the signal class
             
            sObj = sObj@Signal( fs, bufferSize_s, length(cfHz) );
            
            if nargin>0     % Safeguard for Matlab empty calls
            
            % Check input arguments
            if nargin<3||isempty(name)
                name = 'tfRepresentation';
                warning(['A name tag should be assigned to the signal. '...
                    'The name %s was chosen by default'],name)
            end
            if nargin<7; channel = 'mono'; end
            if nargin<6||isempty(data); data = []; end
            if nargin<5||isempty(label)
                label = name;
            end
            if nargin<4||isempty(cfHz); cfHz = []; end
            if nargin<1||isempty(fs)
%                 error('The sampling frequency needs to be provided')
                fs = [];
            end
            
            % N.B: We are not checking the dimensionality of the provided
            % data and leave this to the user's responsibility. Assuming
            % for example that there should be more frequency bins than
            % time samples might not be compatible with processing in short
            % time chunks.
            
            % Populate object properties
            populateProperties(sObj,'Label',label,'Name',name,...
                'Dimensions','nSamples x nFilters');
            sObj.cfHz = cfHz;
            sObj.setData( data );
            sObj.Channel = channel;
            
            end
            
        end
        
        function h = plot(sObj,h0,p)
            %plot       This method plots the data from a time-frequency
            %           domain signal object
            %
            %USAGE
            %       sObj.plot
            %       sObj.plot(h_prev,p)
            %       h = sObj.plot(...)
            %
            %INPUT ARGUMENT
            %  h_prev : Handle to an already existing figure or subplot
            %           where the new plot should be placed
            %       p : Structure of non-default plot parameters (generated
            %           from genParStruct.m)
            %
            %OUTPUT ARGUMENT
            %       h : Handle to the newly created figure
            
            if ~isempty(sObj.Data)
            
                % Decide if the plot should be on a linear or dB scale
                switch sObj.Name
                    case {'gammatone','ild','ic','itd','onset_strength','offset_strength'}
                        do_dB = 0;
                    case {'innerhaircell','ratemap_magnitude','ratemap_power'}
                        do_dB = 1;
                    otherwise 
                        warning('Cannot plot this object')
                end
            
                % Manage plotting parameters
                if nargin < 3 || isempty(p) 
                    % Get default plotting parameters
                    p = getDefaultParameters([],'plotting');
                else
                    p.fs = sObj.FsHz;   % Add the sampling frequency to satisfy parseParameters
                    p = parseParameters(p);
                end
                
                if do_dB
                    if strcmp(sObj.Name,'ratemap_power')
                        data = 10*log10(abs(sObj.Data(:).'));
                    else
                        % Get the data in dB
                        data = 20*log10(abs(sObj.Data(:).'));
                    end
                else
                    data = sObj.Data(:).';
                end

                % Generate a time vector
                t = 0:1/sObj.FsHz:(size(data,2)-1)/sObj.FsHz;

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

                % Managing frequency axis ticks for auditory filterbank
                %
                % Find position of y-axis ticks
                M = size(sObj.cfHz,2);  % Number of channels
                n_points = 500;         % Number of points in the interpolation
                interpolate_ticks = spline(1:M,sObj.cfHz,...
                    linspace(0.5,M+0.5,n_points));
                %
                % Restrain ticks to signal range (+/- a half channel)
                aud_ticks = p.aud_ticks;
                aud_ticks=aud_ticks(aud_ticks<=interpolate_ticks(end));
                aud_ticks=aud_ticks(aud_ticks>=interpolate_ticks(1));
                n_ticks = size(aud_ticks,2);        % Number of ticks
                ticks_pos = zeros(size(aud_ticks)); % Tick position
                %
                % Find index for each tick
                for ii = 1:n_ticks
                    jj = find(interpolate_ticks>=aud_ticks(ii),1);
                    ticks_pos(ii) = jj*M/n_points;
                end

                
                % Set the color map
                try
                    colormap(p.colormap)
                catch
                    warning('No colormap %s is available, using ''jet''.',p.colormap)
                    colormap('jet')
                end
                
                % Plot the figure
                switch sObj.Name
                    case 'gammatone'
                        waveplot(data.',t,sObj.cfHz,[],[]);
                    otherwise
                        imagesc(t,1:M,data)  % Plot the data
                        axis xy              % Use Cartesian coordinates
                        
                        % Set up y-axis
                        set(gca,'YTick',ticks_pos,...
                            'YTickLabel',aud_ticks,'fontsize',p.fsize_axes,...
                            'fontname',p.ftype)
                
                        if p.bColorbar
                            colorbar             % Display a colorbar
                        end
                end

                % Set up a title
                if ~strcmp(sObj.Channel,'mono')
                    pTitle = [sObj.Label ' - ' sObj.Channel];
                else
                    pTitle = sObj.Label;
                end
                
                % Set up axes labels
                xlabel('Time (s)','fontsize',p.fsize_label,'fontname',p.ftype)
                ylabel('Frequency (Hz)','fontsize',p.fsize_label,'fontname',p.ftype)
                title(pTitle,'fontsize',p.fsize_title,'fontname',p.ftype)

                % Set up plot properties
                

                % Scaling the plot
                switch sObj.Name
                    case {'innerhaircell','ratemap_magnitude','ratemap_power'}
                        m = max(data(:));    % Get maximum value for scaling
                        set(gca,'CLim',[m-p.dynrange m])

                    case {'ild','itd'}
                        m = max(abs(data(:)))+eps;
                        set(gca,'CLim',[-m m])

                    case 'ic'
                        set(gca,'CLim',[0 1])

                end
            else
                warning('This is an empty signal, cannot be plotted')
            end
                
            
        end
    end
end
