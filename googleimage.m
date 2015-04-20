function googleimage(name)

<<<<<<< HEAD
%web(['http://images.google.com/images?q=' argin]);
=======
>>>>>>> origin/master
    hexcode=dec2hex(double(name));
    percents=repmat('%',size(hexcode,1),1);
    urlstr=sprintf('%s',strcat(percents,hexcode)');
html = urlread(['http://images.google.com/images?q=' urlstr]);
<<<<<<< HEAD
%display(html);
=======
%html = urlread(['http://www.bing.com/images/search?q=' urlstr]);
%moon = findstr('',html);
%display(moon);
>>>>>>> origin/master
beg = findstr('src="http:',html);
begend = html(beg:beg+200);
display(begend);
fin = findstr('" width="',begend);
%disp(beg);
%disp(fin);
%beg1 = beg(1);
%disp(beg);
%bege = beg+200;
%disp(html(beg:bege));
%disp(html(beg+5:fin-1));
%filename= websave('urlimage', ['http://images.google.com/images?q=' argin]);
A = imread(begend(6:fin-1));
figure, imshow(A,'Border','tight');
end
