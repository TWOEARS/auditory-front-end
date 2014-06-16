classdef TimeDomainSignal < Signal
    
    properties
        % Only inherited properties
    end
    
    methods
        function sObj = TimeDomainSignal(fs,name,label,data,canal)
            %TimeDomainSignal       Constructor for the "time domain signal"
            %                       children signal class
            %
            %USAGE
            %     sObj = TimeDomainSignal(fs)
            %     sObj = TimeDomainSignal(fs,name,label)
            %     sObj = TimeDomainSignal(fs,name,label,data,canal)
            %
            %INPUT ARGUMENTS
            %       fs : Sampling frequency (Hz)
            %     name : Formal name for the signal (default: name =
            %            'time')
            %    label : Label for the signal, to be used in e.g. figures
            %            (default: label = 'Waveform')
            %     data : Vector of amplitudes to construct an object from
            %            existing data
            %    canal : Flag indicating 'left', 'right', or 'mono'
            %            (default: canal = 'mono')
            
            %
            %OUTPUT ARGUMENT
            %     sObj : Time domain signal object inheriting the signal class
            
            if nargin>0  % Failproof for Matlab empty calls
            
            % Check input arguments
            if nargin<5; canal = 'mono'; end
            if nargin<4; data = []; end
            if nargin<3||isempty(label); label = 'Waveform'; end
            if nargin<2||isempty(name); name = 'time'; end
            %if nargin<1; fs = []; end
            
            % Check dimensionality of data if it was provided
            if ~isempty(data) && min(size(data))>1
                error(['The data used to instantiate this object should be a' ...
                    'single vector of amplitude values'])
            end
            
            % Format data to a column vector
            data = data(:);
            
            % Populate object properties
            populateProperties(sObj,'Label',label,'Name',name,...
                'Dimensions','nSamples x 1','FsHz',fs);
            sObj.Data = data;
            sObj.Canal = canal;
            
            end
        end
       
        function h = plot(sObj,h_prev)
            %plot       This method plots the data from a time domain
            %           signal object
            %
            %USAGE
            %       sObj.plot
            %       sObj.plot(h_prev)
            %       h = sObj.plot(...)
            %
            %INPUT ARGUMENT
            %  h_prev : Handle to an already existing figure, to plot
            %           alongside another signal
            %
            %OUTPUT ARGUMENT
            %       h : Handle to the newly created figure
            
            % TO DO: A .m file could be generated, that would contain
            % prefered properties for plots
            
            % Check input
            if nargin<2
                h_prev = [];
            end
            
            if ~isempty(h_prev)
                figure(h_prev)
                h = h_prev;
                hold on
            else
                h = figure();
            end
            
            if ~isempty(sObj.Data)
                
                % Get default plotting parameters
                p = getDefaultParameters([],'plotting');

                % Generate a time axis
                t = 0:1/sObj.FsHz:(length(sObj.Data)-1)/sObj.FsHz;

                % Plot
                plot(t,sObj.Data,'color',p.color,'linewidth',p.linewidth_s)
                xlabel('Time (s)','fontsize',p.fsize_label,'fontname',p.ftype)
                ylabel('Amplitude','fontsize',p.fsize_label,'fontname',p.ftype)
                title(sObj.Label,'fontsize',p.fsize_title,'fontname',p.ftype)
                set(gca,'fontsize',p.fsize_axes,'fontname',p.ftype)
            
            else
                warning('This is an empty signal, cannot be plotted')
            end
                
            
        end
        
        function play(sObj)
            %play       Playback the audio from a time domain signal
            %
            %USAGE
            %   sObj.play()
            %
            %INPUT ARGUMENTS
            %   sObj : Time domain signal object
            
            sound(sObj.Data,sObj.FsHz)
            
        end
        
    end
end