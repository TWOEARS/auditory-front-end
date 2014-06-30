function  WP2parameterHelper(cat)
%WP2parameterHelper     Extensive and user friendly listing of parameters
%                       involved in WP2 processing.
%
%USAGE:
%    WP2parameterHelper



% Load the parameter info file
path = fileparts(mfilename('fullpath'));
load([path filesep 'parameterInfo.mat'])

% List the categories
cats = fieldnames(pInfo);

if nargin == 0
    % Display header
    fprintf(['\nParameters are organized in different categories:\n'])

    % Display the categories
    for ii = 1:size(cats,1)
        category = cats{ii};
        link = ['<a href="matlab:WP2parameterHelper(''' category ''')">'];
        fprintf(['\t' link pInfo.(cats{ii}).label '</a>\n'])
    end
    fprintf('\n')
else
    if isfield(pInfo,cat)
        % Display the category
        fprintf(['\n' pInfo.(cat).label ' parameters:\n\n'])
        
        % Get the parameter names for this category
        names = fieldnames(pInfo.(cat));
        
        % Remove the category label
        names = names(2:end);   
        
        % Find appropriate columns widths
        name_size = 4;  % Size of string 'Name'
        
        for ii = 1:size(names,1)
            name_size = max(name_size,size(names{ii},2));
        end
        
       
        % Display a list of parameters for this category
        
        % Text formatting for the parameter default value
        value = cell(size(names,1),1);
        val_size = 7;   % Size of string 'Default'
        for ii = 1:size(names,1)
            if iscell(pInfo.(cat).(names{ii}).value)
                % Then it's multiple strings concatenated in a cell array
                val = ['{'];
                for jj = 1:size(pInfo.(cat).(names{ii}).value,2)-1
                    val = [val '''' pInfo.(cat).(names{ii}).value{jj} ''','];
                end
                value{ii} = [val '''' pInfo.(cat).(names{ii}).value{jj+1} '''}'];
            elseif ischar(pInfo.(cat).(names{ii}).value)
                % Then it's a single string
                value{ii} = ['''' pInfo.(cat).(names{ii}).value ''''];
            elseif size(pInfo.(cat).(names{ii}).value,2)>1
                % Then it's an numerical array
                val = ['['];
                for jj = 1:size(pInfo.(cat).(names{ii}).value,2)-1
                    val = [val num2str(pInfo.(cat).(names{ii}).value(jj)) ' '];
                end
                value{ii} = [val num2str(pInfo.(cat).(names{ii}).value(jj+1)) ']'];
            else
                % It's a single numeral
                value{ii} = num2str(pInfo.(cat).(names{ii}).value);
            end
            
            % Keep track of larger string for table formatting
            val_size = max(val_size,size(value{ii},2));
            
        end
           
        % Display a header
        fprintf(['  %-' int2str(name_size+2) 's  %-' int2str(val_size+1) 's  %-s\n'],'Name','Default','Description')
        fprintf(['  %-' int2str(name_size+2) 's  %-' int2str(val_size+1) 's  %-s\n'],'----','-------','-----------')
        
        for ii = 1:size(names,1)
            % Display on command window
            fprintf(['  %-' int2str(name_size+2) 's  %-' int2str(val_size+1) 's  %-s\n'],names{ii},value{ii},pInfo.(cat).(names{ii}).description)
%             
%             if ~ischar(pInfo.(cat).(names{ii}).value)
%                 fprintf(['  %-' int2str(name_size+2) 's  %-' int2str(val_size+1) 's  %-s\n'],names{ii},num2str(pInfo.(cat).(names{ii}).value),pInfo.(cat).(names{ii}).description)
%             elseif iscell(pInfo.(cat).(names{ii}).value)
%                 fprintf(['  %-' int2str(name_size+2) 's  %-' int2str(val_size+1) 's  %-s\n'],names{ii},num2str(pInfo.(cat).(names{ii}).value),pInfo.(cat).(names{ii}).description)
%             else 
%                 fprintf(['  %-' int2str(name_size+2) 's  %-' int2str(val_size+1) 's  %-s\n'],names{ii},['''' pInfo.(cat).(names{ii}).value ''''],pInfo.(cat).(names{ii}).description)
%             end
%             fprintf(['%7s %s %s\n'],names{ii},num2str(pInfo.(cat).(names{ii}).value),pInfo.(cat).(names{ii}).description)
        end
        fprintf('\n')
    end
end
    