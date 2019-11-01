function saveFluenceProf(filenm, fluenceProf)

if isempty(fluenceProf)
    return;
end

% Backward compatibility
if isfield(fluenceProf, 'fluenceProf')
    foo = fluenceProf;
    fluenceProf = fluenceProf.fluenceProf;
end

fields = fieldnames(fluenceProf);
strLst=[];
n=length(fields);
for ii=1:n
    if ii<n
        strLst = [strLst '''' fields{ii} ''','];
    elseif ii==n
        strLst = [strLst '''' fields{ii} ''''];        
    end
    eval(sprintf('%s = fluenceProf.%s;',fields{ii},fields{ii}));
end

cmd = sprintf('save(''%s'', %s, ''-mat'');', filenm, strLst);
fprintf('Save command: %s\n', cmd);
eval(cmd);

