function requestList
%requestList  Returns a list of currently implemented valid requests for 
%             WP2 processing.
%
%USAGE: 
%   requestList()

list = getDependencies('available');
fprintf('The following requests for WP2 processing are currently valid:\n')

for ii = 1:size(list,2)
   fprintf('\t''%s''\n',list{ii})   
end