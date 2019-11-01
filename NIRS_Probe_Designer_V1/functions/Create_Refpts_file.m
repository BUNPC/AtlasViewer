function Create_Refpts_file(refpts,filename)

pos = refpts.pos;
save(filename, 'pos', '-ascii');

fd = fopen([filename(1:end-4) '_labels.txt'], 'wt');
for ii=1:length(refpts.labels)
    fprintf(fd, '%s\n', refpts.labels{ii});
end
fclose(fd);


