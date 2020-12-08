function sd_file_save2nirs(filename) %#ok<INUSD>
global SD
global filedata

filedata.SD = SD;

fields = fieldnames(filedata);
strLst=[];
n=length(fields);
for ii=1:n
    if ii<n
        strLst = [strLst '''' fields{ii} ''','];
    elseif ii==n
        strLst = [strLst '''' fields{ii} ''''];        
    end
    eval(sprintf('%s = filedata.%s;',fields{ii},fields{ii}));
end
eval( sprintf('save( filename, %s, ''-mat'')', strLst) );
