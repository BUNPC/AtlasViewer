function upgradeNIRSDir()


files = dir('*.nirs');
while isempty( files ) 
    pathnm = uigetdir( 'Choose directory with NIRS files' );
    if pathnm==0 
        return;
    end
    cd( pathnm )
    files = dir('*.nirs');
end
nFiles = length(files);
[flag, iF] = EasyNIRS_checkNIRSacrossFiles( );
if flag==1
elseif flag==-1
    ch=menu(sprintf('SD Warning! %s has different SD structure.',files(iF).name),'Proceed','Exit');
    if ch==2
        return;
    end  
elseif flag==-2
    menu(sprintf('Error: %s has bad s vector.',files(iF).name),'OK');
    return;
else
    ch=menu(sprintf('SD Warning! %s has different SD geometry.',files(iF).name),'Proceed','Exit');
    if ch==2
        return;
    end
end

if ~exist('./upgrade','file')
    mkdir('./upgrade');
end
copyfile('./*.nirs','./upgrade');


% ---------------------------------------------------------------
if exist('./groupResults.mat','file')
    load('groupResults.mat');
    hwait = waitbar( 0, 'Upgrade User Data' );
    for ii=1:length(group)
        for jj=1:length(group(ii).subjs)
            for kk=1:length(group(ii).subjs(jj).runs)
                iF = group(ii).subjs(jj).runs(kk).fileidx;
                clear timeExcludeVec timeExclude
                load(group(ii).subjs(jj).runs(kk).filename,'-mat','timeExclude','timeExcludeVec');
                if exist('timeExcludeVec')
                     timeExclude0.tranges = timeExclude;
                     timeExclude0.vec = timeExcludeVec;
                     timeExclude = timeExclude0;
                     save(['./upgrade/' group(ii).subjs(jj).runs(kk).filename],'timeExclude','-mat','-append');
                end
                hwait = waitbar(iF/nFiles, hwait, sprintf('Upgrading User Data in %s',...
                                group(ii).subjs(jj).runs(kk).filename));
                if isfield(group(ii).subjs(jj).runs(kk),'userdata')
                    userdata = group(ii).subjs(jj).runs(kk).userdata;
                    save(['./upgrade/' group(ii).subjs(jj).runs(kk).filename],'userdata','-mat','-append');
                end
            end
        end
    end
    save('./upgrade/groupResults.mat','group');
    close(hwait);
else
    for ii=1:length(files)
        clear timeExcludeVec timeExclude
        load(files(ii).name,'-mat','timeExclude','timeExcludeVec');
        if exist('timeExcludeVec')
             timeExclude0.tranges = timeExclude;
             timeExclude0.vec = timeExcludeVec;
             timeExclude = timeExclude0;
             save(['./upgrade/' files(ii).name],'timeExclude','-mat','-append');
        end
    end
end



% ---------------------------------------------------------------    
C=stimGUI_GetConditions('./stimConditionNames.cfg');
CondNames0 = C;
hwait = waitbar( 0, 'Upgrade Conditions' );
for iF=1:nFiles
    hwait = waitbar(iF/nFiles, hwait, sprintf('Upgrading %s',files(iF).name) );
    load(['./' files(iF).name],'-mat','s');
    if exist('CondNames','var') && ~isempty(CondNames)
        continue;
    end
    CondNames = CondNames0;

    % First make number of cols in s matrix and number of cond labels the same
    n=length(CondNames);
    m=size(s,2);
    d=n-m;
    k=0;
    if(d>0)
        s = [s zeros(size(s,1),d)];
    elseif(d<0)
        for ii=n+1:m
            while ~isempty(find(strcmp(CondNames,num2str(ii+k))))
                k=k+1;
            end
            CondNames{ii} = num2str(ii+k);
        end
    end

    % Merge duplicate conditions to one column in s
    for iS=1:size(s,2)
        k = find(strcmp(CondNames,CondNames{iS}));
        if length(k)>1
            k2 = k(2:end);
            [i,j]=find(s(:,k2)==1);
            if length(i)>0
                s(i,k(1)) = 1;
                s(i,k2(j)) = 0;
            end
        end
    end

    % Remove zero columns from s matrix
    lstIS = [];
    c=1;
    for iS=1:size(s,2)
        if all(~s(:,iS))
            lstIS(c)=iS;
            c=c+1;
        end
    end

    s(:,lstIS)=[];
    CondNames(lstIS)=[];
    save(['./upgrade/' files(iF).name],'s','CondNames','-mat','-append');
end
close(hwait);


% ---------------------------------------------------------------
% Create stimConditionNames.txt file based on the old one
jj=1;
fid = fopen('./upgrade/stimConditionNames.txt','w');
CondNamesNew = {};
for ii=1:length(CondNames0)
    if isempty(find(strcmp(CondNamesNew,CondNames0{ii})))
        fprintf(fid,'%s\n',CondNames0{ii});
        CondNamesNew{jj} = CondNames0{ii};
        jj=jj+1;
    end
end
fclose(fid);



% -----------------------------------------------------------------
% Copy groupResults and processing stream config files 
if exist('./upgrade','file')
    if exist('./groupResults.mat','file')
        copyfile ./groupResults.mat ./upgrade;
    end
    files = dir('./*.cfg');
    for ii=1:length(files)
        if strcmp(files(ii).name,'stimConditionNames.cfg')
            continue;
        end 
        copyfile(files(ii).name,'./upgrade');
    end
end

