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

scalefactor = 10;
labelidx = 1;
numidx = 2;
unitsidx = 3;
if isnumber(parts{1})
    labelidx = 0;
    numidx = 1;
    unitsidx = 2;
end
if length(parts) >= unitsidx && strcmp(parts{unitsidx},'mm')
    scalefactor = 1;
end

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





