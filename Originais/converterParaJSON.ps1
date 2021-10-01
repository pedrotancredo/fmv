param($arquivo,$arquivodestino) # primeira linha

Write-Host "Essse comando terá como saída um arquivo JSON com todos os dados extraidos do arquivo binário .TS"
if ($arquivo -and $arquivodestino){
python C:\ScriptsPowerShell\metadataToJsonDistinctLatLongValueOnly.py $arquivo $arquivodestino
#python C:\ScriptsPowerShell\metadataToJson.py $arquivo $arquivodestino
} else {
Write-Host "Arquivo não informado ou destino não informado. Por favor execute:"
Write-Host "----------------------------------------------"
Write-Host ".\lerMetadados.ps1 <nome do arquivo binario aqui> <nome do arquivo destino aqui>"
}