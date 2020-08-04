function foos = removeblanks( boos )

foos = {};
for ii=1:length(boos)
    kk=0;
    for jj=1:length(boos{ii})
        if boos{ii}(jj)~=' ';
            kk=kk+1;
            foos{ii}(kk) = boos{ii}(jj);
        end
    end
end