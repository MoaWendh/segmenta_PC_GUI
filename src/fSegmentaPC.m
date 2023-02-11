
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Utiliza��o da fun��o "pcsegdist()" para segmentar uma nuvem de pontos.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles= fSegmentaPC(handles)
clc;

% Para usar o close all � necess�rio mudar o HandleVisibility do
% painelprincial para "off". Assim, quando for finalizado, antes ser� necess�rio
% tornar este parametro novamente para "on" e depois executar close all.
close all;

infoFolder= dir(fullfile(handles.pathReadPC, '*.pcd'));
numPCs= length(infoFolder(not([infoFolder.isdir])));

pc= pcread(handles.PcToRead);
% Filtra o ru�do da nuvem de pontos de refer�ncia.
pcDenoised= pcdenoise(pc);

if (handles.habSegmentaPorThreshold)
    % Efetua um procedimento de filtragem utilizando a dist�ncia ecuclidiana
    % entre o ponto XYZ e a origem do LiDAR, usa threshold de dist�nica m�nima
    % e m�xima definidas nas viari�veis:
    % - handles.valThresholdMinDistance
    % - handles.valThresholdMaxDistance.
    pcThresholded= fPcFiltraDistancia(pcDenoised, handles);
    
    % Se estiver habilitado salva a PC segmentada:
    if (handles.HabSalvarPcSeg && pcThresholded.Count)
        answer = questdlg('Salvar a PC segmentada?', '', 'Sim', 'N�o', 'Redefinir folder para salvar', 'Sim');
        switch answer
            case 'Sim'
                    % Se o path para salvar ainda n�o foi definido ser� aberta
                    % uma tela para escolher o folder:
                    if strcmp(handles.pathSavePC, "")
                        handles.pathSavePC= uigetdir(handles.pathSavePC);
                        if ~(handles.pathSavePC)
                            msg= sprintf(' Opera��o de salvar a PC Segmentada foi cancelada.');
                            figMsg= msgbox(msg);
                            uiwait(figMsg);
                            return; % Sai da fun��o!
                        end;
                    end

                    pathSavePC= fullfile(handles.pathSavePC, handles.nameFolderSavePcSeg);
                    if (isdir(pathSavePC))
                        % Verifica se j� tem arquivos .pcds salvos, se sim ser�
                        % dada continuidade a numera��o:
                        fullPath= fullfile(pathSavePC, '*.pcd');
                        result= dir(fullPath);
                        numFilesPCD= length(result);
                        numFile= numFilesPCD + 1;
                        nameFile= sprintf('%0.4d.pcd',numFile);
                        fullPath= fullfile(pathSavePC, nameFile);
                        pcwrite(pcThresholded, fullPath); 
                    else
                        mkdir(pathSavePC)
                        numFile= 1;
                        nameFile= sprintf('%0.4d.pcd',numFile);
                        fullPath= fullfile(pathSavePC, nameFile);
                        pcwrite(pcThresholded, fullPath); 
                    end

            case 'Redefinir folder para salvar'   
                    handles.pathSavePC= uigetdir(handles.pathSavePC);
                    if ~(handles.pathSavePC)
                        msg= sprintf(' Opera��o de redefini��o do folder foi cancelada.');
                        figMsg= msgbox(msg);
                        uiwait(figMsg);
                        return; % Sai da fun��o!
                    end
                    
                    pathSavePC= fullfile(handles.pathSavePC, handles.nameFolderSavePcSeg);
                    if (isdir(pathSavePC))
                        % Verifica se j� tem arquivos .pcds salvos, se sim ser�
                        % dada continuidade a numera��o:
                        fullPath= fullfile(pathSavePC, '*.pcd');
                        result= dir(fullPath);
                        numFilesPCD= length(result);
                        numFile= numFilesPCD + 1;
                        nameFile= sprintf('%0.4d.pcd',numFile);
                        fullPath= fullfile(pathSavePC, nameFile);
                        pcwrite(pcThresholded, fullPath); 
                    else
                        mkdir(pathSavePC)
                        numFile= 1;
                        nameFile= sprintf('%0.4d.pcd',numFile);
                        fullPath= fullfile(pathSavePC, nameFile);
                        pcwrite(pcThresholded, fullPath); 
                    end
              
            case 'N�o'
                    return;
        end
    end 
else
    % Segmenta a nuvem de pontos em clusters com a fun��o pcsegdist(): 
    [labels, numClusters] = pcsegdist(pcDenoised, handles.valMinDistance, 'NumClusterPoints', [handles.valMinPoints handles.valMaxPoints]);

    % Remove os pontos que n�o tem valor de label v�lido, ou seja =0.
    idxValidPoints = find(labels);

    % Guarda o cluster definidos na vari�vel "idxValidPoints" quem cont�m 
    % os endere�os com os pontos v�lidos:
    labelColorIndex = labels(idxValidPoints);

    % Gera um nuvem de pontos com os valores segmentados:
    pcSegmented = select(pcDenoised, idxValidPoints);
    
    % Gera uma nuvem de pontos para cada cluster:
    for (ctCluster=1:numClusters)
        pcCluster{ctCluster}= select(pcDenoised, labels==ctCluster);
    end
    fprintf(' PC lida cont�m -> %d clusters.\n', numClusters); 

    % Se estiver habilitado chama fun��o para exibir os resultados da segmenta��o:
    if (handles.showPcSegmentada && (numClusters>0)) 
        fShowPcSegmentada(pcCluster, pcSegmented, numClusters, labelColorIndex);
    end
end  
end
