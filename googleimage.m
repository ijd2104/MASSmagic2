function googleimage(name)

    hexcode=dec2hex(double(name));
    percents=repmat('%',size(hexcode,1),1);
    urlstr=sprintf('%s',strcat(percents,hexcode)');
    urlstr = strcat(urlstr,'&imgsz=xlarge&rsz=8');
html = urlread(['http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=' urlstr]);

begend = html;
beg = strfind(begend,'"url":"');
i = randi(numel(beg));
begend = html(beg(i)+7:end);
fin = strfind(begend,'","');

try
    A = imread(begend(1:fin-1));
catch
    begend = html;
    beg = strfind(begend,'"url":"');
    i = randi(numel(beg));
    begend = html(beg(i)+7:end);
    fin = strfind(begend,'","');
    try
       A = imread(begend(1:fin-1)); 
    catch
        begend = html;
        beg = strfind(begend,'"url":"');
        i = randi(numel(beg));
        begend = html(beg(i)+7:end);
        fin = strfind(begend,'","');
        A = imread(begend(1:fin-1));
    end
end
    
figure('MenuBar','none','NumberTitle','off','Name',name)
%set(0,'DefaultFigureMenu','none');
imshow(A,'Border','tight');
end
