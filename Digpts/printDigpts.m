function printDigpts(digpts, idprefixmsg)

if ~exist('idprefixmsg','var') || isempty(idprefixmsg)
    idprefixmsg = 'Digpts for subject';
end
fprintf('\n');

fprintf('%s %s:\n', idprefixmsg, digpts.pathname);
for ii = 1:length(digpts.refpts.pos)
    fprintf('%s: [%0.4f, %0.4f, %0.4f]\n', digpts.refpts.labels{ii}, digpts.refpts.pos(ii,1), digpts.refpts.pos(ii,2), digpts.refpts.pos(ii,3));
end

nsrc = size(digpts.srcpos, 1);
if nsrc > 5
    n = 5;
else
    n = nsrc;
end

for ii = 1:n
    fprintf('s%d: [%0.4f, %0.4f, %0.4f]\n', ii, digpts.srcpos(ii,1), digpts.srcpos(ii,2), digpts.srcpos(ii,3));
end
fprintf('\n');

