function b = isHeadsizeEmpty(digpts)
b = true;
if isempty(digpts.headsize.HC)
    return
end
if isempty(digpts.headsize.NzCzIz)
    return
end
if isempty(digpts.headsize.LPACzRPA)
    return
end
b = false;
