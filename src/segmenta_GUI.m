function varargout = segmenta_GUI(varargin)
% SEGMENTA_GUI MATLAB code for segmenta_GUI.fig
%      SEGMENTA_GUI, by itself, creates a new SEGMENTA_GUI or raises the existing
%      singleton*.
%
%      H = SEGMENTA_GUI returns the handle to a new SEGMENTA_GUI or the handle to
%      the existing singleton*.
%
%      SEGMENTA_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGMENTA_GUI.M with the given input arguments.
%
%      SEGMENTA_GUI('Property','Value',...) creates a new SEGMENTA_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before segmenta_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to segmenta_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help segmenta_GUI

% Last Modified by GUIDE v2.5 18-Apr-2024 10:57:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @segmenta_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @segmenta_GUI_OutputFcn, ...
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


% --- Executes just before segmenta_GUI is made visible.
function segmenta_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to segmenta_GUI (see VARARGIN)

% ********************* Parâmetros gerais editáveis:  *********************
% 
% Seleciona a PC que será lida no formato ".pcd"
handles.PcToRead= 'D:\Moacir\ensaios';

% Seleciona o path onde a PC segmantada será salva:
handles.pathBase= 'D:\Moacir\ensaios';
handles.pathSavePC= 'D:\Moacir\ensaios';
handles.pathReadPC= handles.pathBase;
handles.nameFolderSavePcSeg= 'segmentada'; 

%
% Parâmetros para segmentação das PCs para definir o ROI do plano, esses 
% parâmetros são usados na função pcsegdist().
% handles.valMinPoints= str2double(handles.txtNumMinPontosPorCluster.String); %500;
% handles.valMaxPoints= str2double(handles.txtNumMaxPontosPorCluster.String); %1500;


%Se "handles.habFunction_SegmentaLidarData" estiver el nivel alto será habilitada
% a função "segmentaLidarData()", caso contrário serpa usada a função
% "pcsegdist".

handles.extPC= "pcd";


% Rotina para fechar todas as figuras aberrtas no Matalab:
%n= length(figure);
%for (i=1:n)
 %   close(figure i);
%end


%**************************************************************************

% Choose default command line output for segmenta_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes segmenta_GUI wait for user response (see UIRESUME)
% uiwait(handles.panelMain);


% --- Outputs from this function are returned to the command line.
function varargout = segmenta_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btPathReadPC.
function btPathReadPC_Callback(hObject, eventdata, handles)
% hObject    handle to btPathReadPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path= fullfile(handles.pathBase,'*.pcd');
[handles.file, handles.path] = uigetfile(path);
handles.PcToRead= fullfile(handles.path, handles.file);
handles.pathReadPC= handles.path;

if handles.file
    handles.pathBase= handles.path;
    handles.btSegmentar.Enable= 'on';
else
    msg= sprintf(' Path de leitura da PC indefinido. \n Para liberar a segmentação defina o path.');
    figMsg= msgbox(msg);
    uiwait(figMsg);
    
    handles.btSegmentar.Enable= 'off';
end

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in btSair.
function btSair_Callback(hObject, eventdata, handles)
% hObject    handle to btSair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.panelMain.HandleVisibility= 'on';
close all;
clc;
clear;


% --- Executes on button press in btSegmentar.
function btSegmentar_Callback(hObject, eventdata, handles)
% hObject    handle to btSegmentar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles= fSegmentaPC(handles);

% Para usar o close all é necessário mudar o HandleVisibility do
% painelprincial para "off". Assim, quando for finalizado, antes será necessário
% tornar este parametro novamente para "on" e depois executar close all.
close all;

infoFolder= dir(fullfile(handles.pathReadPC, '*.pcd'));
numPCs= length(infoFolder(not([infoFolder.isdir])));

handles.pcOriginal= pcread(handles.PcToRead);
% Filtra o ruído da nuvem de pontos de referência.
% pcDenoised= pcdenoise(pc);

% Efetua um procedimento de filtragem utilizando a distância ecuclidiana
% entre o ponto XYZ e a origem do LiDAR, usa threshold de distânica mínima
% e máxima definidas nas viariáveis:
% - handles.valThresholdMinDistance
% - handles.valThresholdMaxDistance.
handles.pcThresholded= fPcFiltraDistancia(handles.pcOriginal, ...
                                          handles.min_X, handles.max_X, ...
                                          handles.min_Y, handles.max_Y, ...
                                          handles.min_Z, handles.max_Z);

handles.pbSalvaPcFormatoPcd.Enable= 'on';
handles.pbShowPcSegmentada.Enable= 'on';
handles.pbSalvaPcFormatoTxt.Enable= 'on';

% Update handles structure
guidata(hObject, handles);



function txtDistanciaMinima_Callback(hObject, eventdata, handles)
% hObject    handle to txtDistanciaMinima (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtDistanciaMinima as text
%        str2double(get(hObject,'String')) returns contents of txtDistanciaMinima as a double


% --- Executes during object creation, after setting all properties.
function txtDistanciaMinima_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtDistanciaMinima (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes when panelMain is resized.
function panelMain_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to panelMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function btPathReadPC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to btPathReadPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Abre janela para escolher as PC a serem rotacionadas:
path= fullfile(handles.pathBase,'*.pcd');
[files pathBase]= uigetfile(path,'Selecione uma PC para Visualização.');
fullPathPC= fullfile(pathBase, files);

if files
    handles.pathBase= pathBase;
    % Faz a leitura da PC:
    pc= pcread(fullPathPC);

    % Exine a PC lida:
    figure; 
    pcshow(pc.Location);

    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
end

% Update handles structure
guidata(hObject, handles);


function editDistMinX_Callback(hObject, eventdata, handles)
% hObject    handle to editDistMinX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDistMinX as text
%        str2double(get(hObject,'String')) returns contents of editDistMinX as a double

handles.min_X= str2num(hObject.String);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editDistMinX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDistMinX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

handles.min_X= str2num(hObject.String);

% Update handles structure
guidata(hObject, handles);



function editDistMaxX_Callback(hObject, eventdata, handles)
% hObject    handle to editDistMaxX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDistMaxX as text
%        str2double(get(hObject,'String')) returns contents of editDistMaxX as a double

handles.max_X= str2num(hObject.String);

% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function editDistMaxX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDistMaxX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

handles.max_X= str2num(hObject.String);

% Update handles structure
guidata(hObject, handles);



function editDistMinY_Callback(hObject, eventdata, handles)
% hObject    handle to editDistMinY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDistMinY as text
%        str2double(get(hObject,'String')) returns contents of editDistMinY as a double

handles.min_Y= str2num(hObject.String);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editDistMinY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDistMinY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

handles.min_Y= str2num(hObject.String);

% Update handles structure
guidata(hObject, handles);


function editDistMaxY_Callback(hObject, eventdata, handles)
% hObject    handle to editDistMaxY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDistMaxY as text
%        str2double(get(hObject,'String')) returns contents of editDistMaxY as a double

handles.max_Y= str2num(hObject.String);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editDistMaxY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDistMaxY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

handles.max_Y= str2num(hObject.String);

% Update handles structure
guidata(hObject, handles);



function editDistMinZ_Callback(hObject, eventdata, handles)
% hObject    handle to editDistMinZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDistMinZ as text
%        str2double(get(hObject,'String')) returns contents of editDistMinZ as a double

handles.min_Z= str2num(hObject.String);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editDistMinZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDistMinZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

handles.min_Z= str2num(hObject.String);

% Update handles structure
guidata(hObject, handles);


function editDistMaxZ_Callback(hObject, eventdata, handles)
% hObject    handle to editDistMaxZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDistMaxZ as text
%        str2double(get(hObject,'String')) returns contents of editDistMaxZ as a double

handles.max_Z= str2num(hObject.String);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editDistMaxZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDistMaxZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

handles.max_Z= str2num(hObject.String);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function statictxtThresoldMinDistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to statictxtThresoldMinDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pbSalvaPcFormatoPcd.
function pbSalvaPcFormatoPcd_Callback(hObject, eventdata, handles)
% hObject    handle to pbSalvaPcFormatoPcd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.pathSavePC= fSalvaPCFormatoPcd(handles.pcThresholded, handles.pathSavePC, handles.nameFolderSavePcSeg, handles.file);

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in pbShowPcSegmentada.
function pbShowPcSegmentada_Callback(hObject, eventdata, handles)
% hObject    handle to pbShowPcSegmentada (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fShowPcFiltradaPorDistancia(handles.pcOriginal, handles.pcThresholded);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pbSalvaPcFormatoTxt.
function pbSalvaPcFormatoTxt_Callback(hObject, eventdata, handles)
% hObject    handle to pbSalvaPcFormatoTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.pathSavePC= fSalvaPCFormatoTxt(handles.pcThresholded, handles.pathSavePC, handles.nameFolderSavePcSeg, handles.file);

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in pbExibirPCTxt.
function pbExibirPCTxt_Callback(hObject, eventdata, handles)
% hObject    handle to pbExibirPCTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close all;


if handles.habExibirDuasPCs 
    path= fullfile(handles.pathReadPC,'*.txt');
    [handles.file, handles.path] = uigetfile(path);
    if ~handles.path
        msg= sprintf('Escolha do arquivo foi cancelada!');
        msgbox(msg,'','warn');
        return;
    end
    handles.PcToRead= fullfile(handles.path, handles.file);
    pc1= load(handles.PcToRead);
    
    [handles.file, handles.path] = uigetfile(path);
    if ~handles.path
        msg= sprintf('Escolha do arquivo foi cancelada!');
        msgbox(msg,'','warn');
        return;
    end
    handles.PcToRead= fullfile(handles.path, handles.file);
    pc2= load(handles.PcToRead);
    
    % Plota as PCs:
    fig= figure;
    fig.Position= [100, 300, 1200, 1000];
    plot3(pc1(:,1),pc1(:,2),pc1(:,3),'or');
    hold on;
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    axis equal;
    grid on;
    plot3(pc2(:,1),pc2(:,2),pc2(:,3),'.b');
else
    path= fullfile(handles.pathReadPC,'*.txt');
    [handles.file, handles.path] = uigetfile(path);
    if ~handles.path
        msg= sprintf('Escolha do arquivo foi cancelada!');
        msgbox(msg,'','warn');
        return;
    end 
    handles.PcToRead= fullfile(handles.path, handles.file);
    pc1= load(handles.PcToRead);
    
    % Plota as PCs:
    fig= figure;
    fig.Position= [100, 300, 1200, 1000];
    plot3(pc1(:,1),pc1(:,2),pc1(:,3),'.r');
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    axis equal;
    grid on;
end

handles.pathReadPC= handles.path;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2

handles.habExibirDuasPCs= hObject.Value;

% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function radiobutton2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

handles.habExibirDuasPCs= hObject.Value;

% Update handles structure
guidata(hObject, handles);
