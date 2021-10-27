function refpts = makeLandmarksBackwardCompatible(refpts)

if isstruct(refpts)
    labels = refpts.labels;
else
    labels = refpts;
end

ar_flag = 0;
al_flag = 0;
a1_flag = 0;
a2_flag = 0;
rpa_flag = 0;
lpa_flag = 0;

for ii=1:length(labels)
    switch(lower(labels{ii}))
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
    labels{a2_flag} = 'rpa';
    labels{a1_flag} = 'lpa';
elseif (rpa_flag==0 & lpa_flag==0) & (ar_flag & al_flag)
    labels{ar_flag} = 'rpa';
    labels{al_flag} = 'lpa';
end

if isstruct(refpts)
    refpts.labels = labels;
else
    refpts = labels;
end

