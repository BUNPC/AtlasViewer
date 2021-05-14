function pname = cropSeparator(pname)
if nargin==0
    pname = '';
    return;
end
if isempty(pname)
    return;
end
if ~ischar(pname)
    return;
end
while pname(end) == '/' || pname(end) == '\'
    pname(end) = '';
    if isempty(pname)
        return;
    end
end

