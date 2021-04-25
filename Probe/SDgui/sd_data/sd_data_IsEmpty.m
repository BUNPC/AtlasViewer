function b = sd_data_IsEmpty(SDo)
global SD

if nargin==0
    SDo = SD;
end

b = false;
if ~isempty(SDo.SrcPos)
    return;
end
if ~isempty(SDo.DetPos)
    return;
end
if ~isempty(SDo.SrcPos3D)
    return;
end
if ~isempty(SDo.DetPos3D)
    return;
end
b = true;

