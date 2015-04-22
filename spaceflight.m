function varargout = spaceflight(varargin)
% SPACEFLIGHT MATLAB code for spaceflight.fig
%      SPACEFLIGHT, by itself, creates a new SPACEFLIGHT or raises the existing
%      singleton*.
%
%      H = SPACEFLIGHT returns the handle to a new SPACEFLIGHT or the handle to
%      the existing singleton*.
%
%      SPACEFLIGHT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPACEFLIGHT.M with the given input arguments.
%
%      SPACEFLIGHT('Property','Value',...) creates a new SPACEFLIGHT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spaceflight_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spaceflight_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%Authors: Imer del Cid, Tony Hung, Kelly Liu, Sophie Qian, Edward Zhang

% Edit the above text to modify the response to help spaceflight

% Last Modified by GUIDE v2.5 19-Apr-2015 20:47:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spaceflight_OpeningFcn, ...
                   'gui_OutputFcn',  @spaceflight_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before spaceflight is made visible.
function spaceflight_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spaceflight (see VARARGIN)

%% Music player code
dirlist=dir('Music');
handles.playlist=dirlist(3:length(dirlist));
handles.playlist=handles.playlist(randperm(size(handles.playlist,1)),:);
handles.count=1;
handles.pausebool=1;
[y, Fs]=audioread(strcat('Music/',handles.playlist(handles.count).name));
handles.player=audioplayer(y,Fs);

%% Plot maps
[lat,lon] = getISScoord();

%Big Map
plot_google_map
axes(handles.BigMap)
%plot(handles.BigMap,plot_google_map)
%plot(handles.BigMap,lon,lat,'or','MarkerSize',5,'LineWidth',2)
plot(lon,lat,'oc','MarkerSize',5,'LineWidth',2)
plot(15.86,45.45,'+r','MarkerSize',10,'LineWidth',2)

%Little Map
    axes(handles.LilMap);
    img = imread('MercatorProjection.jpg');
    imgH = 599;
    imgW = 773;
    imshow(img, 'InitialMag',100, 'Border','tight')
    [x0,y0] = mercatorProjection(lon,lat, imgW, imgH);  
    [x1,x2,y1,y2] = plotOrbitalPath(lat);
    hold on
    plot(x0, y0, 'oc', 'MarkerSize',5, 'LineWidth',2)
    plot(x1,y1,'--y','LineWidth',1.5)
    plot(x1,y1+25,'-b')
    plot(x2,y2+25,'-b')
    plot(x1,y1-25,'-b')
    plot(x2,y2-25,'-b')
    plot(x2,y2,'--y','LineWidth',1.5)
    hold off

%% Logo
axes(handles.logo);
imshow('massmagiclogo.png');

%%Show first Target and fill fields
sites = parseXMLFile(strcat(pwd,'\TargetSites.xml'));

longitude = zeros(numel(sites),1);
latitude = zeros(numel(sites),1);
for i = 1:numel(sites)
    lon3 = str2double(sites(i).long);
    lat3 = str2double(sites(i).lat);
    [longitude(i),latitude(i)] = mercatorProjection(lon3,lat3, 773, 599);
end
axes(handles.LilMap)
hold on
plot(longitude,latitude,'xm','MarkerSize',3,'LineWidth',2);
plot(longitude(1),latitude(1),'+r','MarkerSize',5,'LineWidth',2);
hold off

handles.sites=sites;
handles.sitecounter=1;
handles.lat=handles.sites(handles.sitecounter).lat;
handles.lon=handles.sites(handles.sitecounter).long;
set(handles.weather,'String',weather(handles.sites(handles.sitecounter).target_name));
set(handles.destinationtext,'String',handles.sites(handles.sitecounter).target_name);
set(handles.notestext,'String',handles.sites(handles.sitecounter).notes);
set(handles.lenstext,'String',handles.sites(handles.sitecounter).lenses);
targetstr=strcat(num2str(handles.sitecounter),'/',num2str(length(handles.sites)));
set(handles.targetlist,'String',targetstr);
str=getLocalTime(handles.lat,handles.lon);
set(handles.localtime,'String',str);

%%Timer Functionality and run timeTilTarget
handles.countdowntimer=timeTilTarget(lat,lon);
set(handles.countdown,'String',convertTime(handles.countdowntimer));

%Picture History
text = fileread('directory.txt');
if strcmp(text,'')==0
    handles.pcount=str2double(text(end-6));
end

%% Other
% Choose default command line output for spaceflight
handles.output = hObject;

% timer to update
handles.timer = timer(...
    'ExecutionMode', 'fixedRate', ...   % Run timer repeatedly
    'Period', 1, ...                % Initial period is 1 sec.
    'TimerFcn', {@update_display,hObject}); % Specify callback

start(handles.timer);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes spaceflight wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = spaceflight_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in NewTarget.
function NewTarget_Callback(hObject, eventdata, handles)
% hObject    handle to NewTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

localidad = '&result_type=locality&key=AIzaSyB58vqRxPw0e8s8nPNl7QyratJss20c0mY';
estado = '&result_type=administrative_area_level_1&key=AIzaSyB58vqRxPw0e8s8nPNl7QyratJss20c0mY';
url1 = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=';
lat = handles.NewLat.String;
lng = handles.NewLon.String;
target = strcat(url1,lat,',',lng,localidad);
target = urlread(target);
load errcode
if strcmp(target,errcode)
    target = strcat(url1,lat,',',lng,estado);
    target = urlread(target);
    if strcmp(target,errcode)
        handles.NewTargetName.String = 'Ocean / Invalid';
        return
    end
end
target = strsplit(target,'"formatted_address" : "');

target = strsplit(target{2},'",');
target = target{1};
handles.NewTargetName.String = target;
site_no = numel(handles.sites)+1;
handles.sites(site_no).site_no = site_no;
handles.sites(site_no).target_name = target;
handles.sites(site_no).lat = lat;
handles.sites(site_no).long = lng;
lenses = [100 180 200 300 400 440 480 800];
handles.sites(site_no).notes = [];
handles.sites(site_no).lenses = num2str([lenses(randi(numel(lenses))),lenses(randi(numel(lenses)))]);

targetstr=strcat(num2str(handles.sitecounter),'/',num2str(length(handles.sites)));
set(handles.targetlist,'String',targetstr);

%Add new target to little map
p = findobj(handles.LilMap,'-depth',1,'Color',[1 0 1]);
lng = str2double(lng);
lat = str2double(lat);
[lng,lat] = mercatorProjection(lng, lat, 773, 599);
set(p,'XData',[p.XData lng],'YData',[p.YData lat]);
guidata(hObject,handles)

    
function NewLat_Callback(hObject, eventdata, handles)
% hObject    handle to NewLat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NewLat as text
%        str2double(get(hObject,'String')) returns contents of NewLat as a double


% --- Executes during object creation, after setting all properties.
function NewLat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NewLat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in imagebox. Google image function.
function imagebox_Callback(hObject, eventdata, handles)
% hObject    handle to imagebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (get(hObject,'Value') == get(hObject,'Max'))
	googleimage(handles.sites(handles.sitecounter).target_name);
    %display('Selected');
   
else
    %display('Not selected');
end

% Hint: get(hObject,'Value') returns toggle state of imagebox




function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3



function NewLon_Callback(hObject, eventdata, handles)
% hObject    handle to NewLon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NewLon as text
%        str2double(get(hObject,'String')) returns contents of NewLon as a double


% --- Executes during object creation, after setting all properties.
function NewLon_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NewLon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox4. Wiki function. 
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (get(hObject,'Value') == get(hObject,'Max'))
	s = wiki(handles.sites(handles.sitecounter).target_name);
    %display('Selected');
    myicon = imread('massmagiclogo.png');
    h = msgbox(s, 'Wikipedia summary', 'custom', myicon);
    ah = get( h, 'CurrentAxes' );
    ch = get( ah, 'Children' );
    %set( ch, 'FontSize', 20 );
    %ah = get( h, 'CurrentAxes' );
    %ch = get( ah, 'Children' );
    %set( ch, 'FontSize', 20 );
    % need to resize the msgbox object to accommodate new FontSizes
    %pos = get( h, 'Position' ); % msgbox current position
    %pos = pos + delta; % change size of msgbox
    %set( msgHandle, 'Position', pos ); % set new position
else
    display('Not selected');
end
% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in PlayButton.
function PlayButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.pausebool==1
    handles.pausebool=0;
    set(handles.songtitle,'String',handles.playlist(handles.count).name(1:length(handles.playlist(handles.count).name)-4));
    handles.player.resume;
else
    if handles.count>length(handles.playlist)
        handles.count=1;
    end
    [y,Fs]=audioread(strcat('Music\',handles.playlist(handles.count).name));
    handles.player=audioplayer(y,Fs);
    set(handles.songtitle,'String',handles.playlist(handles.count).name(1:length(handles.playlist(handles.count).name)-4));
    play(handles.player);
    handles.count=handles.count+1;
end
%guidata(hObject,handles);


% --- Executes on button press in PauseButton.
function PauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to PauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.pausebool=1;
handles.player.pause;
%guidata(hObject,handles)

% --- Executes on button press in SkipButton.
function SkipButton_Callback(hObject, eventdata, handles)
% hObject    handle to SkipButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.player.isplaying
   handles.pausebool=1;
   handles.player.pause;
end
handles.count=handles.count+1;
if handles.count>length(handles.playlist)
    handles.count=1;
end
%disp(handles.playlist);
%disp(handles.count);
[y,Fs]=audioread(strcat('Music\',handles.playlist(handles.count).name));
handles.player=audioplayer(y,Fs);
set(handles.songtitle,'String',handles.playlist(handles.count).name(1:length(handles.playlist(handles.count).name)-4));
play(handles.player);
guidata(hObject,handles)

% --- Executes on button press in scrolltarget.
function scrolltarget_Callback(hObject, eventdata, handles)
% hObject    handle to scrolltarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.sitecounter==length(handles.sites)
    handles.sitecounter=1;
else
    handles.sitecounter=handles.sitecounter+1;
end
handles.lat=handles.sites(handles.sitecounter).lat;
handles.lon=handles.sites(handles.sitecounter).long;
handles.countdowntimer=timeTilTarget(handles.lat,handles.lon);
set(handles.countdown,'String',convertTime(handles.countdowntimer));
set(handles.weather,'String',weather(handles.sites(handles.sitecounter).target_name));
set(handles.destinationtext,'String',handles.sites(handles.sitecounter).target_name);
set(handles.notestext,'String',handles.sites(handles.sitecounter).notes);
set(handles.lenstext,'String',handles.sites(handles.sitecounter).lenses);
targetstr=strcat(num2str(handles.sitecounter),'/',num2str(length(handles.sites)));
set(handles.targetlist,'String',targetstr);
str=getLocalTime(handles.lat,handles.lon);
set(handles.localtime,'String',str);

%Update next target marker
delete(findobj(handles.LilMap,'-depth',1,'Color',[1 0 0]));
p = findobj(handles.LilMap,'-depth',1,'Color',[1 0 1]);
x = p.XData;
y = p.YData;
s = handles.sitecounter;
axes(handles.LilMap)
hold on
plot(x(s),y(s),'+r','MarkerSize',5,'LineWidth',2);
hold off

%Update target in Big Map
p = findobj(handles.BigMap,'-depth',1,'Color',[1 0 0]);
x = str2double(handles.lon);
y = str2double(handles.lat);
set(p,'XData',x,'YData',y,'Marker','+','MarkerSize',10,'LineWidth',2);
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function LilMap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%plotOrbitalPath()
% Hint: place code in OpeningFcn to populate LittleMap


% --- Executes during object creation, after setting all properties.
function BigMap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BigMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate BigMap


%% User functions
%this function updates display (is called every 3 seconds) and updates
%countdown timer
function update_display(hObject,eventdata,hfigure)

handles = guidata(hfigure);
t2=subtractTime(handles.countdown.String,1);
s = strsplit(t2,':');
t = str2double(s(2));
s = str2double(s(3));
if ~rem(s,4)
    [y,x] = getISScoord();
    p = findobj(handles.BigMap,'-depth',1,'Color',[0 1 1]);
    set(p,'XData',x,'YData',y,'Marker','o','MarkerSize',5,'LineWidth',2);
    if ~rem(s,12)
        [x,y] = mercatorProjection(x,y, 773, 599);
        p = findobj(handles.LilMap,'-depth',1,'Color',[0 1 1]);
        set(p,'XData',x,'YData',y,'Marker','o','MarkerSize',5,'LineWidth',2);
        if s==0 && ~rem(t,5)
            [x1,x2,y1,y2] = plotOrbitalPath(y);
             p = findobj(handles.LilMap,'-depth',1,'Color',[1 1 0]);
             set(p(1),'XData',x1,'YData',y1,'LineStyle','--','LineWidth',1.5);
             set(p(2),'XData',x2,'YData',y2,'LineStyle','--','LineWidth',1.5);
             p = findobj(handles.LilMap,'-depth',1,'Color',[0 0 1]);
             set(p(1),'XData',x1,'YData',y1-25);
             set(p(2),'XData',x2,'YData',y2-25);
             set(p(3),'XData',x1,'YData',y1+25);
             set(p(4),'XData',x2,'YData',y2+25);
        end
    end 
end
set(handles.countdown,'String',t2);

function searchbox_Callback(hObject, eventdata, handles)
% hObject    handle to searchbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of searchbox as text
%        str2double(get(hObject,'String')) returns contents of searchbox as a double

% --- Executes during object creation, after setting all properties.
function searchbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to searchbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in searchbutton.
function searchbutton_Callback(hObject, eventdata, handles)
% hObject    handle to searchbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
term=get(handles.searchbox,'String');
if isempty(term)==0
    searchForTerm(term);
end

% --- Executes on button press in takepicture.
function takepicture_Callback(hObject, eventdata, handles)
% hObject    handle to takepicture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.pcount=handles.pcount+1;
w=weather(handles.sites(handles.sitecounter).target_name);
d=handles.sites(handles.sitecounter).target_name;
n=handles.sites(handles.sitecounter).notes;
l=handles.sites(handles.sitecounter).lenses;
texttosave=strcat(w,d,n,l);
texttosave=strrep(texttosave,'\n','');
saveImage(handles.pcount,texttosave);
guidata(hObject, handles);


% --- Executes on button press in refresh.
function refresh_Callback(hObject, eventdata, handles)
% hObject    handle to refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=getLocalTime(handles.lat,handles.lon);
set(handles.localtime,'String',str);
%guidata(hObject,handles);


% --- Executes during object deletion, before destroying properties.
function BigMap_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to BigMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stop(handles.timer)
disp('Thanks for using MASSmagic!')
guidata(hObject, handles);

% --- Executes during object deletion, before destroying properties.
function LilMap_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to LilMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stop(handles.timer)
disp('Thanks for using MASSmagic!')
guidata(hObject, handles);


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
