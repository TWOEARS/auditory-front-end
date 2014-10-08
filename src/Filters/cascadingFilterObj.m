classdef cascadingFilterObj < filterObj
    % This children class implements cascading filters
    % It adds a new property giving the number of time to cascade, and
    % overloads the processing and reset methods
    
    properties (GetAccess = public)
        cascadeOrder    % Number of time the filter has to be cascaded
    end
    
    methods
        
        function fObj = cascadingFilterObj(cascade)
            
            % Add the new property
            if cascade<=1 || mod(cascade,1)~=0
                error('The cascading order of the filter should be a integer larger than 1.')
            end
            
            fObj.cascadeOrder = cascade;
            
        end
    
        function reset(fObj)
    
            if isempty(fObj.Order)
                error('The filter transfer function must have been specified before initializing its states')
            else
                % Create filter states
                fObj.States = zeros(fObj.Order,fObj.cascadeOrder);
            end
        end
    
        function out = filter(fObj,data)
        
            % Check if filter states are initialized
            if isempty(fObj.States)
                % Initialize filter states
                fObj.reset
            end
            
            % Initialize the output
            out = data;
            
            % Cascade filtering
            for ii = 1:fObj.cascadeOrder
                [out,fObj.States(:,ii)]=filter(fObj.b,fObj.a,out,fObj.States(:,ii));
            end
            
            % Correction for complex-valued transfer function filters
            if ~(fObj.RealTF)
                out = 2*real(out);
            end
            
        end
        
    end
    
end