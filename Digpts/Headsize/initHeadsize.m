function headsize = initHeadsize(~)

headsize = struct(...
    'HC', [], ...
    'LPACzRPA', [], ...
    'NzCzIz', [], ...
    'default', struct(...
        'HC', 500, ...
        'LPACzRPA', 310, ...
        'NzCzIz', 370 ...
        ), ...
    'isempty',@isempty_loc ...
    );


% -----------------------------------------------
function b = isempty_loc(headsize)

b = true;
if isempty(headsize)
    return;
end
if isempty(headsize.HC)
    return;
end
if isempty(headsize.LPACzRPA)
    return;
end
if isempty(headsize.NzCzIz)
    return;
end
b = false;


