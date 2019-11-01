function fwmodel = existMCOutput(fwmodel,probe,dirnameSubj)

fwmodel.errMCoutput = zeros(probe.noptorig,fwmodel.nWavelengths);
d1 = repmat(struct('filename','','str','','year',[],'month',[],'day',[],'hour',[],'min',[],'sec',[],'num',[]),probe.noptorig,fwmodel.nWavelengths);
d2 = repmat(struct('filename','','str','','year',[],'month',[],'day',[],'hour',[],'min',[],'sec',[],'num',[]),probe.noptorig,fwmodel.nWavelengths);

if isempty(probe.optpos_reg)
    return;
end

ERR=1;

if dirnameSubj(end)~='/' && dirnameSubj(end)~='\' 
    dirnameSubj(end+1)='/';
end


% Get source and detector positions
jj=1; kk=1;
srcpos=[]; detpos=[];
nsrc = probe.nsrc;
for ii=1:probe.noptorig
    if ii<=nsrc
        srcpos(jj,:) = probe.optpos_reg(ii,:);
        jj=jj+1;
    else
        detpos(kk,:) = probe.optpos_reg(ii,:);
        kk=kk+1;
    end
end

extin = '';
extout = '';
[mc_appnamelist, mc_appextin, mc_appextout] = mcAppList();
for ii=1:length(mc_appnamelist)
    if ~isempty(dir(['./fw/*', mc_appextout{ii}]));
        extin = mc_appextin{ii};
        extout = mc_appextout{ii};
        fwmodel = setMCappname(fwmodel, extout);
        break;
    end
end

if isempty(extin)
    return;
end

for iWav = 1:fwmodel.nWavelengths
    
    for ii=1:size(srcpos,1)
        filenameInput = sprintf('%sfw/fw%d.s%d%s', dirnameSubj, iWav, ii, extin);
        config = read_tMCimg_inp(filenameInput);
        
        if isempty(config)
            continue;
        end
        
        if mcParamsChanged(fwmodel, config, iWav)
            fwmodel.errMCoutput(ii,iWav)=-2;
            continue;
        end
        
        p1=config.srcpos;
        p2=srcpos(ii,:);
        if ~all(abs(p2-p1)<ERR)
            fwmodel.errMCoutput(ii,iWav)=-1;
            continue;
        end
        fwmodel.errMCoutput(ii,iWav)=1;
        
        filenameOutput = sprintf('%sfw/fw%d.s%d%s', dirnameSubj, iWav, ii, extout);
        fileOutput = dir(filenameOutput);
        if isempty(fileOutput)
            continue;
        end
        fwmodel.errMCoutput(ii,iWav)=2;
        
        filenameInputStruct = dir(filenameInput);
        filenameOutputStruct = dir(filenameOutput);
        foo1 = getFileDateStruct(filenameInputStruct);
        foo2 = getFileDateStruct(filenameOutputStruct);        
        if isempty(foo1) | isempty(foo2)
            continue;
        end        
        d1(ii,iWav) = foo1;
        d2(ii,iWav) = foo2;
        
        if d1(ii,iWav).num>d2(ii,iWav).num
            continue;
        end
        fwmodel.errMCoutput(ii,iWav)=3;
    end
    
    if isempty(ii)
        ii=0;
    end
    
    for jj=1:size(detpos,1)
        filenameInput = sprintf('%sfw/fw%d.d%d%s', dirnameSubj, iWav, jj, extin);
        config = read_tMCimg_inp(filenameInput);
        
        if isempty(config)
            continue;
        end
        
        p1=config.srcpos;
        p2=detpos(jj,:);
        if ~all(abs(p2-p1)<ERR)
            fwmodel.errMCoutput(ii+jj,iWav)=-1;
            continue;
        end
        fwmodel.errMCoutput(ii+jj,iWav)=1;
        
        filenameOutput = sprintf('%sfw/fw%d.d%d%s', dirnameSubj, iWav, jj, extout);
        fileOutput = dir(filenameOutput);
        if isempty(fileOutput)
            continue;
        end
        fwmodel.errMCoutput(ii+jj,iWav)=2;
        
        filenameInputStruct = dir(filenameInput);
        filenameOutputStruct = dir(filenameOutput);
        foo1 = getFileDateStruct(filenameInputStruct);
        foo2 = getFileDateStruct(filenameOutputStruct);
        if isempty(foo1) | isempty(foo2)
            continue;
        end        
        d1(ii+jj,iWav) = foo1;
        d2(ii+jj,iWav) = foo2;

        if d1(ii+jj,iWav).num>d2(ii+jj,iWav).num
            continue;
        end
        fwmodel.errMCoutput(ii+jj,iWav)=3;
    end
    
end




% ---------------------------------------------------------------
function fwmodel = setMCappname(fwmodel, extout)

switch(extout)
    case '.2pt'
        if ~strcmp(fwmodel.mc_appname, 'tMCimg')
            fwmodel.mc_rootpath    = '';
            fwmodel.mc_exepath     = '';
            fwmodel.mc_appname     = 'tMCimg';
            fwmodel.mc_exename     = '';
            fwmodel.mc_exename_ext = '';
            fwmodel.mc_options     = '';
        end
    case '.inp.mc2'
        if ~strcmp(fwmodel.mc_appname, 'mcx')
            fwmodel.mc_rootpath    = '';
            fwmodel.mc_exepath     = '';
            fwmodel.mc_appname     = 'mcx';
            fwmodel.mc_exename     = '';
            fwmodel.mc_exename_ext = '';
            fwmodel.mc_options     = '';
        end
end



% -------------------------------------------------------------------
function b = mcParamsChanged(fwmodel, config, iWav)

b = false;
if fwmodel.nphotons ~= config.phot_num;
    b = true;
end


for kk=1:size(config.tiss_prop,1)
    if fwmodel.headvol.tiss_prop(kk).scattering(iWav) ~= config.tiss_prop(kk,1);
        b = true;
    end
    if fwmodel.headvol.tiss_prop(kk).anisotropy(1) ~= config.tiss_prop(kk,2);
        b = true;
    end
    if fwmodel.headvol.tiss_prop(kk).absorption(iWav) ~= config.tiss_prop(kk,3);
        b = true;
    end
    if fwmodel.headvol.tiss_prop(kk).refraction(1) ~= config.tiss_prop(kk,4);
        b = true;
    end
end
