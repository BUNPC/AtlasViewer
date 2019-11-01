function values = fieldvalues(s)

values = {};
fields = fieldnames(s);
for ii=1:length(fields)
    eval(sprintf('values{ii} = s.%s', fields{ii}));
end

