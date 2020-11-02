function b = isvalidfile(str, options)

if ~exist('options','var')
    options = '';
end

b = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Error checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Err check 1.
if ~ischar(str)
    return;
end

% Err check 2.
if optionExists(options, 'checkextension')
    [~, ~, ext] = fileparts(str);
    if isempty(ext)
        return;
    end
end

% Err check 2.
if exist(str,'file') ~= 2
    return;
end

b = true;
