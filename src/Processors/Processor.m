classdef Processor < handle
    
    properties
        Type            % Describes the processing performed
        Input           % Handle to input signal
        Output          % Handle to output signal
        FsHzIn          % Sampling frequency of input, prior to processing
        FsHzOut         % Sampling frequency of output, resulting from processing
        Dependencies    % Cell array listing the dependencies to other signals
        % TO DO: Figure out how to deal with dependencies
    end
    
    methods (Abstract = true)
        out = processChunk(pObj,in)
            % This method should implement the way the processing is
            % handled in the children classes
            % 
            % TO DO: Need to devise a unified structure for in and out data
            % independent of what the processing is. Only the data need to
            % be considered at the moment. Might later be part of a data
            % class. This will then be modified accordingly.
        
        reset(pObj)    
            % This method is called any time a change of parameter implying
            % incompatibility with the stored states of the processor is
            % carried out. The method should reset the states of all
            % filters, and reinitialize components of the processor.
            %
            % TO DO: This might take additional input arguments. TBD
            
        hasParameters(pObj,p)
            % This method should return "true" if the processor has the
            % parameters described in the structure p and "false" if one or
            % more parameter is different. Used by the manager to know
            % when to instantiate a new processor.
            
    end
    
    methods
        function  parValue = getDependentParameter(pObj,parName)
            %getDependentProperty    Finds the value of a parameter in the
            %                        list of dependent processors
            %
            %USAGE:
            %  parValue = pObj.getDependentParameter(parName)
            %
            %INPUT PARAMETERS:
            %      pObj : Processor instance
            %   parName : Parameter name
            %
            %OUTPUT PARAMETERS:
            %  parValue : Value for that parameter. Returns an empty output
            %             if no parameter with the provided name was 
            %             found in the list of dependent processors.
            
            %TODO: Will have to be changed for processors with multiple
            %dependencies
            
            if nargin<2 || isempty(parName)
                warning('%s: No parameter name was specified',mfilename)
                parValue = [];
                return
            end
            
            % Initialization
            parValue = [];
            proc = pObj;
            
            while isempty(parValue)&&~isempty(proc.Dependencies{1})
                
                % Check if current processor has such a parameter
                if isprop(proc,parName)
                    % Then get the corresponding value
                    parValue = proc.(parName);
                else
                    % Else move on to the next dependent processor
                    proc = proc.Dependencies{1};
                end
                
            end
            
        end
    end
    
    methods (Access=protected)
        function pObj = populateProperties(pObj,varargin)
            
            % First check on input
            if mod(size(varargin,2),2)||isempty(varargin)
                error('Additional input arguments have to come in pairs of ...,''property name'',value,...')
            end
            
            % List of valid properties % TO DO: should this be hardcoded
            % here?
            validProp = {'Type',...
                         'Dependencies',...
                         'FsHzIn',...
                         'FsHzOut',...
                         'Decimation'};
                     
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
                pObj.(varargin{ii})=varargin{ii+1};
            end
            
            
        end 
    end
    
    
end