function headsize = getHeadsize(headsize, dirname)

if ~exist('dirname','var') || isempty(dirname)
    dirname = pwd;
end
dirname = filesepStandard(dirname);

filename = [dirname, 'headsize.txt'];
if ~exist(filename, 'file')
    return;
end

try
    % If headsize.txt file format is just 3 numbers then do this 
    curveLen = load(filename, '-ascii');
    scalefactor = getScaleFactor(curveLen);
    if length(curveLen)==3
        headsize.HC = curveLen(1)*scalefactor;
        headsize.NzCzIz = curveLen(2)*scalefactor;
        headsize.LPACzRPA = curveLen(3)*scalefactor;
    end
    if ~isempty(headsize.HC)
        return
    end
   
    
    % If headsize.txt file format is more complicated and needs parsing do
    % this
    fid = fopen(filename, 'r');
    linecount = 0;
    while 1
        line = fgetl(fid);
        if line == -1
            break;
        end
        if isempty(line)
            continue;
        end
        linecount = linecount+1;
        headsize = parse(headsize, line, linecount);
    end
    fclose(fid);
catch ME
    try 
        fclose(fid);
        rethrow(ME);
    catch ME
        rethrow(ME);
    end
end



% -----------------------------------------------------
function headsize = parse(headsize, line, linecount)
parts = str2cell(line, {':',' '});
for ii = length(parts):-1:1
    if isempty(parts{ii})
        parts(ii) = [];
    end
end
if isempty(parts)
    return
end

labelidx = 1;
numidx = 2;
if isnumber(parts{1})
    labelidx = 0;
    numidx = 1;
end

scalefactor = getScaleFactor(parts{numidx});

if labelidx==0
    switch(linecount)
        case 1
            headsize.HC = str2num(parts{numidx})*scalefactor;
        case 2
            headsize.NzCzIz = str2num(parts{numidx})*scalefactor;
        case 3            
            headsize.LPACzRPA = str2num(parts{numidx})*scalefactor;
    end
else
    switch(lower(parts{labelidx}))
        case {'lpa-cz-rpa','lpaczrpa','lparpa','rpa-cz-lpa','rpaczlpa','rpalpa'}
            headsize.LPACzRPA = str2num(parts{numidx})*scalefactor;
        case {'circumference','headcircumference','hc'}
            headsize.HC = str2num(parts{numidx})*scalefactor;
        case {'nz-cz-iz','nzcziz','nziz','iz-cz-nz','izcznz','iznz'}
            headsize.NzCzIz = str2num(parts{numidx})*scalefactor;
    end
end



% -------------------------------------------------------------------
function scalefactor = getScaleFactor(curveLen)
scalefactor = 10;
if ischar(curveLen)
    curveLen = str2num(curveLen);
end
if mean(curveLen) >= 100
    scalefactor = 1;
elseif mean(curveLen) < 100 
    scalefactor = 10;
end

