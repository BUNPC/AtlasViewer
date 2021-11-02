function v2 = restoreObject(v2, v1)
if ~exist('v1','var')
    return
end
if ~exist('v2','var')
    return
end

% Do not overwrite graphics handles
if ishandles(v2) && ~isnumeric(v2)
    return
end

% Do not overwrite file path names
if ischar(v2) && ispathvalid(v2)
    return
end

% Do not copy function handles 
if isa(v1, 'function_handle')
    return;
end


fields1 = propnames(v1);
fields2 = propnames(v2);

% Copy array to array
if isempty(fields1) && isempty(fields2)
    if isnumeric(v1) && isnumeric(v2)
        v2 = v1;
    elseif ischar(v1) && ischar(v2)
        v2 = v1;
    elseif iscell(v1) && iscell(v2)
        for ii = 1:length(v1)
            if ii <= length(v2)
                v2{ii} = restoreObject(v2{ii}, v1{ii});
            end
        end
    end
end


% Copy array to array
if isempty(v2)
    v2 = v1;
    return
end

% Copy structs and objects
for ii = 1:length(fields1)
   
    % We only need to concern ourselves with fields that exists in v1 AND v2 
    for jj = 1:length(v2(:))
        if eval( sprintf('isfield(v2(jj), ''%s'')', fields1{ii}) )
            if jj > length(v1(:))
                continue
            end
            if isfield(v2(jj), 'checkCompatability') && ~isempty(v2(jj).checkCompatability)
                eval( sprintf('v2(jj) = v2(jj).checkCompatability(v2(jj), v1(jj), ''%s'');', fields1{ii}) );                        
            end
            eval( sprintf('v2(jj).%s = restoreObject(v2(jj).%s, v1(jj).%s);', fields1{ii}, fields1{ii}, fields1{ii}) );
        elseif isfield(v2(jj), 'checkCompatability') && ~isempty(v2(jj).checkCompatability)
            eval( sprintf('v2(jj) = v2(jj).checkCompatability(v2(jj), v1(jj), ''%s'');', fields1{ii}) );            
        end
    end
end



