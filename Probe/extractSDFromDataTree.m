function SD = extractSDFromDataTree(obj)
SD = [];

if isempty(obj)
    return;
end

if isa(obj, 'char') || isa(obj, 'SnirfClass')
    if isa(obj, 'char')
        filename  = obj;
        snirf = SnirfClass(filename);
    elseif isa(obj, 'SnirfClass')
        snirf = obj;
    end
    SD = snirf.GetSDG();
    SD.MeasList = snirf.GetMeasList();
elseif isa(obj, 'DataTreeClass')
    if isempty(obj.IsEmpty())
        return;
    end
    p = obj.currElem.GetProbe();
    n = NirsClass();
    s = SnirfClass();
    s.probe = p.copy();
    n.ConvertSnirfProbe(s);
    SD = n.SD;
    SD.MeasList = obj.currElem.GetMeasurementList('matrix');
end
