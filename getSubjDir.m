function dirname = getSubjDir(arg)

if ~exist('arg','var') || isempty(arg)
    arg = {''};
end

if length(arg) > 1
    dirname = arg{1};
else    
    % After checking all the above for insications of subject folder
    % see if dirname is etill empty. If it is ask user for subject dir. 
    if isSubjDir(pwd)
        dirname = pwd;
    else
        pause(.1);
        dirname = uigetdir(pwd, 'Please select subject folder');
        if dirname==0
            dirname = pwd;
            return;
        end
    end
end

if isempty(dirname) | dirname==0
    return;
end
dirname = filesepStandard(dirname);

cd(dirname);



