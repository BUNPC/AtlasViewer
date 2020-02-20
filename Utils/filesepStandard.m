function pathname = filesepStandard(pathname)

%
% Usage:
%    pathname = filesepStandard(pathname)
%
% Takes a pathname as argument and replaces any non-standard file/folder
% separators with standard ones, that is '/'. It also gets rid of redundant
% file seps
% 
% Example: 
%    
%   >> pathname = 'C:\dir1\\\dir2\\dir3\test1/\test2/'
%   >> pathname = filesepStandard(pathname)
%
%   pathname =
%
%   C:/dir1/dir2/dir3/test1/test2/
%
%

if isempty(pathname)
    return;
end
pathname(pathname=='\') = '/';
if pathname(end) ~= '/'
    pathname(end+1) = '/';
end
if ispc()
    if pathname(2)==':'
        pathname(1) = upper(pathname(1));
    end
end

