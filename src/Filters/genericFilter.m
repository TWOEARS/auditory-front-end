classdef genericFilter < filterObj
    
    methods 
        function obj = genericFilter(b,a,fs,struct)
            % genericFilter Design a "generic" filter object from
            %               its transfer function coefficients
            %
            %USAGE
            %       F = genericFilter(b,a)
            %
            %INPUT ARGUMENTS
            %       b : filter coefficient numerator
            %       a : filter coefficient denominator
            %      fs : sampling frequency on which the filter operates
            %  struct : implementation of filter structure (default:
            %           'Direct-Form II Transposed')
            %
            %OUTPUT ARGUMENT
            %       F : filter object
            
            if nargin>0
                % CHECK INPUT ARGUMENTS
                if nargin<2
                    error('Provide both numerator and denominator filter coefficients')
                end
                if nargin<3 || isempty(fs); fs=1; end
                if nargin<4 || isempty(struct); struct = 'Direct-Form II Transposed'; end

                % POPULATE THE FILTER OBJECT PROPERTIES
                obj = populateProperties(obj,'Type','Generic Filter',...
                    'Structure',struct,'FsHz',fs,...
                    'b',b,'a',a);
            end
        end
    end
end