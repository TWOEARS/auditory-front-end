classdef bwFilter < filterObj
    
    methods
        function obj = bwFilter(fs,order,cutOffHz,struct,cascade)
            if nargin > 0
                if nargin < 4||isempty(struct); struct = 'Direct-Form II Transposed'; end
                if nargin < 3; cutOffHz = 1000; end % Dau1996 model
                if nargin < 2; order = 2; end % Dau1996
                
                % Generate filter coefficients
                [b,a]=butter(order,cutOffHz/(0.5*fs),'low');
                
                % Populate filter properties
                obj = populateProperties(obj,'Type',...
                    'Butterworth low-pass filter','Structure',...
                struct,'FsHz',fs,'b',b,'a',a);
               
                
            end
        end
    end
    
end