function v2 = updateVar(v2, v1)

if ~exist('v1','var')
    return
end
if ~isobject(v1) && ~isstruct(v1)
    return;
end

fields1 = propnames(v1);   
for ii = 1:length(fields1)
    % We only need to concern ourselves with fields that exists in v1
    % but are missing in v2. (You can only add fields to structs but
    % not class objects
    if isstruct(v2)
        if eval( sprintf('~isfield(v2, ''%s'')', fields1{ii}) )
            for jj = 1:length(v2(:))
                if jj > length(v1(:))
                    continue
                end
                if eval( sprintf('isa(v1(jj).%s, ''matlab.mixin.Copyable'')', fields1{ii}) )
                    eval( sprintf('v2(jj).%s = v1(jj).%s.copy;', fields1{ii}, fields1{ii}) );
                elseif eval( sprintf('isa(v1(jj).%s, ''handle'')', fields1{ii}) )
                    constructor = eval( sprintf('class(v1.%s);', fields1{ii}) );
                    eval( sprintf('v2(jj).%s = %s();', fields1{ii}, constructor) );                    
                    eval( sprintf('v2(jj).%s = copyClassObj(v2(jj).%s, v1(jj).%s);', fields1{ii}, fields1{ii},  fields1{ii}) );
                else
                    eval( sprintf('v2(jj).%s = v1(jj).%s;', fields1{ii}, fields1{ii}) );
                end
            end
        else
            for jj = 1:length(v2(:))
                if jj > length(v1(:))
                    continue
                end
                eval( sprintf('v2(jj).%s = updateVar(v2(jj).%s, v1(jj).%s);', fields1{ii}, fields1{ii},  fields1{ii}) );
            end
        end
    end
end
    
