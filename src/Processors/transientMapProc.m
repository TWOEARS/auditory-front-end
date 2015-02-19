classdef transientMapProc < Processor
%TRANSIENTMAPPROC Binary onset and offset maps processor.    
%   Based on the transient strength which is derived from the corresponding 
%   onset strength and offset strength processor, a binary decision about 
%   transient activity is formed, where only the most salient information
%   is retained. This can be used to group the acoustic input according to 
%   individual auditory events [1].
%
%   TRANSIENTMAPPROC properties:
%        minStrengthdB   - Minimum transient strength for mapping
%        minSpread       - Minimum spread of the transient (number of time-frequency units)
%        fuseWithinSec   - Time constant below which transients are fused
%        minValuedB      - Lower limit for the input representation below which transient are discarded
%
%   See also: Processor, ratemapProc, onsetProc, offsetProc
%
%   Reference:
%   [1] Turgeon, M., Bregman, A. S., and Ahad, P. A. (2002), "Rhythmic 
%       masking release: Contribution of cues for perceptual organization
%       to the cross-spectral fusion of concurrent narrow-band noises," 
%       Journal of the Acoustical Society of America 111(4), pp. 1819?1831.

    properties (SetAccess = protected)
        minStrengthdB   % Minimum transient strength for mapping
        minSpread       % Minimum spread of the transient (number of frequency channels)
        fuseWithinSec   % Events within that period (in sec) are fused together
        minValuedB      % Lower limit for the input representation below which transient are discarded
    end
    
    properties (GetAccess = private)
        buffer          % Last fuseWithinSec seconds of input chunk are stored there
        fuseWithinSamples
    end
    
    methods
        function pObj = transientMapProc(fs,p)
            %transientMapProc    Constructs an transient mapping processor
            %
            %USAGE
            %  pObj = transientMapProc(fs)
            %  pObj = transientMapProc(fs,p)
            %
            %INPUT PARAMETERS
            %    fs : Sampling frequency (Hz)
            %     p : Structure of non-default parameters
            %
            %OUTPUT PARAMETERS
            %  pObj : Processor Object
    
            if nargin > 0
    
            % Checking input parameters
            if isempty(fs)
                error('Sampling frequency needs to be provided')
            end
            if nargin<2||isempty(p)
                p = getDefaultParameters(fs,'processing');
            else
                p = parseParameters(p);
            end
    
            % Populate properties
            pObj.minStrengthdB = p.trm_minStrengthdB;
            pObj.minSpread = p.trm_minSpread;
            pObj.fuseWithinSec = p.trm_fuseWithinSec;
            pObj.minValuedB = p.trm_minValuedB;
    
            pObj.buffer = [];
            pObj.fuseWithinSamples = ceil(pObj.fuseWithinSec*fs);
            
            pObj.Type = 'Transient mapper';
            pObj.FsHzIn = fs;
            pObj.FsHzOut = fs;
            
            end
            
        end
    
        function out = processChunk(pObj,in)
            %processChunk       Apply the processor to a new chunk of input signal
            %
            %USAGE
            %   out = pObj.processChunk(in)
            %
            %INPUT ARGUMENT
            %    in : New chunk of input data
            %
            %OUTPUT ARGUMENT
            %   out : Corresponding output
    
            % Append the buffer
            in = [pObj.buffer; in];
            
            % Store the last fuseWithinSamples of the input in the buffer
            Lbuf = size(pObj.buffer,1);
            L = size(in,1);
            
            if L <= pObj.fuseWithinSamples
                % Then the buffered input goes back into the buffer and there is no
                % processing for this chunk
                pObj.buffer = in;
                out = [];
            else
                
                % Discard transients if the representation is below a threshold
                if ~isempty(pObj.minValuedB)
                    try
                        rmap = pObj.Dependencies{1}.Dependencies{1}.Output.Data(end-L+1:end);   
                        bSet2zero = 10*log10(rmap) < pObj.minValuedB;
                        in(bSet2zero) = 0;
                    
                    catch
                        warning('Could not access the ratemap representation from which transients were derived. Skipping transient discarding ...')
                    end
                        
                end
                
                % This "valid" input is then processed
                out = detectOnsetsOffsets(in,1/pObj.FsHzIn,pObj.minStrengthdB,...
                            pObj.minSpread,pObj.fuseWithinSec);
                
                % The output for the first Lbuf samples was already provided in the
                % previous chunk
                out = out(Lbuf+1:end,:);
                
                % Update the buffer
                pObj.buffer = in(end-pObj.fuseWithinSamples+1:end,:);
                
            end
            
            
        end
    
        function reset(pObj)
            pObj.buffer = [];
        end
            
        function hp = hasParameters(pObj,p)
            % Should probably always return 0, investigate
            hp = 0;
        end
        
    end
    
end