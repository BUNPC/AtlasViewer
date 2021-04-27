function SD = extractSDFromDataTree(obj)
SD = [];

if isa(obj, 'char') || isa(obj, 'SnirfClass')
    if isa(obj, 'char')
        filename  = obj;
        snirf = SnirfClass(filename);
    elseif isa(obj, 'SnirfClass')
        snirf = obj;
    end
    SD = snirf.GetSDG();
    SD.MeasList = snirf.GetMeasList();
elseif isa(obj, 'TreeNodeClass')
    SD = obj.GetSDG('2D');
    foo = obj.GetMeasList();
    SD.MeasList = foo.MeasList;    
end
