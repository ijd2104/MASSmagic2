function saveImage(count, txt)
    addpath exportfig/
    name=strcat('images\',num2str(count),'.png');
    export_fig(name);
    fid=fopen('directory.txt','a');
    fprintf(fid,'%s | %s\n',txt,strcat('images\',num2str(count),'.png'));
    rmpath exportfig/
    fclose(fid);
end