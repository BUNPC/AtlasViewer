function c = findCenterRefpts(refpts)

c = [];
p = [];

r = refpts;

ar_flag = 0;
al_flag = 0;
a1_flag = 0;
a2_flag = 0;
rpa_flag = 0;
lpa_flag = 0;

for ii=1:length(r.labels)
    switch(lower(r.labels{ii}))
        case 'ar'
            ar_flag = ii;
        case 'al'
            al_flag = ii;
        case 'a2'
            a2_flag = ii;
        case 'a1'
            a1_flag = ii;
        case 'rpa'
            rpa_flag = ii;
        case 'lpa'
            lpa_flag = ii;            
    end
end

if rpa_flag & lpa_flag
    p(1,:) = refpts.pos(rpa_flag,:);
    p(2,:) = refpts.pos(lpa_flag,:);
elseif a2_flag & a1_flag
    p(1,:) = refpts.pos(a2_flag,:);
    p(2,:) = refpts.pos(a1_flag,:);
elseif ar_flag & al_flag
    p(1,:) = refpts.pos(ar_flag,:);
    p(2,:) = refpts.pos(al_flag,:);
end

if length(p)>1
    c = (p(1,:)+p(2,:))/2;
end

