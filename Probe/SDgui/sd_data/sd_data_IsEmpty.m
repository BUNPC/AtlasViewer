function b = sd_data_IsEmpty(SDo)
global SD

if nargin==0
    SDo = SD;
end

b = true;
if isempty(SDo)
    return;
end
if isempty(SDo.SrcPos)
    return;
end
if isempty(SDo.DetPos)
    return;
end
if isempty(SDo.SrcPos3D)
    return;
end
if isempty(SDo.DetPos3D)
    return;
end
b = false;

