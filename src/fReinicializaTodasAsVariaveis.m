function handles= fReinicializaTodasAsVariaveis(handles)

% Uma forma segura de reinicialiar as variáveis é eliminar o seu campo 
% da variável global handles. Conforme abaixo:
if isfield(handles, 'PcToRead')
    handles= rmfield(handles, 'PcToRead');
end

if isfield(handles, 'pcOriginal')
    handles= rmfield(handles, 'pcOriginal');
end

handles.pbSalvaPcFormatoPcd.Enable= 'off';
handles.pbShowPcSegmentada.Enable= 'off';
handles.pbSalvaPcFormatoTxt.Enable= 'off';
end