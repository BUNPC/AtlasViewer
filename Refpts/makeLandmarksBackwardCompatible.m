function [refpts, labels] = makeLandmarksBackwardCompatible(refpts, labels)

if isstruct(refpts)
    r = refpts;
else
    r.pos = refpts;
    r.labels = labels;
end

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

if (rpa_flag==0 & lpa_flag==0) & (a2_flag & a1_flag)
    r.labels{a2_flag} = 'rpa';
    r.labels{a1_flag} = 'lpa';
elseif (rpa_flag==0 & lpa_flag==0) & (ar_flag & al_flag)
    r.labels{ar_flag} = 'rpa';
    r.labels{al_flag} = 'lpa';
end

%{
if (rpa_flag==0 & lpa_flag==0) & (a2_flag & a1_flag)
    q = menu('Landmarks RPA and LPA missing. Do you want to use A2 and A1 as RPA and LPA landmarks?','Yes','No');
    if q==1
        r.labels{a2_flag} = 'rpa';
        r.labels{a1_flag} = 'lpa';
    end
    
elseif (rpa_flag==0 & lpa_flag==0) & (ar_flag & al_flag)
    q = menu('Landmarks RPA and LPA missing. Do you want to use Ar and Al as RPA and LPA landmarks?','Yes','No');
    if q==1
        r.labels{ar_flag} = 'rpa';
        r.labels{al_flag} = 'lpa';
    end
end
%}


if isstruct(refpts)
    refpts = r;
    labels = {};
else
    refpts = r.pos;
    labels = r.labels;
end

