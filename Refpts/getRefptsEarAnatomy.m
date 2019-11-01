function ear_refpts_anatomy  = getRefptsEarAnatomy(pts, labels)

ear_refpts_anatomy = 'tragus';

k_LPA = find(strcmpi(labels,'LPA'));
k_RPA = find(strcmpi(labels,'RPA'));
k_T9  = find(strcmpi(labels,'t9'));
k_T10 = find(strcmpi(labels,'t10'));
k_C5  = find(strcmpi(labels,'c5'));
k_C6  = find(strcmpi(labels,'c6'));

if ~isempty(k_C5) & ~isempty(k_C6)
    if isempty(k_T9) & isempty(k_T10) & ~isempty(k_LPA) & ~isempty(k_RPA)
        ear_refpts_anatomy = 'preauricular';
    elseif ~isempty(k_T9) & ~isempty(k_T10) & ~isempty(k_LPA) & ~isempty(k_RPA)
        if all(pts(k_T9,:)==pts(k_LPA,:))
            ear_refpts_anatomy = 'preauricular';
        end
    end
end