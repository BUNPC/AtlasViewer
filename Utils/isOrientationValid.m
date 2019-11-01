function b = isOrientationValid(o)

b = false;
if isempty(o)
    return;
end
if ~ischar(o)
    return;
end

for i=1:length(o)
    switch(upper(o(i)))
        case 'R'
        case 'L'
        case 'A'
        case 'P'
        case 'S'
        case 'I'
        otherwise
            return;
    end
end

if ismember('L', upper(o)) && ismember('R', upper(o))
    return;
end
if ismember('A', upper(o)) && ismember('P', upper(o))
    return;
end
if ismember('S', upper(o)) && ismember('I', upper(o))
    return;
end

b = true;



