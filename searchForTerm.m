function [figures] = searchForTerm(term)
    figures=[];
    fid=fopen('directory.txt','r');
    tline = fgetl(fid);
    while ischar(tline)
        if isempty(strfind(tline,term))==0
            index=strfind(tline,'|');
            figures=[figures;tline(index+2:end)];
            A = imread(tline(index+2:end));
            figure, imshow(A,'Border','tight');
        end
        tline = fgetl(fid);
    end
end