function genNIRSSubjData(template, subjname, nruns)

% 
% Usage:
%    
%    genNIRSSubjData(template, subjname, nruns)
%
% Description:
%
%    Generate 'nruns' .nirs files for subject named 'subjname'. The data for the files is based 
%    on the data from the 'template' .nirs file which is multiplied by a random number. 
%
% Example 1: 
%
%    Generate 3 runs for subject named 'subj1' based on the data from file 'template.nirs'.
%
%    genNIRSSubjData('./template.nirs','subj1',3)
%
%

if ~exist('rcoeff','var') || (exist('rcoeff','var') && length(rcoeff)<nruns)
    rcoeff = ones(nruns,1)*50;
end

load(template,'-mat');
if exist('aux10')
    aux=aux10;
end

if isempty(subjname)
    k1=[findstr(template,'/') findstr(template,'\')];
    k1=sort(k1);
    template=template(k1(end)+1:end);
    k2=findstr(template,'.nirs');
    subjname=template(1:k2-1);
else
    subjname=subjname;
end

d0=d;
for ii=1:nruns
    dmean = mean(d(:))/10;
    dr=dmean.*rand(size(d,1),size(d,2));
    d=d0+dr;
    jj=ii;
    while 1
        if(jj>9)
            filename = [subjname '_run' num2str(jj) '.nirs'];
        else
            filename = [subjname '_run0' num2str(jj) '.nirs'];
        end
        if exist(filename,'file')
            jj=jj+1;
            continue;
        else
            break;
        end
    end
    save(filename, '-mat', 'SD', 't', 'd', 's', 'ml', 'aux');
end

