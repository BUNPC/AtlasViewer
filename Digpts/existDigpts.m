function b = existDigpts(digpts)

b=1;
if isempty(digpts)
    b=0;
end
if ~isfield(digpts,'refpts')
    b=0;
end
if ~isstruct(digpts)
    b=0;
end
