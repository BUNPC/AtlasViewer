function [digpts, pts] = getDigpts(digpts, dirname, refpts)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Parse arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Arg 1
if ~exist('digpts','var') || isempty(digpts)
    digpts = initDigpts();
end

% Arg 2
if ~exist('dirname','var') || isempty(dirname)
    dirname = filesepStandard(pwd);
end

% Arg 3
if ~exist('refpts','var')
    refpts = [];
end

pts = [];
if iscell(dirname)
    for ii=1:length(dirname)
        digpts = getDigpts(digpts, dirname{ii}, refpts);
        if ~digpts.isempty(digpts)
            return;
        end
    end
    return;
end

if ~existDigpts(digpts)
    digpts = initDigpts();
end

digpts.headsize = getHeadsize(digpts.headsize, dirname);

inputfile = '';
if exist(dirname,'file')==2
    inputfile = dirname;
    k = find(dirname=='/' | dirname=='\');
    if ~isempty(k)
        dirname = dirname(1:k(end));
    end
elseif exist(dirname,'dir')==7
    if dirname(end)~='/' && dirname(end)~='\'
        dirname(end+1)='/';
    end
    inputfile = [dirname, 'digpts.txt'];
end


% Check if there's a group of subjects with dig pts in current subject
% folder. If yes then create a group of dig pt structures to represent
% them. They'll be used when importing a group probe, which will be the
% mean of all the subjects' dig pts.
digpts = getGroupDigpts(digpts, dirname, refpts);

% Check if dig pts file exists in current subject folder
if ~exist(inputfile,'file')
    return;
end

digpts = resetDigpts(digpts);

iP=1; iR=1;
fid = fopen(inputfile,'r');
while 1
    try
        
        str = fgetl(fid);
        if ~isempty(str) && str(1)==-1
            break;
        end
        if isempty(str)
            continue;
        end
        if ~my_isalpha_num(str(1))
            continue;
        end
        
        k = find(str==':');
        if lower(str(1))=='s' && isnumber(str(2))
            iS=str2num(str(2:min(strfind(str,':'))-1));  % Use the index from the file
            digpts.srcpos(iS,:) = str2num(str(k+1:end));
            % iS=iS+1;
        elseif lower(str(1))=='d' && isnumber(str(2))
            iD=str2num(str(2:min(strfind(str,':'))-1));  % Use the index from the file
            digpts.detpos(iD,:) = str2num(str(k+1:end));
            % iD=iD+1;
        elseif lower(str(1))=='m' && isnumber(str(2))
            iM = str2num(str(2:min(strfind(str,':'))-1));  % Use the index from the file
            digpts.dummypos(iM,:) = str2num(str(k+1:end));
        elseif str(1)=='@'
            digpts.pcpos(iP,:) = str2num(str(k+1:end));
            iP=iP+1;
        elseif ~isempty(k)
            label = str(1:k-1);
            k2 = find(label==' ');
            label(k2)=[];
            switch(lower(label))
                case 'nz'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'nz';
                    iR=iR+1;
                case 'iz'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'iz';
                    iR=iR+1;
                case {'rpa'}
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'rpa';
                    iR=iR+1;
                case {'lpa'}
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'lpa';
                    iR=iR+1;
                case {'a2'}
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'a2';
                    iR=iR+1;
                case {'a1'}
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'a1';
                    iR=iR+1;
                case {'ar'}
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'ar';
                    iR=iR+1;
                case {'al'}
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'al';
                    iR=iR+1;
                case 'cz'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'cz';
                    iR=iR+1;
                case 'fpz'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'fpz';
                    iR=iR+1;
                case 'afz'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'afz';
                    iR=iR+1;
                case 'fz'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'fz';
                    iR=iR+1;
                case 'fcz'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'fcz';
                    iR=iR+1;
                case 'cpz'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'cpz';
                    iR=iR+1;
                case 'pz'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'pz';
                    iR=iR+1;
                case 'poz'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'poz';
                    iR=iR+1;
                case 'oz'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'oz';
                    iR=iR+1;
                case 't7'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 't7';
                    iR=iR+1;
                case 'c5'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'c5';
                    iR=iR+1;
                case 'c3'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'c3';
                    iR=iR+1;
                case 'c1'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'c1';
                    iR=iR+1;
                case 'c2'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'c2';
                    iR=iR+1;
                case 'c4'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'c4';
                    iR=iR+1;
                case 'c6'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'c6';
                    iR=iR+1;
                case 't8'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 't8';
                    iR=iR+1;
                case 'fp1'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'fp1';
                    iR=iR+1;
                case 'f7'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'f7';
                    iR=iR+1;
                case 'p7'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'p7';
                    iR=iR+1;
                case 'o1'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'o1';
                    iR=iR+1;
                case 'fp2'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'fp2';
                    iR=iR+1;
                case 'f8'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'f8';
                    iR=iR+1;
                case 'p8'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'p8';
                    iR=iR+1;
                case 'o2'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'o2';
                    iR=iR+1;
                case 'f3'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'f3';
                    iR=iR+1;
                case 'f4'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'f4';
                    iR=iR+1;
                case 'p3'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'p3';
                    iR=iR+1;
                case 'p4'
                    digpts.refpts.pos(iR,:) = str2num(str(k+1:end));
                    digpts.refpts.labels{iR} = 'p4';
                    iR=iR+1;
            end
        else
            digpts.pcpos(iP,:) = str2num(str);
            iP=iP+1;
        end
    catch
        dbg=1;
    end
end
fclose(fid);

if ~digpts.isempty(digpts)
    digpts.pathname = dirname;
end

if isempty(refpts) || isempty(refpts.isempty(refpts))
    return
end

digpts = setDigptsOrientation(digpts, dirname);




% -----------------------------------------
function b = isnumber(str)
b = ~isempty(str2num(str));


