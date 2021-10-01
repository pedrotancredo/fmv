param($arquivo, $arquivodestino) # primeira linha

Write-Host "Essse comando ter� como sa�da um arquivo binario com extens�o bin extra�do do arquivo diretamente do arquivo .TS compativel com STANAG 4609 / MISB 0601 e MISB 0102 "
if ($arquivo -and $arquivodestino){
ffmpeg -i $arquivo -map d:0 -f data $arquivodestino'.bin'
} else {
Write-Host "Arquivo n�o informado. Por favor execute:"
Write-Host "----------------------------------------------"
Write-Host "./extrairKLVBinario.ps1 <nome do arquivo de video .TS compativel com STANAG aqui> <caminho do arquivo destino e nome do arquivo>"
}