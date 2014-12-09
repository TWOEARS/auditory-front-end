classdef Parameters < handle
    
    properties (GetAccess = public) % Private?
        map             % Map container for the parameter values
    end
    
    properties (GetAccess = public, Dependent = true)
        description     % Map container for the description of individual parameters
    end
    
    
    methods
        
        function parObj = Parameters(keys,values)
            %Parameters   Constructor for the parameter object class
            
            if nargin<2; values = []; end
            if nargin<1; keys = []; end
            
            % Initialize a map container
            parObj.map = containers.Map('KeyType', 'char', 'ValueType', 'any');
            
            % Populate with provided keys and values
            if size(keys,2)~=size(values,2)
                warning(['Provided keys and values should have the same number of '...
                         'elements. Omitting them.'])
            else
                for ii = 1:size(keys,2)
                    parObj.map(keys{ii}) = values{ii};
                end
            end
            
        end
          
        function processorParameters = getProcessorParameters(parameterObj,processorName)
            %getProcessorParameters     Extract the parameter values used
            %                           for a specific processor
            %
            %USAGE:
            % processorPar =
            %       parameterObj.getProcessorParameters(processorName)
            %
            %INPUT ARGUMENTS:
            %   parameterObj : Instance of parameter object
            %  processorName : Specific processor name
            %
            %OUTPUT ARGUMENTS:
            %   processorPar : New parameter object containing only the
            %                   parameters for that processor
            
            % Get the parameter keys from specific processor
            try
                
                keys = feval([processorName '.getParameterInfo']);
            
            catch
                warning('There is no %s processor, or its getParameterInfo static method is not implemented!',processorName)
                return
            end
            
            % Instantiate a new parameter object
            processorParameters = Parameters();
            
            % Copy the values from parameterObj with corresponding key
            for ii = 1:size(keys,2)
                if parameterObj.value.isKey(keys{ii})
                    processorParameters.map(keys{ii}) = parameterObj.map(keys{ii});
                else
                    warning('No parameter named %s in this object.',keys{ii})
                    processorParameters(keys{ii}) = 'n-a';
                end
            end
            
        end
    
        function description = get.description(parObj)
            % This method will build a list of parameter description when the description
            % property is requested
            
            % Initialize the output
            description = containers.Map('KeyType', 'char', 'ValueType', 'char');
            
            % List of parameter names
            parList = parObj.map.keys;
            
            for ii = 1:size(parList,2)
                description(parList{ii}) = ...
                        Parameters.readParameterDescription(parList{ii});
            end
            
        end
        
        function r = eq(parObj1,parObj2)
            % Overload equality between parameter objects
            
            % NB: Keys are naturally ordered in map containers, no need to do it here
            if isequal(parObj1.map.keys,parObj2.map.keys)
                r = isequal(parObj1.map.values,parObj2.map.values);
            else
                r = 0;
            end
            
        end
        
    end
    
    
    methods (Access = private)
       
        function appendParameters(parObj,newParObj)
            %appendParameters   Appends new parameter properties to an existing object
            %
            %
            
            % Get a list of keyvalues to append
            keyList = newParObj.map.keys;
            
            if any(parObj.map.isKey(keyList))
                warning('Cannot append already existing parameters')
            else
                parObj.map = [parObj.map ; newParObj.map];
            end
            
        end
        
    end
    
    methods (Static)
       
        function text = readParameterDescription(parName)
            %readParameterDescription   Finds the description of a single parameter
            %
            %USAGE:
            %   text = Parameters.readParameterDescription(parName)
            %
            %INPUT ARGUMENTS:
            %   parName : Name of the parameter
            %
            %OUTPUT ARGUMENTS:
            %      text : Associated description
            
            % Find the name of the processor using this parameter
            procName = Processor.findProcessorFromParameter(parName);
            
            % Get the parameter infos
            if ~isempty(procName)
                [names,~,description] = feval([procName '.getParameterInfo']);
                text = description{strcmp(parName,names)};
            else
                text = 'n-a';
            end
            
        end
        
    end
    
end