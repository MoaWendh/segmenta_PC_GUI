function fShowPcFiltradaPorDistancia(pcOriginal, pcThreshold, ExibeApenasPcSegmentada)
 
close all;

tamMarker= 150;

%Elemina valores nulos da nuvem de pontos:
numCanais= size(pcOriginal.Location, 1);

for ctCanal=1:numCanais
    numPontos= size(pcOriginal.Location, 2);
    for ctPonto=1:numPontos
        xyz_aux= [pcOriginal.Location(ctCanal, ctPonto, 1) pcOriginal.Location(ctCanal, ctPonto, 2) pcOriginal.Location(ctCanal, ctPonto, 3)];
        if nnz(xyz_aux)>2
            xyz1(ctCanal, ctPonto, :)= xyz_aux;
        else
            xyz1(ctCanal, ctPonto, :)=[ NaN NaN NaN];
        end
    end
end

pcOriginal_aux= pointCloud(xyz1);

%Elemina valores nulos da nuvem de pontos:
numCanais= size(pcThreshold.Location, 1);

for ctCanal=1:numCanais
    numPontos= size(pcThreshold.Location, 2);
    for ctPonto=1:numPontos
        xyz_aux= [pcThreshold.Location(ctCanal, ctPonto, 1) pcThreshold.Location(ctCanal, ctPonto, 2) pcThreshold.Location(ctCanal, ctPonto, 3)];
        if nnz(xyz_aux)>2
            xyz2(ctCanal, ctPonto, :)= xyz_aux;
        else
            xyz2(ctCanal, ctPonto, :)=[ NaN NaN NaN];
        end
    end
end

pcThreshold_aux= pointCloud(xyz2);

if ExibeApenasPcSegmentada
    % Cria um novo mapa de cores para os clusters
    fig= figure;
    pcshow(pcThreshold_aux.Location, 'MarkerSize', tamMarker);
    numPontos= length(pcThreshold_aux.Location); 
    msg= sprintf(' Filtrada PC com %d pontos', numPontos);
    title(msg);
    xlabel('X (m)', 'FontWeight', 'bold');
    ylabel('Y (m)', 'FontWeight', 'bold');
    zlabel('Z (m)', 'FontWeight', 'bold');
    fig.Position= [480, 200, 1750, 790];

    ax= gca;
    ax.XColor = 'k';
    ax.YColor = 'k'; 
    ax.ZColor = 'k';
    ax.FontSize= 22;
    ax.Color = 'w';
   % view(-10, -30);
    
    % Esta função abaixo anula o fundo preto gerado pela função pcshow() do Matlab:
    set(gcf, 'Color', 'w'); % 'w' para branco
else
    % Cria um novo mapa de cores para os clusters
    fig= figure;

    % Exibe a nuvem de pontos segmentada inteira:
    subplot(1,2,1);
    pcshow(pcOriginal_aux.Location);
    numPontos= length(pcOriginal_aux.Location); 
    msg= sprintf('PC original com %d pontos', numPontos);
    title(msg);
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');

    subplot(1,2,2);
    pcshow(pcThreshold_aux.Location);
    numPontos= length(pcThreshold_aux.Location); 
    msg= sprintf(' Filtrada PC com %d pontos', numPontos);
    title(msg);
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
    fig.Position= [-1900, 260, 1500, 710];
end
end