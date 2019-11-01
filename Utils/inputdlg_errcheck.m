function answer = inputdlg_errcheck(prompt, title, nlines, def)

answer = inputdlg(prompt, title, nlines, def, 'on');
while 1
    err=zeros(1,length(prompt));
    if isempty(answer)
        break;
    end
    for ii=1:length(answer)
        if ~isnumber(answer{ii})
            err(ii)=1;
        end
        if length(str2num(answer{ii})) > 1
            err(ii)=2;
        end
    end
    if ~all(err==0)
        q = menu(sprintf('Invalid input for parameter # %d. Do you want to try again?', ii),'Yes','No');
        if q==2
            answer = {};
            return;
        end
        answer = inputdlg(prompt, title, nlines, def, 'on');
        continue;
    end
    break;
end
