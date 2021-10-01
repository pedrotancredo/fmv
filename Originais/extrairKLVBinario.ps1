param($arquivo, $arquivodestino) # primeira linha

Write-Host "Essse comando terá como saída um arquivo binario com extensão bin extraído do arquivo diretamente do arquivo .TS compativel com STANAG 4609 / MISB 0601 e MISB 0102 "
if ($arquivo -and $arquivodestino){
ffmpeg -i $arquivo -map d:0 -f data $arquivodestino'.bin'
} else {
Write-Host "Arquivo não informado. Por favor execute:"
Write-Host "----------------------------------------------"
Write-Host "./extrairKLVBinario.ps1 <nome do arquivo de video .TS compativel com STANAG aqui> <caminho do arquivo destino e nome do arquivo>"
}