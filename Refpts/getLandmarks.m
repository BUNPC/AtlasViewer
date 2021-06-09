function [nz, iz, rpa, lpa, cz, refpts_out] = getLandmarks(refpts)

refpts_out = initRefpts;
nz  = [];
iz  = [];
rpa = [];
lpa = [];
cz  = [];

if isempty(refpts)
    return;
end


kk=1;
for ii=1:length(refpts.labels)
    switch(lower(refpts.labels{ii}))
        case 'nz'
            nz  = refpts.pos(ii,:);
            refpts_out.pos(kk,:)  = refpts.pos(ii,:);
            refpts_out.labels{kk}  = 'nz';
            kk=kk+1;
        case 'iz'
            iz  = refpts.pos(ii,:);
            refpts_out.pos(kk,:)  = refpts.pos(ii,:);
            refpts_out.labels{kk}  = 'iz';
            kk=kk+1;
        case {'rpa','a2','ar'}
            rpa = refpts.pos(ii,:);
            refpts_out.pos(kk,:)  = refpts.pos(ii,:);
            refpts_out.labels{kk}  = 'rpa';
            kk=kk+1;
        case {'lpa','a1','al'}
            lpa = refpts.pos(ii,:);
            refpts_out.pos(kk,:)  = refpts.pos(ii,:);
            refpts_out.labels{kk}  = 'lpa';
            kk=kk+1;
        case 'cz'
            cz  = refpts.pos(ii,:);
            refpts_out.pos(kk,:)  = refpts.pos(ii,:);
            refpts_out.labels{kk}  = 'cz';
            kk=kk+1;
    end
end

