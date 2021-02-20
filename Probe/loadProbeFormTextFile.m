function probe = loadProbeFormTextFile(varargin)

if nargin==0
    probe = initProbe();
    dirname = filesepStandard(pwd);
    filename = 'probe_reg.txt';
    headsurf = [];
elseif nargin==1
    if ischar(varargin{1})
        probe = initProbe();
        dirname = varargin{1};
    elseif isstruct(varargin{1})
        probe = varargin{1};
        dirname = filesepStandard(pwd);
    end
    filename = 'probe_reg.txt';
    headsurf = [];
elseif nargin==2
    if ischar(varargin{1})
        probe = initProbe();
        dirname = varargin{1};
        if ischar(varargin{2})
            filename = varargin{2};
            headsurf = [];
        else
            filename = 'probe_reg.txt';
            headsurf = varargin{2};
        end
    elseif isstruct(varargin{1})
        probe = varargin{1};
        dirname = varargin{2};
        filename = 'probe_reg.txt';
    end
elseif nargin==3
    probe = varargin{1};
    dirname = varargin{2};
    if ischar(varargin{3})
        filename = varargin{3};
        headsurf = [];
    else
        filename = 'probe_reg.txt';
        headsurf = varargin{3};
    end
elseif nargin==4
    probe = varargin{1};
    dirname = varargin{2};
    filename = varargin{3};
    headsurf = varargin{4};
end

try
    fid = fopen([dirname, filename],'r');
catch
    return;
end
if fid<0
    return;
end

srcpos = [];
detpos = [];
dummypos = [];
while 1
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
        iS = str2num(str(2:min(strfind(str,':'))-1));  % Use the index from the file
        srcpos(iS,:) = str2num(str(k+1:end));
    elseif lower(str(1))=='d' && isnumber(str(2))
        iD = str2num(str(2:min(strfind(str,':'))-1));  % Use the index from the file
        detpos(iD,:) = str2num(str(k+1:end));
    elseif lower(str(1))=='m' && isnumber(str(2))
        iM = str2num(str(2:min(strfind(str,':'))-1));  % Use the index from the file
        dummypos(iM,:) = str2num(str(k+1:end));
    end
end
probe.srcpos   = srcpos;
probe.detpos   = detpos;
probe.optpos   = [srcpos; detpos; dummypos];
probe.nsrc     = size(srcpos,1);
probe.nopt     = size(probe.optpos,1);
probe.noptorig = size(probe.srcpos,1) + size(probe.detpos,1);
probe.registration.dummypos = dummypos;
if isPreRegisteredProbe(probe, headsurf)
    probe.optpos_reg = probe.optpos;
end
fclose(fid);
