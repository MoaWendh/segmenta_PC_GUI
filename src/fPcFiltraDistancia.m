%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/12/2022
% Filtra nuvem de pontos considerando a distância euclidiana entre o LiDAR
% e ponto medido, ou seja, a norma do ponto XYZ.
% Os parâmetros de entrada, Threshold, são distância mínima e máxima do LiDAR
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pcThresholded= fPcFiltraDistancia(pc, ...
                                           valMin_X, valMax_X, ...
                                           valMin_Y, valMax_Y, ...
                                           valMin_Z, valMax_Z)
clc;
pcSegmentada= 0;

% Testa a dimensão da PC para verificar se ela tem mais de um canal:
dimensaoPC= size(pc.Location);
lengthDims= length(dimensaoPC);

% Caso a dimensão seja 1, o tratamenteo da nuvem de pontos é bem diferente:
if lengthDims<3
    ctPontoFiltrado= 0;
    numPontos= dimensaoPC(1);
    for (ctPonto=1:numPontos)    
        if (pc.Location(ctPonto,1)>valMin_X && pc.Location(ctPonto,1)<valMax_X && ...
            pc.Location(ctPonto,2)>valMin_Y && pc.Location(ctPonto,2)<valMax_Y && ...
            pc.Location(ctPonto,3)>valMin_Z && pc.Location(ctPonto,3)<valMax_Z)

            ctPontoFiltrado= ctPontoFiltrado + 1;
            location(ctPontoFiltrado,:)= pc.Location(ctPonto,:);
            intensity(ctPontoFiltrado,:)= pc.Intensity(ctPonto,:);
            pcSegmentada=1;
        end
    end
else
    % Nesta caso, além de varrer os pontos, os canais também devem ser
    % varridos, isto possibilita salvar a PC com os mesmso nº de canais
    % originais.
    numCanais= dimensaoPC(1);
    for ctCanal=1:numCanais
        ctPontoFiltrado= 0;
        numPontos= dimensaoPC(2); 
        for (ctPonto=1:numPontos)
            % Testa para ver se o pontos está dentro da região, volume, definido para X, Y e Z: 
            if (pc.Location(ctCanal, ctPonto, 1)>valMin_X && pc.Location(ctCanal, ctPonto, 1)<valMax_X && ...
                pc.Location(ctCanal, ctPonto, 2)>valMin_Y && pc.Location(ctCanal, ctPonto, 2)<valMax_Y && ...
                pc.Location(ctCanal, ctPonto, 3)>valMin_Z && pc.Location(ctCanal, ctPonto, 3)<valMax_Z)

                ctPontoFiltrado= ctPontoFiltrado + 1;
                location(ctCanal, ctPontoFiltrado,:)= pc.Location(ctCanal, ctPonto, :);
                intensity(ctCanal, ctPontoFiltrado)= pc.Intensity(ctCanal, ctPonto);
                pcSegmentada=1;
            end
        end
        if ctPontoFiltrado==0
            % Caso o canal não tenha valor válido, será inserido o valor
            % zero, para manter o canal quando este for salvo:
            location(ctCanal, 1,:)= [0 0 0]'; 
            intensity(ctCanal, 1)= 0;
        end
    end   
end

% testa para ver se pelo menos um canal foi filtrado:
if pcSegmentada>0
    pcThresholded= pointCloud(location, 'Intensity', intensity);
    msg= sprintf('PC segmentada ok!');
    figMsg= msgbox(msg);
    uiwait(figMsg);   
else
    msg= sprintf('Não foram detectados pontos com esses parâmetro: \n Verifica os thresholds máx. e mín.');
    figMsg= msgbox(msg);
    uiwait(figMsg);
    pcThresholded.Count= 0;
end
end
