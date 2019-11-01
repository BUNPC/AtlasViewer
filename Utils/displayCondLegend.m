function hLegend=displayCondLegend(hLegend,hIncl,idxIncl,hExcl,idxExcl,CondNames)

n = length(CondNames);

[idxIncl k]=sort(idxIncl);
hIncl=hIncl(k);
[idxExcl k]=sort(idxExcl+n);
hExcl=hExcl(k);
hCond=[hIncl hExcl];
if(isempty(hCond))
    return;
end
idx=[idxIncl idxExcl];
if(ishandle(hLegend))
    delete(hLegend);
end

for jj=0:1
    for ii=1:n
        if jj==0
            names{ii}=[CondNames{ii} ' (incl)'];
        elseif jj==1
            names{ii+n}=[CondNames{ii} ' (excl)'];
        end
    end
end
hLegend = legend(hCond(:),names(idx(:)));
