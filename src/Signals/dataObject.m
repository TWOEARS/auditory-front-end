classdef dataObject < dynamicprops

    properties
        isStereo   % Flag indicating if the data structure will be based
                    %   on a stereo (binaural) signal
    end
    
    methods
        function dObj = dataObject(s,fs,is_stereo)
            %dataObject     Constructs a data object
            %
            %USAGE
            %       dObj = dataObject(s,fs)
            %       dObj = dataObject(s,fs,is_stereo)
            %
            %INPUT ARGUMENTS
            %          s : Initial time-domain signal
            %         fs : Sampling frequency
            %  is_stereo : Flag indicating if the ear signal is binaural
            %              (true) or  monaural (false) (default:
            %              is_stereo=false). Used in chunk-based scenario
            %              when the dataObject is initialized with an empty
            %              signal
            %
            %OUTPUT ARGUMENTS
            %       dObj : Data object
            
            if nargin==1
                error('The sampling frequency needs to be provided') 
            end
            if nargin==0
                s = [];
                fs = [];
            end
            
            % Check number of channels of the provided signal
            if size(s,2)==2 
                % Set to stereo when provided signal is
                is_stereo = true;
            elseif nargin<3||isempty(is_stereo)
                % Set to default if stereo flag not provided
                is_stereo = false;
            end
            
            % Set the is_stereo property
            dObj.isStereo = is_stereo;
            
            % Populate the signal property
            
            % TO DO: Do something with the label of this signal?
            if is_stereo
                if ~isempty(s)
                    sig_l = TimeDomainSignal(fs,'signal','Ear Signal',s(:,1),'left');
                    sig_r = TimeDomainSignal(fs,'signal','Ear Signal',s(:,2),'right');
                else
                    sig_l = TimeDomainSignal(fs,'signal','Ear Signal',[],'left');
                    sig_r = TimeDomainSignal(fs,'signal','Ear Signal',[],'right');
                end
                dObj.addSignal(sig_l);
                dObj.addSignal(sig_r);
            else
                if ~isempty(s)
                    sig = TimeDomainSignal(fs,'signal','Ear signal (mono)',s);
                else
                    sig = TimeDomainSignal(fs,'signal','Ear signal (mono)',[]);
                end
                dObj.addSignal(sig);
            end          
        end
        
        function addSignal(dObj,sObj)
            %addSignal      Appends an additional signal object to a data 
            %                 object as a new property
            %
            %USAGE
            %     dObj.addSignal(sObj)
            %     addSignal(dObj,sObj)
            %
            %INPUT ARGUMENTS
            %      dObj : Data object to append the signal to
            %      sObj : Signal object to add
            %
            %This method uses dynamic property names. The data object dObj
            %will then contain the signal sObj as a new property, named 
            %after sObj.Name
            
            % N.B.: Left/right channel handling works here only because
            % left channel is always instantiated first. Might want to
            % check if that is a limitation.
            
            % Which channel (left, right, mono) is this signal
            if strcmp(sObj.Canal,'right')
                jj = 2;
            else
                jj = 1;
            end
            
            % Check if a signal with this name already exist
            if isprop(dObj,sObj.Name)
                ii = size(dObj.(sObj.Name),1)+2-jj;
                dObj.(sObj.Name){ii,jj} = sObj;
            else
                dObj.addprop(sObj.Name);
                dObj.(sObj.Name) = {sObj};
            end
            
        end
        
        function clearData(dObj)
            %clearData  Clear data of all signals in the data structure
            %
            %USAGE:
            %    dObj.clearData
            
            % Get a list of the signals contained in the data object
            sig_list = fieldnames(dObj);
            
            % Remove the "isStereo" property from the list
            sig_list = sig_list(2:end);
            
            % Loop over all the signals
            for ii = 1:size(sig_list,1)
                
                % There should always be a left or mono channel
                dObj.(sig_list{ii}){1}.clearData;
                
                % Check if there is a right channels
                if size(dObj.(sig_list{ii}),2)>1
                    
                    % It could still be empty (e.g. for "mix" signals)
                    if isa(dObj.(sig_list{ii}){2},'Signal')
                        dObj.(sig_list{ii}){2}.clearData;
                    end
                    
                end
                
            end
           
            
        end
        
        function play(dObj)
            %play       Playback the audio from the ear signal in the data
            %           object
            %
            %USAGE
            %   dObj.play()
            %
            %INPUT ARGUMENTS
            %   dObj : Data object
            
            if ~isprop(dObj,'signal')||isempty(dObj.signal)||...
                    isempty(dObj.signal{1}.Data)
                warning('There is no audio in the data object to playback')
            else
                if size(dObj.signal,2)==1
                    % Then mono playback
                    sound(dObj.signal{1}.Data,dObj.signal{1}.FsHz)
                else
                    % Stereo playback
                    temp_snd = [dObj.signal{1}.Data dObj.signal{2}.Data];
                    sound(temp_snd,dObj.signal{1}.FsHz)
                end
            end
        end
        
    end
    
    
    
end
