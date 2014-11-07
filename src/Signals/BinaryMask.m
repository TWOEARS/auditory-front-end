classdef BinaryMask < TimeFrequencySignal
    
    % This class inherits the TimeFrequencySignal only to overload the plot routine
    
    properties (GetAccess = protected)
        maskedSignal
    end
    
    methods
        function sObj = BinaryMask(fs,bufferSize_s,name,cfHz,label,data,channel,maskedSignal)
            
            % Call to the superconstructor
            sObj = sObj@TimeFrequencySignal(fs,bufferSize_s,name,cfHz,label,data,channel);
            
            sObj.maskedSignal = maskedSignal;
            
        end
        
        function h = plot(sObj,h0,p)
            

            
            if nargin < 3 || isempty(p) 
                % Get default plotting parameters
                p = getDefaultParameters([],'plotting');
            else
                p.fs = sObj.FsHz;
                p = parseParameters(p);
            end
            
            if nargin < 2 || isempty(h0)
                h0 = [];
            end
            
            % Mask color
            color = reshape(p.binaryMaskColor,1,1,3);
            
            % Plot the masked signal without colorbar
            p.bColorbar = 0;
            h = sObj.maskedSignal.plot(h0,p);
            hold on
            
            % Get x and y axis
            rm = get(get(h,'children'),'children');
            x = get(rm,'XData');
            y = get(rm,'YData');
            
            % Plot the mask
            im = imagesc(x,y,sObj.Data(:).');
            
            % Make mask zeros transparent
            set(im,'AlphaDataMapping','none','AlphaData',sObj.Data(:).')
            
            % And paint it black (or any other color for that matter..)
            set(im,'CData',repmat(color,size(y,2),size(x,2)))
            
            % Overwrite the title
            if isfield(p,'fsize_title')
                title(sObj.Label,'fontsize',p.fsize_title)
            else
                title(sObj.Label)
            end
            
            
        end
        
    end
    
    
    
    
    
    
end