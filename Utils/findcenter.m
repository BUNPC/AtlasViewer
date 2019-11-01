function c = findcenter(x)

if ~isstruct(x)
    volsurf = x;
    bbox = gen_bbox(volsurf);
    c = find_region_centers({bbox});
elseif isfield(x, 'labels')
    c = findCenterRefpts(refpts);
end

