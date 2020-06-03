function digpts = getDigpts(digpts, dirname)

if iscell(dirname)
    for ii=1:length(dirname)
        digpts = getDigpts(digpts, dirname{ii});
        if ~digpts.isempty(digpts)
            return;
        end
    end
    return;
end

if ~existDigpts(digpts)
    digpts = initDigpts();
end

inputFile='';
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
    inputfile = [dirname 'digpts.txt'];
end


% Check if there's a group of subjects with dig pts in current subject
% folder. If yes then create a group of dig pt structures to represent
% them. They'll be used when importing a group probe, which will be the
% mean of all the subjects' dig pts.
digpts = getGroupDigpts(digpts, dirname);

% Check if dig pts file exists in current subject folder
if ~exist(inputfile,'file')
    return;
end

digpts = resetDigpts(digpts);

iP=1; iS=1; iD=1; iR=1;
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
        if lower(str(1))=='s' && AVUtils.isnumber(str(2))
            iS=str2num(str(2:min(strfind(str,':'))-1));  % Use the index from the file
            digpts.srcmap(1,iS) = str2num(str(2:k-1));
            digpts.srcpos(iS,:) = str2num(str(k+1:end));
            % iS=iS+1;
        elseif lower(str(1))=='d' && AVUtils.isnumber(str(2))
            iD=str2num(str(2:min(strfind(str,':'))-1));  % Use the index from the file
            digpts.detmap(1,iD) = str2num(str(2:k-1));
            digpts.detpos(iD,:) = str2num(str(k+1:end));
            % iD=iD+1;
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

[nz,iz,rpa,lpa,cz] = getLandmarks(digpts.refpts);

% JD removed this on 06/27/2018 because of realization that alignRefptsWithXyz
% doesn't not just rotate and translate, but changes the shape of
% the digitized points.
%
% Align dig pt axes with XYZ axes; This matters when we register atlas to
% dig points. If dig points are not very well aligned with xyz then when we
% register MRI anatomy (which is usually aligned) the newly registered MRI
% anatomy will be just as misaligned with xyz as the dig points. This will
% make standard S/I, R/A, A/P views not work very well.
%
% digpts.T_2xyz = alignRefptsWithXyz(nz, iz, rpa, lpa, cz);

[digpts.refpts.orientation, digpts.refpts.center] = getOrientation(nz, iz, rpa, lpa, cz);

digpts.orientation = digpts.refpts.orientation;
digpts.center      = digpts.refpts.center;

if exist([dirname, 'digpts2mc.txt'],'file')
    digpts.T_2mc = load([dirname, 'digpts2mc.txt'],'-ascii');
else
    digpts.T_2mc = eye(4);
end
T = digpts.T_2mc * digpts.T_2xyz;
digpts.refpts.pos = xform_apply(digpts.refpts.pos, T);
digpts.srcpos = xform_apply(digpts.srcpos, T);
digpts.detpos = xform_apply(digpts.detpos, T);
digpts.pcpos  = xform_apply(digpts.pcpos, T);

if ~digpts.isempty(digpts)
    digpts.pathname = dirname;
end




% -----------------------------------------
function b = AVUtils.isnumber(str)
b = ~isempty(str2num(str));


