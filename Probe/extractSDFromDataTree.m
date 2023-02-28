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
    SD = obj.currElem.GetSDG('2D');
    foo = obj.currElem.GetMeasList();
    SD.MeasList = foo.MeasList; 
%     SD = obj.currElem.GetProbe();
end
