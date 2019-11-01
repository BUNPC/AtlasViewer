function b = istextfile(fname)

b = false;
fd = fopen(fname, 'r');
if fd<0
    b=[];
    return;
end
s = uint8(fread(fd, 100, 'uint8'));
n = length(s);
c=0;
for ii=1:n
    if istext(s(ii))
        c=c+1;
    end
end
if c/n >= .9
    b = true;
end
fclose(fd);




% ----------------------------------------------------------------
function b=istext(c)

b=false;
if length(c)>1
    return;
end
    
asciiset = ' !@#$%^&*()_-+=\[]{}?~<>.,:;|"''0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

b = ~isempty(findstr(c, asciiset));

