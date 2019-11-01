function obj = restoreObject(obj,obj0)

if exist('obj0','var')
    obj.handles = obj0.handles;
end

% Current initialized object
fnames0 = fieldnames(obj0);

% Saved object we're want to restore
fnames = fieldnames(obj);

% Add fields to saved object we want to restore from current 
% initialized object
for ii=1:length(fnames0)
    if ~ismember(fnames0{ii},fnames);
        eval( sprintf('obj.%s = obj0.%s;',fnames0{ii},fnames0{ii}) );
    end   
end

% Remove fields from saved object which do not exists in current 
% initialized version of this object
for ii=1:length(fnames)
    if ~ismember(fnames{ii},fnames0);
        eval( sprintf('obj = rmfield(obj,''%s'');',fnames{ii}) );
    end
end

% Update set of fields in obj compatible with current version
fnames = fieldnames(obj);

% Check the validity of any function handle fields
for ii=1:length(fnames)
    eval(sprintf('b = strcmp(class(obj.%s), ''function_handle'');', fnames{ii}));
    if b==true
        eval(sprintf('fh = functions(obj.%s);', fnames{ii})); 
        if isempty(fh.file)
            eval( sprintf('obj.%s = [];',fnames{ii}) );
        end
    end    
end

% Make sure field order is same as for obj0
obj = orderfields(obj, fieldnames(obj0));

if ~isfield(obj,'guiobjprop')
    return;
end

guiobjprop = fieldnames(obj.guiobjprop);
for ii=1:length(guiobjprop)
    eval(sprintf('len = length(obj.guiobjprop.%s(:));', guiobjprop{ii}));
    for jj=1:len
        eval(sprintf('propnames = fieldnames(obj.guiobjprop.%s(jj));', guiobjprop{ii}));
        eval(sprintf('propvalues = fieldvalues(obj.guiobjprop.%s(jj));', guiobjprop{ii}));
        eval(sprintf('b = isempty(obj.handles.%s);',guiobjprop{ii}));
        try 
            eval(sprintf('if b==0 && ishandles(obj.handles.%s(jj)), set(obj.handles.%s(jj), propnames, propvalues); end', ...
                         guiobjprop{ii}, guiobjprop{ii}));
        catch
            disp(sprintf('ERROR restoring property %s',guiobjprop{ii}));
        end
    end
end
