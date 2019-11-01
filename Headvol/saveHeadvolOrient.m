function headvol = saveHeadvolOrient(headvol, obj)

headvol.orientation = obj.orientation;
if isempty(headvol.orientationOrig)
    headvol.orientationOrig = obj.orientation;
end

