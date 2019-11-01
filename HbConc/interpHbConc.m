function [Cout, k] = interpHbConc(v, C, r, iCh)

% 
% [Cout, k] = interpHbConc(v, C, r, k)
%
% Inputs:
%    
%     v - Cortex mesh vertices
%     C - Hb Concentration, HRF x Ch 
%     r - Projected locations on the cortex
%    
% 
C = C(:,:,iCh); % include only long distance and active channels
r = r(iCh,:); % include only long distance and active channels

Cout = zeros(size(v,1),1);
Cmean = [];
Ci = [];
k = [];

if isempty(v)
    return;
end
if isempty(C)
    return;
end
if isempty(r)
    return;
end

% Assign mean HRF to every channel
jj=1;
for ii=1:size(C,3)
    k = find(isnan(C(:,1,ii)) | isinf(C(:,1,ii)));
    if ~isempty(k)
        Cmean(jj) = 0;
    else
        Cmean(jj) = mean(C(:,1,ii));
    end
    jj=jj+1;
end


% Find all the mesh vertices within 3 cm of a channel projection point
h = 20;
k = [];
for kk=1:size(r,1)
    if ~ismember(kk,iCh)
        continue;
    end
    d = dist3(v,r(kk,:));
    j = find(d<h);
    k = [k(:); j(:)];
end
k = unique(k);

h = waitbar(0, 'Please wait...');

% Get interpolated value (weighted averages for all the mesh vertices within 
% 3 cm of a % channel projection point
ri = v(k,:);
N = size(ri,1);
interval = floor(N/50);
for ii=1:N   
    Ci(ii) = meanweighted(Cmean, r, ri(ii,:));
   %   Ci(ii) = meanweighted(Cmean(iCh), r(iCh,:), ri(ii,:)); 
    if mod(ii,interval)==0
        waitbar(ii/N, h, sprintf('Completed %d%% of Hb interpolation', uint32(100*ii/N)));
    end
end

close(h)
foo = zeros(size(Ci));
for m = 1:size(Ci,2)
    if Ci(m)>=0
        foo(m) = Ci(m)/max(Ci)*max(Cmean);
    else
        foo(m) = Ci(m)/min(Ci)*min(Cmean);
    end
end

Cout(k) = foo;

    
    
