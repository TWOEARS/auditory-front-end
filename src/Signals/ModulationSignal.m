classdef ModulationSignal < Signal
% This class collects three-dimensional outputs of a modulation filterbank    
    
    properties
        cfHz    % Audio center frequencies of the channels (Hz)
        modCfHz % Modulation center frequencies (Hz)
    end
    
    methods
        
        function sObj = ModulationSignal(fs,name,cfHz,modCfHz,label,data,canal)
            %ModulationSignal   Constructor for the modulation signal class
            %
            %USAGE:
            %   sObj = ModulationSignal(fs,name)
            %   sObj = ModulationSignal(fs,name,cfHz,modCfHz,label,data,canal)
            %
            %INPUT ARGUMENTS:
            %      fs : Sampling frequency (Hz)
            %    name : Name tag for the signal, shouldl be compatible with
            %           variable name syntax.
            %    cfHz : Audio channel center frequencies (Hz)
            % modCfHz : Modulation channel center frequencies (Hz)
            %   label : Label for the signal, to be used e.g. in figures
            %           (default: label = name)
            %    data : Data matrix to construct an object from existing
            %           data. Time should span the first dimension, audio
            %           frequency the second dimension, and modulation
            %           frequency the third. Alternatively, audio and
            %           modulation frequencies can be interleaved in the
            %           second dimension.
            %   canal : Flag indicating 'left', 'right', or 'mono'
            %           (default: canal = 'mono')
            %
            %OUTPUT ARGUMENT:
            %    sObj : Instance of modulation signal object
            
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
            if nargin<4||isempty(modCfHz); modCfHz = []; end
            if nargin<3||isempty(cfHz); cfHz = []; end
            if nargin<1||isempty(fs)
                fs = [];
            end
            
            % Data dimensionality check: if there is a mismatch between
            % provided center frequencies and data dimension, try to
            % transpose the data to fix the problem. If impossible, the
            % provided center frequencies are discarded, data is not
            % transposed, and a warning is issued.
            s = size(data);             % Data dimensions
            n_f = size(cfHz(:),1);      % Number of audio frequency bins
            n_fm = size(modCfHz(:),1);  % Number of modulation freq. bins
            
            if size(s,2)==2
                % Add a third dimension to avoid generating an
                % error
                s = [s 0];
            end
            
            % Check for a mismatch
            
            if ismember(n_f*n_fm,s) && s(3)==0
                % Then the provided data contained interleaved channels,
                % need to sort them out
                
                if s(1) == n_f*n_fm
                    % Transpose the data to have time first
                    data = data.';
                end
                
                % Reshape the data
                data = permute(reshape(data,[size(data,1) n_fm n_f]),[1 3 2]);
                
            elseif ((n_f == s(2))&&(n_fm == s(3)))||(max(s)==0)
                % Then everything should be fine, carry on
                
            elseif (~ismember(n_f,s)||~ismember(n_fm,s))&&(max(s)~=0)
                % Then provided center frequencies do not match the data
                
                warning('Provided vectors of center frequencies do not match the data, ignoring them')
                cfHz = [];
                modCfHz = [];
                
            else
                % Dimensions matches, but a permutation is required
                
                % Find the number of time bins
                n_t = s(s~=n_f);
                n_t = n_t(n_t~=n_fm);
                
                % Permutation vector
                p = [find(n_t==s) find(n_f==s) find(n_fm==s)];
                
                % Request the permutation
                data = permute(data,p);
                
                % Issue a warning
                warning('Data was permuted to match the provided vectors of center frequencies')
                
            end
            
            % NB: This functionality is implemented to allow defining such
            % signals from a 2D matrix with interleaved audio and
            % modulation frequencies, but does not (cannot) check that
            % proper input was provided in this case!
            
            % Populate object properties
            populateProperties(sObj,'Label',label,'Name',name,...
                'Dimensions','nSample x nFilters x nModulationFilters',...
                'FsHz',fs);
            sObj.cfHz = cfHz(:)';
            sObj.Data = data;
            sObj.Canal = canal;
            sObj.modCfHz = modCfHz(:)';
                
            end
            
            
        end
        
        function h = plot(sObj)
            %plot   Plot a modulation signal
            %
            %USAGE:
            %      sObj.plot
            %      sObj.plot(...)
            %  h = sObj.plot(...)
            %
            %INPUT ARGUMENTS
            %  sObj : Signal instance
            %
            %OUTPUT ARGUMENTS
            %     h : Handle to the figure
            %
            %TODO: - Clean up and use plot properties. 
            %      - Add other plot options (given audio frequency?)
            
            % Interleave audio and modulation frequencies for a simple, 2D
            % plot
            
            s = size(sObj.Data);
            data = reshape(permute(sObj.Data,[1 3 2]),[s(1) s(2)*s(3)]);
            
            
            
            h = figure;
            imagesc(20*log10(abs(data.')))
            axis xy
            title([sObj.Label ' (w.i.p.)'])
            xlabel('Time (samples)')
            ylabel('Audio/modulation frequencies')
        end
        
    end
    
    
end