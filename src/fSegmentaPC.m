
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Utiliza��o da fun��o "pcsegdist()" para segmentar uma nuvem de pontos.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pcThresholded= fSegmentaPC(handles)
clc;

% Para usar o close all � necess�rio mudar o HandleVisibility do
% painelprincial para "off". Assim, quando for finalizado, antes ser� necess�rio
% tornar este parametro novamente para "on" e depois executar close all.
close all;

infoFolder= dir(fullfile(handles.pathReadPC, '*.pcd'));
numPCs= length(infoFolder(not([infoFolder.isdir])));

pc= pcread(handles.PcToRead);
% Filtra o ru�do da nuvem de pontos de refer�ncia.
% pcDenoised= pcdenoise(pc);

% Efetua um procedimento de filtragem utilizando a dist�ncia ecuclidiana
% entre o ponto XYZ e a origem do LiDAR, usa threshold de dist�nica m�nima
% e m�xima definidas nas viari�veis:
% - handles.valThresholdMinDistance
% - handles.valThresholdMaxDistance.
pcThresholded= fPcFiltraDistancia(pc, handles.showPcSegmentada, ...
                                  handles.min_X, handles.max_X, ...
                                  handles.min_Y, handles.max_Y, ...
                                  handles.min_Z, handles.max_Z);
 

% Se estiver habilitado salva a PC segmentada:
if (handles.HabSalvarPcSeg && pcThresholded.Count)
    answer = questdlg('Salvar a PC segmentada?', '', 'Sim', 'N�o', 'Sim');
    nameFile=handles.file;
    switch answer
        case 'Sim'
                handles.pathSavePC= uigetdir(handles.pathSavePC);
                if ~(handles.pathSavePC)
                    msg= sprintf(' Opera��o de salvar a PC Segmentada foi cancelada.');
                    figMsg= msgbox(msg);
                    uiwait(figMsg);
                    return; % Sai da fun��o!
                end

                pathSavePC= fullfile(handles.pathSavePC, handles.nameFolderSavePcSeg);
                if (isdir(pathSavePC))
                    % Verifica se j� tem arquivos .pcds salvos, se sim ser�
                    % dada continuidade a numera��o:
                    % fullPath= fullfile(pathSavePC, '*.pcd');
                    % result= dir(fullPath);
                    % numFilesPCD= length(result);
                    % numFile= numFilesPCD + 1;
                    % nameFile= sprintf('%0.4d.pcd',numFile);
                    fullPath= fullfile(pathSavePC, nameFile);
                    pcwrite(pcThresholded, fullPath); 
                else
                    mkdir(pathSavePC)
                    %numFile= 1;
                    %nameFile= sprintf('%0.4d.pcd',numFile);
                    fullPath= fullfile(pathSavePC, nameFile);
                    pcwrite(pcThresholded, fullPath); 
                end
        case 'N�o'
                return;
    end
end 
end
