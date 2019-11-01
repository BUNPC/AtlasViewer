function genStimMatrix(filenames,nCond)


if length(filenames)==0
    files = dir('*.nirs');
    while isempty( files ) 
        pathnm = uigetdir( 'Choose directory with NIRS files' );
        if pathnm==0 
            return;
        end
        cd( pathnm )
        files = dir('*.nirs');
    end
else
    for iF=1:length(filenames)
        files(iF).name = filenames{iF};
    end
end

m=length(files);
n=length(nCond);
d=n-m;
if d<0
    nCond = [nCond ones(1,abs(d))];
end

for iF=1:length(files)
    load(files(iF).name, '-mat','t');
    s = zeros(size(t,1),nCond(iF));
    save(files(iF).name,'s','-mat','-append');
end   
