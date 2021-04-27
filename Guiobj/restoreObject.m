function obj = restoreObject(obj, obj0)

% Make sure the following fields are overwritten by the lastest initalized version
if exist('obj0','var')
    obj.handles = obj0.handles;
end
if isfield(obj0, 'name')
    obj.name = obj0.name;
end

% Copy only fields that exist in the newer object that do NOT exist in the saved object.
% Keep the rest of the fields as is
obj = updateVar(obj, obj0);

% Current initialized object
fnames0 = fieldnames(obj0);

% Saved object we're want to restore
fnames = fieldnames(obj);

% Remove fields from saved object which do not exists in current 
% initialized version of this object
for ii = 1:length(fnames)
    if ~ismember(fnames{ii},fnames0)
        eval( sprintf('obj = rmfield(obj,''%s'');', fnames{ii}) );
    end
end

% Update set of fields in obj compatible with current version
fnames = fieldnames(obj);

% Check the validity of any function handle fields
for ii = 1:length(fnames)
    eval(sprintf('b = strcmp(class(obj.%s), ''function_handle'');', fnames{ii}));
    if b==true
        eval(sprintf('fh = functions(obj.%s);', fnames{ii})); 
        if isempty(fh.file)
            eval( sprintf('obj.%s = [];', fnames{ii}) );
        end
    end    
end

% Make sure field order is same as for obj0
obj = orderfields(obj, fieldnames(obj0));




