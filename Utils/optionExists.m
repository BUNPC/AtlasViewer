function b = optionExists(options, value)
if isempty(options)
    b = false;
    return;
end
if ~exist('value','var') || isempty(value)
    b = false;
    return;
end
b = ~isempty(findstr(options, value)); %#ok<*FSTR>