function v2 = copyClassObj(v2, v1)

if ~isobject(v1)
    v2 = v1;
elseif isobject(v1) && isa(v1, 'handle')
    if ~strcmp(class(v1), class(v2))
        return
    end
    fields1 = propnames(v1);
    for ii = 1:length(v2)
        eval( sprintf('v2.%s = copyClassObj(v2.%s, v1.%s);', fields1{ii}, fields1{ii}, fields1{ii}) );
    end
end

