function dirname = getSubjDir(arg)
dirname = pwd;
if length(arg) > 0
    dirname = arg{1};
else    
    % After checking all the above for insications of subject folder
    % see if dirname is etill empty. If it is ask user for subject dir. 
    if ~isSubjDir(dirname)
        pause(.1);
        dirname = uigetdir(dirname, 'Please select subject folder');
        if dirname==0
            dirname = pwd;
        end
    end
end
dirname = filesepStandard(dirname);

cd(dirname);



