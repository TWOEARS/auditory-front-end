classdef Processor < handle
%PROCESSOR Superclass for the auditory front-end (AFE) framework processors.
%   This abstract class defines properties and methods that are shared among all processor
%   classes of the AFE.
%
%   PROCESSOR properties:
%       Type          - Describes briefly the processing performed
%       Input         - Handle to input signal
%       Output        - Handle to output signal
%       FsHzIn        - Sampling frequency of input (i.e., prior to processing)
%       FsHzOut       - Sampling frequency of output (i.e., resulting from processing)
%       Dependencies  - Handle to the processor that generated this processor's input
%       isBinaural    - Flag indicating the need for two inputs
%       hasTwoOutputs - Flag indicating the need for two outputs
%
%   PROCESSOR abstract methods (implemented by each subclasses):
%       processChunk  - Returns the output from the processing of a new chunk of input
%       reset         - Resets internal states of the processor, if any
%       hasParameters - Returns true if the processor uses the parameters passed as input
%
%   PROCESSOR methods:
%       getDependentParameter - Returns the value of a parameter used in a dependency
%       getCurrentParameters  - Returns the parameter values used by this processor
%
%   See also Processors (folder)

    properties
        Type
    end
    
    properties (Hidden = true)
        Input = {};
        Output = {};
        isBinaural = false;
        hasTwoOutputs = false;
        FsHzIn
        FsHzOut
        UpperDependencies = {};
        LowerDependencies = {};
        Channel
    end

    properties (GetAccess = private)
        bHidden = 0;
    end
    
    properties %(GetAccess = protected)
        parameters
    end
    
    methods (Abstract = true)
        out = processChunk(pObj,in)
            % This method should implement the way the processing is
            % handled in the children classes.
        
        reset(pObj)    
            % This method is called any time a change of parameter implying
            % incompatibility with the stored states of the processor is
            % carried out. The method should reset the states of all
            % filters, and reinitialize components of the processor.
            %
            % TO DO: This might take additional input arguments. TBD
            
        verifyParameters(pObj)
            % This method is called at instantiation of the processor, to verify that the
            % provided parameters are valid, correct conflicts if needed, and add default 
            % values to parameters missing in the list.
            
    end
    
    methods
        function pObj = Processor(fsIn,fsOut,procName,parObj)
            %Super-constructor
            
            if nargin>0
            
            % Store specific parameters only
            pObj.parameters = parObj.getProcessorParameters(procName);
            
            % Populate properties
            pInfo = feval([procName '.getProcessorInfo']);
            pObj.Type = pInfo.name;
            pObj.FsHzIn = fsIn;
            pObj.FsHzOut = fsOut;
%             pObj.Dependencies = feval([procName '.getDependency']);

            pObj.verifyParameters;
            
            end
            
        end
        
        function  parValue = getDependentParameter(pObj,parName)
            %getDependentParameter   Finds the value of a parameter in the
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
            
            while isempty(parValue)
                
                if proc.parameters.map.isKey(parName)
                    parValue = proc.parameters.map(parName);
                else
                    if isempty(proc.LowerDependencies{1})
                        break
                    end
                    proc = proc.LowerDependencies{1};
                end
                
            end
            
        end
        
        function parObj = getCurrentParameters(pObj,bRecursiveList)
            %getCurrentParameters  This methods returns a list of parameter
            %values used by a given processor.
            %
            %USAGE:
            %   parObj = pObj.getCurrentParameters
            %   parObj = pObj.getCurrentParameters(full_list)
            %
            %INPUT PARAMETERS:
            %           pObj : Processor object instance
            % bRecursiveList : Set to true to return also the parameter values
            %                  used by parent processors.
            %
            %OUTPUT PARAMETERS:
            %   parObj : Parameter object instance
            
            % TODO: Will have to be modified when introducing processors
            % with multiple parents.
            
            if nargin<2||isempty(bRecursiveList)
                bRecursiveList = 0;
            end
            
            % Make a copy of the processor parameter
            parObj = pObj.parameters.copy;
            
            % Add dependencies if necessary
            if bRecursiveList && ~isempty(pObj.Dependencies{1})
                while 1
                    if ~isempty(pObj.Dependencies{1})
                        pObj = pObj.Dependencies{1};
                    else
                        break
                    end
                    parObj.appendParameters(pObj.parameters)
                end
            end
            
            
        end
        
        function hp = hasParameters(pObj,parObj)
            %TODO: Write h1
            
            % Extract the parameters related to this processor only
            testParameters = parObj.getProcessorParameters(class(pObj));
            
            % Compare them with current processor parameters
            hp = (pObj.parameters == testParameters);
            
            
        end
        
    end
    
    methods (Access=protected)
        
        function extendParameters(pObj)
            %extendParameters   Add missing parameters in a processor
            
            if ~isprop(pObj,'parameters') || isempty(pObj.parameters)
                pObj.parameters = Parameters;
            end
            
            pObj.parameters.updateWithDefault(class(pObj));
            
        end
        

    end
    
    methods (Hidden = true)
        
        function addUpperDependencies(pObj,dependentProcs)
            %ADDUPPERDEPENDENCIES   Populate link to higher processors relying on this one
            
            pObj.UpperDependencies = [pObj.UpperDependencies dependentProcs];
            
        end
        
        function addLowerDependencies(pObj,dependentProcs)
            %ADDLOWERDEPENDENCIES   Populate link to lower processors this one relies on.
            % Likewise, will will add the current processor as an upper dependency in
            % those processors.
            
            pObj.LowerDependencies = [pObj.LowerDependencies dependentProcs];
            for ii = 1:size(dependentProcs,2)
                dependentProcs{ii}.addUpperDependencies(pObj);
            end
            
        end
        
        function addInput(pObj,dependency)
            %ADDINPUT   Adds a signal to the list of input of the processor
            % Will consider that the input signal is the output of the dependency. If
            % the dependency has a left- and right-channel output, will pick the suitable
            % one.
            % Should the input attribution works in any other way for a given processor,
            % this method should be overloaded for that specific children processor.
            
            % NB: 'dependency' should be a cell array with a handle to a single processor,
            % with a single output, or maximally one output per channel.
            
            if iscell(dependency) && numel(dependency)==1 && ...
                    size(dependency{1}.Output,2)<=2
                dependency = dependency{1};
            else
                error(['Cannot add input for that specific processor. Consider ' ...
                    'overloading this method in the children processor class '...
                    'definition.'])
            end
            
            % Number of already existing inputs
            ii = size(pObj.Input,2);
            
            if size(dependency.Output,2) == 1
                % Then it is a single output -> single input scenario
                pObj.Input{ii+1,1} = dependency.Output{1};
                
            else
                % Then the dependency has two outputs corresponding to two channels
                
                % TODO: They should be already be ordered, the following check should be
                % removed after testing and is here for debugging only.
                if strcmp(dependency.Output{1}.Channel,'left') && ...
                        strcmp(dependency.Output{2}.Channel,'right')
                    pObj.Input{ii+1,1} = dependency.Output{1};
                    pObj.Input{ii+1,2} = dependency.Output{2};
                elseif strcmp(dependency.Output{1}.Channel,'right') && ...
                        strcmp(dependency.Output{2}.Channel,'left')
                    pObj.Input{ii+1,1} = dependency.Output{2};
                    pObj.Input{ii+1,2} = dependency.Output{1};
                    warning('Outputs of dependent processors were incorrectly ordered, consider investigating.')
                else
                    error('Something is wrong with the outputs of the dependent processor, investigate.')
                end
            end
            
        end
        
        function addOutput(pObj,sObj)
            %ADDOUTPUT  Adds a signal to the list of output of the processor
            
            if iscell(sObj)
                % Then there are multiple outputs, pseudo-recursive call
                for ii = 1:numel(sObj)
                    pObj.addOutput(sObj{ii});
                end
            else
                % Which column in the cell array should the signal go?
                if strcmp(sObj.Channel,'right')
                    jj = 2;
                elseif strcmp(sObj.Channel,'left') || strcmp(sObj.Channel,'mono')
                    jj = 1;
                else    % NB: Will be removed after testing
                    error('Need to specify a channel for output signal')
                end

                ii = max(size(pObj.Output,1),1);

                if isempty(pObj.Output) || isempty(pObj.Output{ii,jj})
                    pObj.Output{ii,jj} = sObj;
                else
                    % Then sObj is an additional output and should be put on another line
                    pObj.Output{ii+1,jj} = sObj;
                end
            end
            
        end
        
        function output = instantiateOutput(pObj,dObj)
            %INSTANTIATEOUTPUT  Instantiate the output signal for this processor
            %
            %NB: This method can be overloaded in children processor where output differs
            %from standard (e.g., multiple output)
            
            sig = feval(pObj.getProcessorInfo.outputType, ...
                        pObj, ...
                        dObj.bufferSize_s, ...
                        pObj.Channel);
            
            dObj.addSignal(sig);
            
            output = {sig};
            
        end
        
    end

    methods (Static)
       
        function pList = processorList()
            %Processor.processorList    Returns a list of valid processor object names
            %
            %USAGE:
            %  pList = Processor.processorList
            %
            %OUTPUT ARGUMENT:
            %  pList : Cell array of valid processor names
            
            % Processors directory
            processorDir = mfilename('fullpath');
            
            % Get file information
            fileList = listFiles(processorDir(1:end-10),'*.m',-1);
            
            % Extract name only
            pList = cell(size(fileList));
            for ii = 1:size(fileList)
                % Get file name
                [~,fName] = fileparts(fileList(ii).name);
                
                % Check if it is a valid processor
                try
                    p = feval(str2func(fName));
                    if isa(p,'Processor') && ~p.bHidden
                        pList{ii} = fName;
                    else
                        pList{ii} = [];
                    end
                catch   % In case fName is not executable without inputs
                    pList{ii} = [];
                end
                
            end
                
            % Remove empty elements
            pList = pList(~cellfun('isempty',pList));
             
        end
        
        function list = requestList()
            %Processor.requestList  Returns a list of supported request names
            %
            %USAGE:
            %   rList = Processor.requestList
            %
            %OUTPUT ARGUMENT:
            %   rList : Cell array of valid requests
            
            % Get a list of processor
            procList = Processor.processorList;
            
            list = cell(size(procList,1),1);
            
            for ii = 1:size(list,1)
                pInfo = feval([procList{ii} '.getProcessorInfo']);
                list{ii} = pInfo.requestName;
            end
            
        end
        
        function procName = findProcessorFromParameter(parameterName)
            %Processor.findProcessorFromParameter   Finds the processor that uses a given parameter
            %
            %USAGE:
            %   procName = Processor.findProcessorFromParameter(parName)
            %
            %INPUT ARGUMENT:
            %   parName : Name of the parameter
            %
            %OUTPUT ARGUMENT:
            %  procName : Name of the processor using that parameter

            % Get a list of processor
            procList = Processor.processorList;

            % Loop over each processor
            for ii = 1:size(procList,1)
                try
                    procParNames = feval([procList{ii} '.getParameterInfo']);
                    
                    if ismember(parameterName,procParNames)
                        procName = procList{ii};
                        return
                    end
                    
                catch
                    % Do not return a warning here, as this is called in a loop
                end

            end

            % If still running, then we haven't found it
            warning('Could not find a processor which uses parameter ''%s''',...
                    parameterName)
            procName = [];

        end
        
        function procName = findProcessorFromSignal(signalName)
            %Processor.findProcessorFromSignal Finds the processor that generates a signal
            %
            %USAGE:
            %   procName = Processor.findProcessorFromSignal(signalName)
            %
            %INPUT ARGUMENT:
            %   signalName : Name of the signal
            %
            %OUTPUT ARGUMENT:
            %     procName : Name of the processor generating that signal
            
            procList = Processor.processorList;
            procName = cell(0);
            
            for ii = 1:size(procList,1)
                pInfo = feval([procList{ii} '.getProcessorInfo']);
                currentName = pInfo.requestName;
                if strcmp(currentName,signalName)
                    procName = [procName; procList{ii}]; %#ok<AGROW>
                end
            end
            
            % Change to string if single output
            if size(procName,1) == 1
                procName = procName{1};
            end
            
            
            
        end
        
    end
    
    
end