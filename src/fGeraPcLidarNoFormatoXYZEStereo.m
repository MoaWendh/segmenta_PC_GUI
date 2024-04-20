function fGeraPcLidarNoFormatoXYZEStereo(file, path, ConvertePcParaMilimetros)

if ~iscell(file)
    numPCs= 1;
else
    numPCs= size(file,2);
end

if ConvertePcParaMilimetros
    k= 1000;
else
    k= 1;
end

% Defineo path onde as PCs serão salvas:
pathToSave= uigetdir(path); 


for ctPc=1:numPCs
    if numPCs==1
        fullFileToRead= fullfile(path, file);
    else
        fullFileToRead= fullfile(path, file{ctPc});
    end
    % Carrega a pc:
    pc= pcread(fullFileToRead);
    
    numCanais= size(pc.Location, 1);
    ctPontoValido= 0;
    for ctCanal=1:numCanais
        numPontos= size(pc.Location, 2);
        for ctPonto=1:numPontos
            if nnz(pc.Location(ctCanal, ctPonto,:))
                ctPontoValido= ctPontoValido + 1;
                % Efetua a inversão das coordenadas Z e Y:
                xyz(ctPontoValido,:)= [pc.Location(ctCanal, ctPonto, 1) pc.Location(ctCanal, ctPonto, 3) pc.Location(ctCanal, ctPonto, 2)]*k;
            end
        end       
    end
    
    % Se esta PC tiver dado válido ela será salva:
    if ctPontoValido
        nameFile= sprintf('pcLidar_%.2d.txt',ctPc);
        namePcToSave= fullfile(pathToSave, nameFile);
        fid= fopen(namePcToSave, 'w');
        if fid>0
            fprintf(fid, '%.4f\t%.4f\t%.4f\n',xyz');
            fclose(fid);
        else
            msg= sprintf('Não foi possível salvar arquivo .txt. Código fid= %d ', fid);
            msgbox(msg, 'Error', 'error');
            return;
        end
    end    
end
end