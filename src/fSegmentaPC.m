
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Utilização da função "pcsegdist()" para segmentar uma nuvem de pontos.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pcThresholded= fSegmentaPC(handles)
clc;

% Para usar o close all é necessário mudar o HandleVisibility do
% painelprincial para "off". Assim, quando for finalizado, antes será necessário
% tornar este parametro novamente para "on" e depois executar close all.
close all;

infoFolder= dir(fullfile(handles.pathReadPC, '*.pcd'));
numPCs= length(infoFolder(not([infoFolder.isdir])));

pc= pcread(handles.PcToRead);
% Filtra o ruído da nuvem de pontos de referência.
% pcDenoised= pcdenoise(pc);

% Efetua um procedimento de filtragem utilizando a distância ecuclidiana
% entre o ponto XYZ e a origem do LiDAR, usa threshold de distânica mínima
% e máxima definidas nas viariáveis:
% - handles.valThresholdMinDistance
% - handles.valThresholdMaxDistance.
pcThresholded= fPcFiltraDistancia(pc, handles.showPcSegmentada, ...
                                  handles.min_X, handles.max_X, ...
                                  handles.min_Y, handles.max_Y, ...
                                  handles.min_Z, handles.max_Z);
 

% Se estiver habilitado salva a PC segmentada:
if (handles.HabSalvarPcSeg && pcThresholded.Count)
    answer = questdlg('Salvar a PC segmentada?', '', 'Sim', 'Não', 'Sim');
    nameFile=handles.file;
    switch answer
        case 'Sim'
                handles.pathSavePC= uigetdir(handles.pathSavePC);
                if ~(handles.pathSavePC)
                    msg= sprintf(' Operação de salvar a PC Segmentada foi cancelada.');
                    figMsg= msgbox(msg);
                    uiwait(figMsg);
                    return; % Sai da função!
                end

                pathSavePC= fullfile(handles.pathSavePC, handles.nameFolderSavePcSeg);
                if (isdir(pathSavePC))
                    % Verifica se já tem arquivos .pcds salvos, se sim será
                    % dada continuidade a numeração:
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
        case 'Não'
                return;
    end
end 
end
