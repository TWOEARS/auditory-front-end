classdef Signal < handle
    
    properties
        Label           % Used to label the signal (e.g., in plots)
        Name            % Used as an instance name in Matlab
        Dimensions      % String describing the dimensions of the signal
        FsHz            % Sampling frequency
        Data            % Storing actual values
        LastChunk       % Time indexes of beginning and end of latest chunk
        Canal           % Flag keeping track of the channel: 'mono', 'left'
                        %   or 'right'
    end

        
    
    methods (Abstract = true)
        h = plot(sObj,h_prev)
            % This method should create a figure displaying the data in the
            % signal object. As data can be of different nature for
            % different signal children objects, this method remains
            % abstract here.
               
    end
    
    methods
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
            %
            %TO DO: There is no pre-allocation of the Data property of a
            %signal. This causes substantial increase in computation time.
                        
            % Time index of new chunk begining (time is always 1st
            % dimension)
            start = size(sObj.Data,1)+1;
            
            % Append the signal
%             sObj.Data = [sObj.Data; data];
            sObj.Data = cat(1,sObj.Data,data);
            
            % Update LastChunk property
            sObj.LastChunk = [start start+size(data,1)-1];
                        
        end
        
        function clearData(sObj)
            %clearData  Clears the data in a signal object without changing
            %           its other properties
            %
            %USAGE
            %   sObj.clearData
            
            sObj.Data = [];
            
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
                         'Dimensions',...
                         'FsHz',...
                         'Data'};
                     
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
            
            % Latest chunk is empty at instantiation
            sObj.LastChunk = [];
            
        end
    end
end