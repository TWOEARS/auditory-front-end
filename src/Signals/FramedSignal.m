classdef FramedSignal < Signal
    
    properties
        frameFsHz      % Sampling frequency inside  
    end
    
    methods
    
        function sObj = FramedSignal(fs,frameFs,name,label,canal)
            %FramedSignal   Constructor for the framed signal class
            %
            %USAGE:
            %   sObj = FramedSignal(fs,frameFs)
            %   sObj = FramedSignal(fs,frameFs,name,label,canal)
            %
            %INPUT ARGUMENTS
            %      fs : Sampling frequency (inverse of frame step-size)
            % frameFs : Sampling frequency inside a frame (Hz)
            %    name : Name tag of the signal
            %   label : Label for the signal
            %   canal : 'left', 'right', or 'mono' (default)
            %
            %OUTPUT ARGUMENTS
            %    sObj : Signal instance
            
            if nargin>0
                
            if nargin<5||isempty(canal);canal='mono';end
            if nargin<3||isempty(name);name='framed_signal';end
            if nargin<4||isempty(label);label=name;end
            
            if nargin<2
                error('Sampling frequencies are needed to instantiate a framed signal')
            end
            
            % Populate signal properties
            populateProperties(sObj,'Label',label,'Name',name,...
                'Dimensions','nFrames x frameSize','FsHz',fs);
            sObj.frameHz = frameFs;
                
                
            end
            
        end
        
        function  h = plot(sObj,h0)
            % TO DO: Implement (if that is ever needed)
            h = 1;
        end
        
    end
    
end