function b = sd_data_Equal(SD1, SD2)
b = false;
if isempty(SD1)
    SD1 = sd_data_Init();
end
if isempty(SD2)
    SD2 = sd_data_Init();
end
fields1 = propnames(SD1);
fieldsToExclude = { ...
'MeasListAct'; ...
'SrcMap'; ...
};
for ii = 1:length(fields1)
    if ~isempty(find(strcmp(fieldsToExclude, fields1{ii}))) %#ok<EFIND>
        continue;
    end    
    if ~isequal(SD1, SD2, fields1{ii})
        return;
    end
end
b = true;



% -----------------------------------------------------------
function b = isequal(SD1, SD2, field)
b = false;
if ~isfield(SD1,field) || ~isfield(SD2,field)
    return;
end
if eval( sprintf('~strcmp(class(SD1.%s), class(SD2.%s))', field, field) )
    return;
end
if eval( sprintf('length(SD1.%s) ~= length(SD2.%s)', field, field) )
    return;
end
EPS = 1.0e-10; %#ok<NASGU>
if eval( sprintf('iscell(SD1.%s)', field) )
    N = eval( sprintf('length(SD1.%s(:))', field) );
    for ii = 1:N
        if eval( sprintf('length(SD1.%s{ii}(:)) ~= length(SD2.%s{ii}(:))', field, field) )
            return;
        end
        if eval( sprintf('~all(SD1.%s{ii}(:) == SD2.%s{ii}(:))', field, field) )
            return;
        end
    end
elseif eval( sprintf('isstruct(SD1.%s)', field) )
    if eval( sprintf('~isempty(comp_struct(SD1.%s, SD2.%s))', field, field) )
        return;
    end
else    
    if eval( sprintf('~all( (SD1.%s(:) - SD2.%s(:)) < EPS )', field, field) )
        return;
    end    
end
b = true;


