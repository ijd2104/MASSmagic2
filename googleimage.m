function googleimage(name)

%web(['http://images.google.com/images?q=' argin]);
    hexcode=dec2hex(double(name));
    percents=repmat('%',size(hexcode,1),1);
    urlstr=sprintf('%s',strcat(percents,hexcode)');
    urlstr = strcat(urlstr,'&imgsz=large');
%html = urlread(['http://images.google.com/images?q=' urlstr]);
html = urlread(['http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=' urlstr]);
%display(html);
%html = urlread(['http://www.bing.com/images/search?q=' urlstr]);
%moon = findstr('',html);
%display(moon);
%beg = findstr('src="http:',html);
beg = findstr('"url":"',html);
%begend = html(beg:beg+200);
begend = html(beg+7:end);
%display(begend);
%fin = findstr('" width="',begend);
fin = findstr('","',begend);
%disp(beg);
%disp(fin);
%beg1 = beg(1);
%disp(beg);
%bege = beg+200;
%disp(html(beg:bege));
%disp(html(beg+5:fin-1));
%filename= websave('urlimage', ['http://images.google.com/images?q=' argin]);
try
    A = imread(begend(1:fin-1));
catch
    try
        beg = findstr('"url":"',begend);
        begend = begend(beg+7:end);
        fin = findstr('","',begend);
        A = imread(begend(1:fin-1));
    catch
        beg = findstr('"url":"',begend);
        begend = begend(beg+7:end);
        fin = findstr('","',begend);
        A = imread(begend(1:fin-1));
    end
end
    
figure('MenuBar','none','NumberTitle','off','Name',name)
%set(0,'DefaultFigureMenu','none');
imshow(A,'Border','tight');
end
