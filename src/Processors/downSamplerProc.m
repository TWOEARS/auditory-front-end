classdef downSamplerProc < Processor
    
    properties
        WorkingDim      % Index of the dimension to be downsampled
        Ratio           % Downsampling ratio (before/after)
    end
    
    properties (GetAccess = private)
        buffer          % Buffered input signal (necessary if non-integer ratio)
    end
    
    methods
        
        function pObj = downSamplerProc(fs,ratio,dim)
            %downSampler    Instantiate a downsampling processor
            %
            %USAGE:
            %  pObj = downSampler(fs,ratio)
            %  pObj = downSampler(fs,ratio,dim)
            %
            %INPUT PARAMETERS
            %    fs : Sampling frequency
            % ratio : Downsampling ratio
            %   dim : Dimension to work upon (default: 1)
            %
            %OUTPUT PARAMETERS
            %  pObj : Processor instance
            
            if nargin>0     % Safeguard for Matlab empty calls
                
            % Checking input parameters
            if nargin<3||isempty(dim)
                dim = 1;
            end
            
            if nargin<2
                error(['Downsampler processor needs sampling frequency '...
                    'and downsampling ratio to be instantiated.'])
            end
            
            % Populate properties
            pObj.Type = 'Down-sampler';
            pObj.FsHzIn = fs;
            if dim == 1
                % Then time is down-sampled
                pObj.FsHzOut = fs/ratio;
            else
                % Then another dimension is down-sampled. Sampling
                % frequency is unchanged
                pObj.FsHzOut = fs;
            end
            pObj.WorkingDim = dim;
            pObj.Ratio = ratio;
                
            % Empty the buffer
            pObj.buffer = [];
            
            end
            
        end
        
        function out = processChunk(pObj,in)
            %processChunk   Calls the processing for a new chunk of signal
            %
            %USAGE
            %   out = pObj.processChunk(in)
            %
            %INPUT ARGUMENTS
            %  pObj : Processor instance
            %    in : Input signal
            %
            %OUTPUT ARGUMENTS
            %   out : Output (down-sampled) signal
            
            % Append provided input to the buffer
            if ~isempty(pObj.buffer)
                
                % This operation is dimension-dependent!
                in = cat(pObj.WorkingDim,pObj.buffer,in);
                
            end
            
            % TODO: Do nothing and return a warning if input has fewer
            % dimensions than pObj.WorkingDim
            
            % Get buffered input dimensions
            dim = size(in);
            
            % We want to move the dimension along which the downsampling
            % occurs to be the first dimension if needed:
            
            if pObj.WorkingDim~=1
                %  - Generate a permutation order vector
                order = 1:size(dim,2);
                order(1) = pObj.WorkingDim;
                order(pObj.WorkingDim) = 1;

                %  - Permute the dimensions
                in = permute(in,order);
                
                %  - Update the dimension vector
                dim = size(in);
            end
            
            % Get rational fraction approximation of the resampling ratio
            [p,q]=rat(pObj.Ratio);
            
            % Matlab's embedded resample function cannot operate on
            % representations with more than 2 dimensions
            
            if size(dim,2)>2
                % Then additional dimensions are squeezed into one
                in = reshape(in,[dim(1) prod(dim(2:end))]);
                
                % Perform resampling colum-wise 
%                 out = resample(in,p,q);
                out = decimate(in,q/p);
                
                % Re-organize data
                out = reshape(out,[size(out,1) dim(2:end)]);
            else
                % Perform resampling colum-wise 
                out = resample(in,p,q);
            end
            
            % Reorganize the dimensions of the output if they were modified
            if pObj.WorkingDim~=1
                out = permute(out,order);
            end
            
            
        end
            
        function hp = hasParameters(pObj,p)
            %hasParameters  This method compares the parameters of the
            %               processor with the parameters given as input
            %
            %USAGE
            %    hp = pObj.hasParameters(p)
            %
            %INPUT ARGUMENTS
            %  pObj : Processor instance
            %     p : Structure containing parameters to test
            
            % TODO: Find a way to implement this...
            
            hp = 1;
            warning('Method hasParameters() not implemented yet for class downSamplerProc!')
            
        end 
        
        function reset(pObj)
            %reset     Resets the internal states of the processor
             %
             %USAGE
             %      pObj.reset
             %
             %INPUT ARGUMENTS
             %  pObj : Down-sampler processor instance
             
             % Empty the buffer
             pObj.buffer = [];
            
        end
        
    end
   
    
    
end