function fShowPcFiltradaPorDistancia(pcOriginal, pcThreshold)
 
close all;

% Cria um novo mapa de cores para os clusters
fig= figure;

% Exibe a nuvem de pontos segmentada inteira:
subplot(1,2,1);
pcshow(pcOriginal.Location);
numPontos= length(pcOriginal.Location); 
msg= sprintf('PC original com %d pontos', numPontos);
title(msg);
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');

subplot(1,2,2);
pcshow(pcThreshold.Location);
numPontos= length(pcThreshold.Location); 
msg= sprintf(' Filtrada PC com %d pontos', numPontos);
title(msg);
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
fig.Position= [100, 200, 1500, 1100];

end