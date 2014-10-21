function requestList
%requestList  Returns a list of currently implemented valid requests for 
%             Two!Ears Auditory Front-End processing.
%
%USAGE:
%   requestList()

list = getDependencies('available');
fprintf('The following requests for Two!Ears Auditory Front-End processing are currently valid:\n')

for ii = 1:size(list,2)
   fprintf('\t''%s''\n',list{ii})
end
