classdef adaptationProc < Processor
    
     properties
         overshootLimit      % limit to the overshoot of the output
         minValue            % the lowest audible threshhold of the signal 
         tau                 % time constants involved in the adaptation loops. 
                             % The number of adaptation loops is determined by the length of tau.
     end
     
     properties (GetAccess = private)
         state              % structure to store previous output

     end
     
     methods
         function pObj = adaptationProc(fs, lim, min)
             %adaptationProc   Construct an adaptation loop processor
             %
             %USAGE
             %   pObj = adaptationProc(fs, limit, minValue)
             %
             %INPUT ARGUMENTS
             %     fs : Sampling frequency (Hz)
             %    lim : limit to the overshoot of the output
             %    min : the lowest audible threshhold of the signal
             %
             
            % check input arguments and set default values
            if nargin>0  % Failsafe for constructor calls without arguments
            
                % Checking input arguments
                if nargin > 3
                    help(mfilename);
                    error('Wrong number of input arguments!')
                end

                if nargin < 3 || isempty(min); min = 1e-5; end
                if nargin < 2 || isempty(lim); lim = 0; end
                if nargin < 1 || isempty(fs); fs = 44100; end

                % Populate the object's properties
                % 1- Global properties
                populateProperties(pObj,'Type','Adaptation loop processor',...
                     'Dependencies',getDependencies('adaptation'),...
                     'FsHzIn',fs,'FsHzOut',fs);
                % 2- Specific properties
                pObj.overshootLimit = lim;
                pObj.minValue = min;
                pObj.tau = [0.005 0.050 0.129 0.253 0.500];
                % initialise the state structure
                % the sizes are unknown at this point - determined by the
                % length of cf (given from the input time-frequency signal)
                pObj.state = struct('tmp1', [], 'tmp21', [],  'tmp22', [], ...
                    'tmp23', [], 'tmp24', [], 'tmp25', []);
                
            end            
        end
         
        function out = processChunk(pObj,in)
            % This is an initial implementation copied from CASP2008
            % Needs further re-structuring
            % On-line chunk-based processing should be considered
            % in: time-frequency signal (time (row) x frequency (column))
            % Needs to loop through cf channels!!
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % testing against CASP2008: needs some additional steps between IHC and adaptation when
            % DRNL is used (not needed when gammatone filterbank is used)
            % linear gain to fit ADloop operating point
            in = in*10^(50/20);
            % expansion
            in = in.^2;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            len=size(in, 1);            % signal length = column length
            chanNo = size(in, 2);       % # of frequency channels
            out=max(in, pObj.minValue); % dimension same as in
            % SE 02/2012, included divisorStage
            divisorStage = out*0;       % dimension same as in
                        
            tmp1 = NaN(1, chanNo);      % memory allocation
            %% coefficients/temp. outputs for adaptation loops
            % aXXs and bXXs are fixed along frequency channels (by given tau values)
            % tmpXX values will keep being updated through the loops 
            %--------------------------------------------------------------
            % first adaption loop
            b01 = 1/(pObj.tau(1)*pObj.FsHzIn);		%b0 from RC-lowpass recursion relation y(n)=b0*x(n)+a1*y(n-1)
            a11 = exp(-b01);			%a1 coefficient of the upper IIR-filter
            b01 = 1-a11;
            tmp21 = sqrt(pObj.minValue)*ones(1, chanNo);		%from steady-state relation
            %---------------------------------------------------------------
            % second adaption loop
            b02=1/(pObj.tau(2)*pObj.FsHzIn);		%b0 from RC-lowpass recursion relation y(n)=b0*x(n)+a1*y(n-1)
            a12=exp(-b02);			%a1 coefficient of the upper IIR-filter
            b02=1-a12;
            tmp22=pObj.minValue^(1/4)*ones(1, chanNo);		%from steady-state relation
            %---------------------------------------------------------------
            % third adaption loop
            b03=1/(pObj.tau(3)*pObj.FsHzIn);		%b0 from RC-lowpass recursion relation y(n)=b0*x(n)+a1*y(n-1)
            a13=exp(-b03);			%a1 coefficient of the upper IIR-filter
            b03=1-a13;
            tmp23=pObj.minValue^(1/8)*ones(1, chanNo);		%from steady-state relation
            %---------------------------------------------------------------
            % forth adaption loop
            b04=1/(pObj.tau(4)*pObj.FsHzIn);		%b0 from RC-lowpass recursion relation y(n)=b0*x(n)+a1*y(n-1)
            a14=exp(-b04);			%a1 coefficient of the upper IIR-filter
            b04=1-a14;
            tmp24=pObj.minValue^(1/16)*ones(1, chanNo);		%from steady-state relation
            %---------------------------------------------------------------
            % fifth adaption loop
            b05=1/(pObj.tau(5)*pObj.FsHzIn);		%b0 from RC-lowpass recursion relation y(n)=b0*x(n)+a1*y(n-1)
            a15=exp(-b05);			%a1 coefficient of the upper IIR-filter
            b05=1-a15;
            tmp25=pObj.minValue^(1/32)*ones(1, chanNo);		%from steady-state relation

            % corr and mult are fixed throughout the loops
            % (do not vary along frequency channels)
            corr = pObj.minValue^(1/32);		% to get a range from 0 to 100 model units
            mult = 100/(1-corr);
            %  mult = 100/(1.2*(1-corr)); % after expansion,DRNL, we need to compensate for
            % "m" is added or altered by morten 26. jun 2006
            if pObj.overshootLimit <= 1 % m, no limitation
                % retrieve final values from the previous chunk(if present)
                % ** how can we know there WAS a previous chunk?
                if(~isempty(pObj.state.tmp21))      % not a good way to check
                    tmp1 = pObj.state.tmp1;
                    tmp21 = pObj.state.tmp21;
                    tmp22 = pObj.state.tmp22;
                    tmp23 = pObj.state.tmp23;
                    tmp24 = pObj.state.tmp24;
                    tmp25 = pObj.state.tmp25;
                end
                
                for ch = 1:chanNo    % for each frequency channel (column)
                    for t = 1:len             % for each (time) sample
                        %   tmp1=out(i);
                        %if tmp1 < min
                        %   tmp1=min;
                        %end
                        %---------------------------------------------------------------
                        tmp1(ch)=out(t, ch)/tmp21(ch);
                        tmp21(ch) = a11*tmp21(ch) + b01*tmp1(ch);       % this is y(n) = a1*y(n-1)+b0*x(n)

                        %---------------------------------------------------------------
                        tmp1(ch)=tmp1(ch)/tmp22(ch);
                        tmp22(ch) = a12*tmp22(ch) + b02*tmp1(ch);

                        %---------------------------------------------------------------
                        tmp1(ch)=tmp1(ch)/tmp23(ch);
                        tmp23(ch) = a13*tmp23(ch) + b03*tmp1(ch);

                        %---------------------------------------------------------------
                        tmp1(ch)=tmp1(ch)/tmp24(ch);
                        tmp24(ch) = a14*tmp24(ch) + b04*tmp1(ch);

                        %---------------------------------------------------------------
                        tmp1(ch)=tmp1(ch)/tmp25(ch);
                        divisorStage(t, ch) = (tmp25(ch)-corr)*mult;
                        tmp25(ch) = a15*tmp25(ch) + b05*tmp1(ch);

                        %--- Scale to model units ----------------------------------

                        out(t, ch) = (tmp1(ch)-corr)*mult;

                        % --- LP --------

                        %   if (lp)
                        %	tmp1 = a1l*tmp_l + b0l*tmp1;
                        %	tmp_l = tmp1;
                        %
                        %   end

                        % out(i) = tmp1;
                    end                  
                end
                % store the final values for next chunk processing
                pObj.state.tmp1 = tmp1;
                pObj.state.tmp21 = tmp21;
                pObj.state.tmp22 = tmp22;
                pObj.state.tmp23 = tmp23;
                pObj.state.tmp24 = tmp24;
                pObj.state.tmp25 = tmp25;
                
                
            else    % m, now limit 
                % retrieve final values from the previous chunk(if present)
                if(~isempty(pObj.state.tmp21))      % not a good way to check
                    tmp1 = pObj.state.tmp1;
                    tmp21 = pObj.state.tmp21;
                    tmp22 = pObj.state.tmp22;
                    tmp23 = pObj.state.tmp23;
                    tmp24 = pObj.state.tmp24;
                    tmp25 = pObj.state.tmp25;
                end             
                
                min1 = tmp21; min2 = tmp22; min3 = tmp23;
                min4 = tmp24; min5 = tmp25;

                % calc values for exp fcn once
                maxvalue = (1 - min1.^2) * pObj.overshootLimit - 1;
                factor1 = maxvalue * 2;
                expfac1 = -2./maxvalue;
                offset1 = maxvalue - 1;

                maxvalue = (1 - min2.^2) * pObj.overshootLimit - 1;
                factor2 = maxvalue * 2;
                expfac2 = -2./maxvalue;
                offset2 = maxvalue - 1;

                maxvalue = (1 - min3.^2) * pObj.overshootLimit - 1;
                factor3 = maxvalue * 2;
                expfac3 = -2./maxvalue;
                offset3 = maxvalue - 1;

                maxvalue = (1 - min4.^2) * pObj.overshootLimit - 1;
                factor4 = maxvalue * 2;
                expfac4 = -2./maxvalue;
                offset4 = maxvalue - 1;

                maxvalue = (1 - min5.^2) * pObj.overshootLimit - 1;
                factor5 = maxvalue * 2;
                expfac5 = -2./maxvalue;
                offset5 = maxvalue - 1;
                
                for ch = 1:chanNo

                    for t = 1:len
                        %  tmp1=out(i);
                        %if tmp1 < min
                        %   tmp1=min;
                        %end
                        %---------------------------------------------------------------
                        tmp1(ch)=out(t, ch)/tmp21(ch);

                        if ( tmp1(ch) > 1 )                 % m,
                            tmp1(ch) = factor1(ch)/(1+exp(expfac1(ch)*(tmp1(ch)-1)))-offset1(ch);  % m,
                        end                             % m,
                        tmp21(ch) = a11*tmp21(ch) + b01*tmp1(ch);

                        %---------------------------------------------------------------
                        tmp1(ch)=tmp1(ch)/tmp22(ch);

                        if ( tmp1(ch) > 1 )                 % m,
                            tmp1(ch) = factor2(ch)/(1+exp(expfac2(ch)*(tmp1(ch)-1)))-offset2(ch);  % m,
                        end                             % m,
                        tmp22(ch) = a12*tmp22(ch) + b02*tmp1(ch);

                        %---------------------------------------------------------------
                        tmp1(ch)=tmp1(ch)/tmp23(ch);

                        if ( tmp1(ch) > 1 )                 % m,
                            tmp1(ch) = factor3(ch)/(1+exp(expfac3(ch)*(tmp1(ch)-1)))-offset3(ch);  % m,
                        end
                        tmp23(ch) = a13*tmp23(ch) + b03*tmp1(ch);

                        %---------------------------------------------------------------
                        tmp1(ch)=tmp1(ch)/tmp24(ch);

                        if ( tmp1(ch) > 1 )                 % m,
                            tmp1(ch) = factor4(ch)/(1+exp(expfac4(ch)*(tmp1(ch)-1)))-offset4(ch);  % m,
                        end
                        tmp24(ch) = a14*tmp24(ch) + b04*tmp1(ch);

                        %---------------------------------------------------------------
                        tmp1(ch)=tmp1(ch)/tmp25(ch);
                        divisorStage(t, ch) = (tmp25(ch)-corr)*mult;

                        if ( tmp1(ch) > 1 )                 % m,
                            tmp1(ch) = factor5(ch)/(1+exp(expfac5(ch)*(tmp1(ch)-1)))-offset5(ch);  % m,
                        end
                        tmp25(ch) = a15*tmp25(ch) + b05*tmp1(ch);

                        %--- Scale to model units ----------------------------------

                        out(t, ch) = (tmp1(ch)-corr)*mult;

                        % --- LP --------

                        %   if (lp)
                        %	tmp1 = a1l*tmp_l + b0l*tmp1;
                        %	tmp_l = tmp1;
                        %
                        %   end

                        %  out(i) = tmp1;

                    end
                end
                % store the final values for next chunk processing
                pObj.state.tmp1 = tmp1;
                pObj.state.tmp21 = tmp21;
                pObj.state.tmp22 = tmp22;
                pObj.state.tmp23 = tmp23;
                pObj.state.tmp24 = tmp24;
                pObj.state.tmp25 = tmp25;              
                
            end          
        end
         
        function reset(pObj)
             %reset     Resets the internal states 
             %
             %USAGE
             %      pObj.reset
             %
             %INPUT ARGUMENTS
             %  pObj : adaptation processor instance
             
            if(~isempty(pObj.state.tmp21))
                pObj.state.tmp1 = [];                
                pObj.state.tmp21 = [];
                pObj.state.tmp22 = [];
                pObj.state.tmp23 = [];
                pObj.state.tmp24 = [];
                pObj.state.tmp25 = [];
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
            
            %NB: Could be moved to private
            
            % The adaptation processor has the following parameters to be
            % checked: overshootLimit, minValue
            
            p_list = {'overshootLimit', 'minValue'};
            
            % Initialization of a parameters difference vector
            delta = zeros(size(p_list,2),1);
            
            % Loop on the list of parameters
            for ii = 1:size(p_list,2)
                try
                    delta(ii) = ~strcmp(pObj.(p_list{ii}),p.(p_list{ii}));
                    
                catch err
                    % Warning: something is missing
                    warning('Parameter %s is missing in input p.',p_list{ii})
                    delta(ii) = 1;
                end
            end
            
            % Check if delta is a vector of zeros
            if max(delta)>0
                hp = false;
            else
                hp = true;
            end
         end
         
     end
     
 end