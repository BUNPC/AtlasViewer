function sd_file_save2nirs(filename,nirsdata_new)

if exist(filename,'file')
    nirsdata = load(filename,'-mat');
else
    nirsdata = struct();
end     
if isfield(nirsdata_new,'SD')
    nirsdata.SD = nirsdata_new.SD;
end
if isfield(nirsdata_new,'d')
    nirsdata.d = nirsdata_new.d;
end
if isfield(nirsdata_new,'s')
    nirsdata.s = nirsdata_new.s;
end
if isfield(nirsdata_new,'t')
    nirsdata.t = nirsdata_new.t;
end
if isfield(nirsdata_new,'aux')
    nirsdata.aux = nirsdata_new.aux;
end
if isfield(nirsdata_new,'ml')
    nirsdata.ml = nirsdata_new.ml;
end
fields = fieldnames(nirsdata);
strLst=[];
n=length(fields);
for ii=1:n
    if ii<n
        strLst = [strLst '''' fields{ii} ''','];
    elseif ii==n
        strLst = [strLst '''' fields{ii} ''''];        
    end
    eval(sprintf('%s = nirsdata.%s;',fields{ii},fields{ii}));
end
eval( sprintf('save( filename, %s, ''-mat'')', strLst) );
