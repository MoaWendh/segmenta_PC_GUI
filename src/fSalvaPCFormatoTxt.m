function path= fSalvaPCFormatoTxt(pc, path, nameFolder, nameFile)

path= uigetdir(path);


if ~(path)
    msg= sprintf(' Operação de salvar a PC Segmentada foi cancelada.');
    figMsg= msgbox(msg);
    uiwait(figMsg);
    return; 
end

pathSavePC= fullfile(path, nameFolder);

numCanais= size(pc.Location,1);
ctPontoValido= 0;
for ctCanal=1:numCanais
    numPontos= size(pc.Location(ctCanal,:,:),2);
    for ctPonto=1:numPontos 
        if nnz(pc.Location(ctCanal,ctPonto,:))
            ctPontoValido= ctPontoValido + 1;
            % Salva em mm:
            xyz(ctPontoValido,:)= [pc.Location(ctCanal,ctPonto,1) pc.Location(ctCanal,ctPonto,3) pc.Location(ctCanal,ctPonto,2)]'*1000; 
        end
    end   
end

numberFile= nameFile(1:4);
nameFileTxt= sprintf('%s%s',numberFile,'.txt');
fileName= fullfile(pathSavePC,nameFileTxt);

if ~isfolder(pathSavePC)
    mkdir(pathSavePC);
end
    
fileID= fopen(fileName,'wt');
if fileID<0
    msg=sprintf('Não foi possível abrir o aquivo %s - Código de Erro= %d ', fileName, fileID);
    waitKey= msgbox(msg,'Error','error', 'modal');
    uiwait(waitKey);
    return;
else    
    fprintf(fileID,'%.4f\t%.4f\t%.4f\n',xyz');
    fclose(fileID);
end

end