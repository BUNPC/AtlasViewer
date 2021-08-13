function saveSD(SD, dirname)
if ispathvalid([dirname, '/probe.SD'])
    filedata = load([dirname, '/probe.SD'], '-mat');
    if ~sd_data_Equal(SD, filedata.SD)
        save([dirname, '/probe.SD'],'-mat', 'SD');
    end
else
    save([dirname, '/probe.SD'],'-mat', 'SD');
end
