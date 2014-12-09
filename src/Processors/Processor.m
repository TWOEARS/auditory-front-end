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
        Input
        Output
        isBinaural = false;
        hasTwoOutputs = false;
        FsHzIn
        FsHzOut
        Dependencies
    end

    properties (GetAccess = private)
        bHidden = 0;
    end
    
    properties (GetAccess = protected)
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
            
    end
    
    methods
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
        
        function parStruct = getCurrentParameters(pObj,full_list)
            %getCurrentParameters  This methods returns a list of parameter
            %values used by a given processor.
            %
            %USAGE:
            %   parStruct = pObj.getCurrentParameters
            %   parStruct = pObj.getCurrentParameters(full_list)
            %
            %INPUT PARAMETERS:
            %        pObj : Processor object instance
            %   full_list : Set to true to return also the parameter values
            %               used by parent processors.
            %
            %OUTPUT PARAMETERS:
            %   parStruct : Parameter structure
            
            % TODO: Will have to be modified when introducing processors
            % with multiple parents.
            
            if nargin<2||isempty(full_list)
                full_list = 1;
            end
            
            % Note: The parameters of interest are stored as properties of
            % the processor object. However we are not interested in the
            % general properties contained in this Processor parent class:
            discard_list = properties('Processor');
            
            % Full properties list of the processor instance
            prop_list = properties(pObj);
            
            % Get the list of "interesting" properties
            list = setdiff(prop_list,discard_list);
            
            % Some parameters have same name across different processors
            % and are differenciated by a prefix.
            if full_list
                switch class(pObj)
                    case 'ildProc'
                        prefix = 'ild_';
                    case 'ratemapProc'
                        prefix = 'rm_';
                    case 'autocorrelationProc'
                        prefix = 'ac_';
                    case 'crosscorrelationProc'
                        prefix = 'cc_';
                    otherwise 
                        prefix = '';
                end
            else
                prefix = '';
            end
                
            % Initialize the parameter structure
            parStruct = struct;
            
            % Store the properties values
            for ii = 1:size(list,1)
                parStruct.([prefix list{ii}]) = pObj.(list{ii});
            end
            
            % Access recursively to the properties of parent processors
            if full_list
                % Get the property values of its parent processor
                if ~isempty(pObj.Dependencies{1})
                    parParent = pObj.Dependencies{1}.getCurrentParameters;
                else
                    % Break the recursion
                    parParent = struct;     % Empty structure
                end

                % Merge the two structures
                par_list = fieldnames(parParent);
                for ii = 1:size(par_list,1)
                    parStruct.(par_list{ii}) = parParent.(par_list{ii});
                end
            end            
            
        end
        
        function hp = hasParameters(pObj,parObj)
            
            % Verify the parameters if necessary
            if ismethod(pObj,'verifyParameters')
                pObj.verifyParameters(parObj)
            end
            
            % Extract the parameters related to this processor only
            testParameters = parObj.getProcessorParameters(class(pObj));
            
            % Compare them with current processor parameters
            hp = (pObj.parameters == testParameters);
            
            
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

    methods (Static)
       
        function parObj = getParameterValues(processorName,requestPar)
            %getParameterValues    Returns the default parameter values for a given
            %                      processor, optionally given a specific request
            %
            %USAGE:
            %  values = Processor.getParameterValues(procName,request)
            %
            %INPUT ARGUMENTS:
            %    procName : Name of the processor
            %     request : Structure of non-default requested parameter
            %                values. Returns default values if empty.
            %
            %OUTPUT ARGUMENTS:
            %      values : Map object of parameter values, indexed by
            %                parameter names
            %
            %NB: As overriding of static methods is not possible, getParameterValues
            %methods of subclasses will explicitely call this superclass method for easier
            %code maintenance.
            
            if nargin<2; requestPar = []; end
            
            % Load parameter names and default values
            try
                [names,values] = feval([processorName '.getParameterInfo']);
            catch
                if ~ismember(processorName,Processor.processorList)
                    warning(['There is no ''%s'' processor. Currently valid processor '... 
                             'names are the following: %s'], ...
                             processorName, ...
                             strjoin(Processor.processorList.',', '))
                    parObj = [];
                    return
                else
                    warning(['The .getParameterInfo static method of processor %s ' ...
                             'is not implemented!'],processorName)
                    parObj = [];
                    return
                end
            end
            
            % Put these in a parameter object
            parObj = Parameters(names,values);
            
            % Override the non-default values given in the request
            if ~isempty(requestPar)
                for ii = 1:size(names,2)
                    if requestPar.map.isKey(names{ii})
                        parObj.map(names{ii}) = requestPar.map(names{ii});
                    end
                end
            end
            
            % Verify the parameters if necessary
            dummyProc = feval(processorName);
            
            if ismethod(dummyProc,'verifyParameters')
                dummyProc.verifyParameters(parObj);
            end
            
        end
        
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
            warning(['Could not find a processor which uses parameter ''%s'''],...
                    parameterName)
            procName = [];

        end
        
    end
    
    
end