function googleimage(name)

%web(['http://images.google.com/images?q=' argin]);
html = urlread(['http://images.google.com/images?q=' name]);
%display(url);
beg = findstr('src="http:',html);
begend = html(beg:beg+200);
%display(begend);
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
