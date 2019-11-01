function genStimMarks(filenames)

% 
% Usage: 
%   
%    genStimMarks(filenames)
%
% Description:
%   
%    For each file in filenames, assigns 1 in s for every time point 
%    in tp each file specified in filenames.
%

MAXSTIM = 5;
MAXCOND = 15;

if ~exist('filenames') || isempty(filenames)
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


for iF=1:length(files)
    load(files(iF).name, '-mat','s','t');

    nStim = round(MAXSTIM*rand(1,1));
    nCond = round((MAXCOND-1)*rand(1,1))+1;

    if exist('s')
        s0 = s;
    end

    s = zeros(size(t,1),nCond);
    for ii=1:nStim
        i = round((size(t,1)-1) * rand(1,1))+1;
        j = round((nCond-1) * rand(1,1))+1;
        s(i,j) = 1;
    end

    save(files(iF).name,'s','s0','-mat','-append');
end   
