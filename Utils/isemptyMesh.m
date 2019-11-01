function b = isemptyMesh(fv)

b = false;
if isempty(fv)
    b = true;
end

if ~isfield(fv, 'vertices')
    b = true;
end

if isempty(fv.vertices)
    b = true;
end

if ~isfield(fv, 'faces')
    b = true;
end

if isempty(fv.faces)
    b = true;
end

