function path= fSalvaPCFormatoPcd(pc, path, nameFolder, nameFile)

path= uigetdir(path);
nameFile= nameFile;

if ~(path)
    msg= sprintf(' Operação de salvar a PC Segmentada foi cancelada.');
    figMsg= msgbox(msg);
    uiwait(figMsg);
    return; 
end

pathSavePC= fullfile(path, nameFolder);

if ~(isdir(pathSavePC))
    mkdir(pathSavePC);
end

fullPath= fullfile(pathSavePC, nameFile);
pcwrite(pc, fullPath); 
end