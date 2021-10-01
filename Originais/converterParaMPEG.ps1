param($arquivo, $arquivodestino) # primeira linha

Write-Host "Essse comando ter� como sa�da um arquivo de video mpeg2 compat�vel com a maioria dos players web extra�do diretamente do arquivo .TS"
if ($arquivo -and $arquivodestino){

#    ffmpeg -i $arquivo -c:v libx264 -c:a aac -ac 1 -b:a 96k -af "afftdn,adeclip,adeclick=b=5,acompressor" -movflags +faststart -vf "yadif=1,scale=-2:720" $arquivodestino'.mp4'
 ffmpeg -i $arquivo -c:v libx264 -ac 1 -movflags +faststart -vf "yadif=1,scale=-2:720" $arquivodestino'.mp4'



} else {
Write-Host "Arquivo n�o informado ou destino n�o informado Por favor execute:"
Write-Host "----------------------------------------------"
Write-Host "./converterParaMPEG.ps1 <nome do arquivo de video .TS> <caminho e nome do arquivo destino com extens�o .mp4>"
}
