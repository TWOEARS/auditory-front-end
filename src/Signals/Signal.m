classdef Signal < handle
    
    properties
        Label           % Used to label the signal (e.g., in plots)
        Name            % Used as an instance name in Matlab
        Dimensions      % String describing the dimensions of the signal
        FsHz            % Sampling frequency
        Canal           % Flag keeping track of the channel: 'mono', 'left'
                        %   or 'right'
    end
    
    properties (SetAccess = protected)
        Data;
    end


    methods (Abstract = true)
        h = plot(sObj,h_prev)
            % This method should create a figure displaying the data in the
            % signal object. As data can be of different nature for
            % different signal children objects, this method remains
            % abstract here.
               
    end
    
    methods
        
        function sObj = Signal( fs, bufferSize_s, bufferElemSize )
            sObj.FsHz = fs;
            bufferSizeSamples = ceil( bufferSize_s * sObj.FsHz );
            sObj.Data = circVBuf( bufferSizeSamples, bufferElemSize );
        end
        
        function appendChunk(sObj,data)
            %appendChunk   This method appends the chunk in data to the
            %               signal object
            %
            %USAGE
            %   sObj.appendChunk(data)
            %
            %INPUTS
            %   sObj : Signal object
            %   data : New chunk (re. time) to be appended to existing data
            %
            %DISCLAIMER:
            %This method is likely called numerous times hence there is no
            %checking on the provided data chunk (e.g., regarding its
            %dimensionality) to improve efficiency. Although for practical
            %reason it remains public, it should not be called "manually"
            %by a user.
            
            sObj.Data.append( data );
        end

        function setData(sObj, data)
            sObj.Data.clear();
            sObj.appendChunk(data);
        end
        
        function clearData(sObj)
            %clearData  Clears the data in a signal object without changing
            %           its other properties
            %
            %USAGE
            %   sObj.clearData
            
            sObj.Data.clear();
        end
        
        function sb = getSignalBlock(sObj,blocksize_s)
            %getSignalBlock   Returns this Signal object's signal data
            %truncated to the last blocksize_s seconds. In case of too
            %little data, the block gets filled with zeros from beginning.
            %
            %USAGE:
            %    sb = sObj.getSignalBlock(blocksize_s)
            %
            %INPUT ARGUMENTS:
            %    sObj : Signal instance
            %    blocksize_s : length of the required data block in seconds
            %
            %OUTPUT ARGUMENTS:
            %    sb : signal data block
            
            blocksize_samples = ceil( sObj.FsHz * blocksize_s );
            % TODO: this assumes that time is on dimension 1. Verify!
            blockStart = max( 1, length( sObj.Data ) - blocksize_samples + 1 );
            sb = sObj.Data(blockStart:end,:,:,:,:);
            if size( sb, 1 ) < blocksize_samples
                sb = [zeros( blocksize_samples - size(sb,1), size(sb,2) ); sb];
            end
            
        end
            
        function pObj = findProcessor(sObj,mObj)
            %findProcessor   Returns a handle to the processor instance
            %that generated this signal.
            %
            %USAGE:
            %    pObj = sObj.findProcessor(mObj)
            %
            %INPUT ARGUMENTS:
            %    sObj : Signal instance
            %    mObj : Manager instance containing the sought processor
            %
            %OUTPUT ARGUMENTS:
            %    pObj : Handle to the processor instance which computed the
            %           signal (empty if none found)
            
            % NB: This brute force approach could be made more subtle by
            % looking into the type of signal sObj is. However it shouldn't
            % be necessary.
            
            % Number of instantiated processors
            n = numel(mObj.Processors);
            
            % Initialize output
            pObj = [];
            
            % Loop over all of them
            for ii = 1:n
                % Check that it is actually a processors
                if isa(mObj.Processors{ii},'Processor')
                    % Check if it outputs the signal of interest
                    if sObj == mObj.Processors{ii}.Output
                        pObj = mObj.Processors{ii};
                    end
                end
            end 
        end
        
        function parStruct = getParameters(sObj,mObj)
            %getParameters  This methods returns a list of parameter
            %values used to compute a given signal.
            %
            %USAGE:
            %   parStruct = sObj.getParameters(mObj)
            %
            %INPUT PARAMETERS:
            %   sObj : Signal object instance
            %   mObj : Manager instance containing the processor responsible
            %   for computing the signal of interest
            %
            %OUTPUT PARAMETERS:
            %   parStruct : Parameter structure
            
            % Find the processor that computed sObj
            proc = sObj.findProcessor(mObj);
            
            % Get the parameters under which this processor was running
            if ~isempty(proc)
                parStruct = proc.getCurrentParameters;
            else
                % Couldn't find the processor in charge
                parStruct = struct;
                % Return a warning, unless sObj is the original ear signal
                if ~strcmp(sObj.Name,'signal')
                    warning('Could not find the processor that computed the signal ''%s.''',sObj.Name)
                end
            end
            
        end
        
    end
    
    methods (Access = protected)
        function sObj = populateProperties(sObj,varargin)
            % This protected method is called by class childrens to
            % populate the default properties of the signal class, in order
            % to avoid code repetition.
            
            % First check on input
            if mod(size(varargin,2),2)||isempty(varargin)
                error('Additional input arguments have to come in pairs of ...,''property name'',value,...')
            end
            
            % List of valid properties % TO DO: should this be hardcoded
            % here?
            validProp = {'Label',...
                         'Name',...
                         'Dimensions'};
                     
            % Loop on the additional arguments
            for ii = 1:2:size(varargin,2)-1
                % Check that provided property name is a string
                if ~ischar(varargin{ii})
                    error('Property names should be given as strings, %s isn''t one!',num2str(varargin{ii}))
                end
                % Check that provided property name is valid
                if ~ismember(varargin{ii},validProp)
                    error('Property name ''%s'' is invalid',varargin{ii})
                end
                % Then add the property value
                sObj.(varargin{ii})=varargin{ii+1};
            end
            
        end
    end
end