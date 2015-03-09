function [ outputtime ] = subtractTime(time,interval)
    t=strsplit(time,':');
    secs=str2double(t(1))*3600+str2double(t(2))*60+str2double(t(3));
    secs=secs-interval;
    hours=floor(secs/3600);
    secs2=secs-hours*3600;
    minutes=floor(secs2/60);
    secs3=secs2-minutes*60;
    hours=num2str(hours);
    minutes=num2str(minutes);
    secs3=num2str(secs3);
    if length(hours)==1
        hours=strcat('0',hours);
    end
    if length(minutes)==1
        minutes=strcat('0',minutes);
    end
    if length(secs3)==1
        secs3=strcat('0',secs3);
    end
    outputtime=strcat(hours,':',minutes,':',secs3);
end