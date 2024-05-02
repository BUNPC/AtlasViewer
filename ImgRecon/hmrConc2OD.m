% dod = hmrConc2OD( dc, SD, ppf )
%
% UI NAME:
% Conc_to_OD
%
% dod = hmrConc2OD( dc, SD, ppf )
% Convert concentrations to OD
%
% INPUTS:
% dc: the concentration data (#time points x 3 x #SD pairs
%     3 concentrations are returned (HbO, HbR, HbT)
% SD:  the SD structure
% ppf: partial pathlength factors for each wavelength. If there are 2
%      wavelengths of data, then this is a vector ot 2 elements.
%      Typical value is ~6 for each wavelength if the absorption change is 
%      uniform over the volume of tissue measured. To approximate the
%      partial volume effect of a small localized absorption change within
%      an adult human head, this value could be as small as 0.1.
%
% OUTPUTS:
% dod: the change in OD (#time points x #channels)
%
function dod = hmrConc2OD( dc, SD, ppf )

nWav = length(SD.Lambda);
ml0 = SD.MeasList;
nTpts = size(dc,1);

dod0 = zeros(size(dc,1),size(ml0,1), size(dc,4));

if length(ppf)~=nWav
    errordlg('The length of PPF must match the number of wavelengths in SD.Lambda');
    dod = dod0;
    return
end

e = GetExtinctions( SD.Lambda );
e = e(:,1:2) / 10; % convert from /cm to /mm

% dod0 assumes sorted channel order. So we have to reorder an unsorted ml 
% to make sure its channel order matches the implicit order of dod0. 
% After we generate dod0, we reorder it's columns to match the orgiginal 
% channel order in ml0
[ml, order] = sortMl(ml0);

lst = find( ml(:,4)==1 );
for idx = 1:length(lst)
    idx1 = lst(idx);
    idx2 = find( ml(:,4)>1 & ml(:,1)==ml(idx1,1) & ml(:,2)==ml(idx1,2) );
    rho = norm(SD.SrcPos(ml(idx1,1),:)-SD.DetPos(ml(idx1,2),:));
    dod0(:,[idx1, idx2']) = (e * dc(:,1:2,idx)')' .* (ones(nTpts,1)*rho*ppf);
    end
dod = dod0(:,order,:);



% ----------------------------------------------------------
function [ml, order] = sortMl(ml0)
order = zeros(size(ml0,1),1);

k1 = find( ml0(:,4)==1 );
k2 = find( ml0(:,4)==2 );

ml1 = ml0(k1,:);
ml2 = ml0(k2,:);

ml1 = sortrows(ml1);
ml2 = sortrows(ml2);

ml = [ml1; ml2];

for iM = 1:size(ml0,1)
   order(iM) = find(ml(:,1)==ml0(iM,1) & ml(:,2)==ml0(iM,2) & ml(:,4)==ml0(iM,4));
end

