function [verstr, V] = version2string()

V = AVUtils.getVernum();
if str2num(V{2})==0 || isempty(V{2})
    verstr = sprintf('v%s', [V{1}]);
else
    verstr = sprintf('v%s', [V{1} '.' V{2}]);
end

if ~isempty(V{3})
    verstr = sprintf('%s, %s', verstr, V{3});
end    