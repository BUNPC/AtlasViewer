function digpts = genDigptsFromHeadsize(digpts, dirname, refpts)

digpts.headsize = getHeadsize(digpts.headsize, dirname);
if isHeadsizeEmpty(digpts)
    return
end
if exist([dirname, 'digpts.txt'],'file')
    dateDigptsFile = getFileDateStruct([dirname, './digpts.txt']);        
    dateHeadsizeFile = getFileDateStruct([dirname, './headsize.txt']);
    if ~isempty(dateDigptsFile) && ~isempty(dateHeadsizeFile)
        if dateDigptsFile.num > dateHeadsizeFile.num
            return
        end
    end
end

% Calculate digitized points
digpts = calcDigptsFromHeadsize(digpts, refpts);

% If digitized points exist but are missing probe optodes, generate 
% artificial digitize optodes 
if ~digpts.isempty(digpts) && digpts.isemptyProbe(digpts)
    saveDigpts(digpts, 'overwrite');
end
