function ExtractData {
    param($arquivo, $arquivodestino) # primeira linha

    Write-Host "Extraindo binario..."
    # Write-Host "Esse comando tera como saida um arquivo binario com extensao bin extraido do arquivo diretamente do arquivo .TS compativel com STANAG 4609 / MISB 0601 e MISB 0102 "
    if ($arquivo -and $arquivodestino) {
        ffmpeg -i $arquivo -map d:0 -f data $arquivodestino'.bin' -y 2>&1 | Select-String -Pattern 'time=(.*?)bit.*?speed=([\s0-9]+)x' -AllMatches | ForEach-Object { Write-Progress 'Extraindo binario: ' $_ }
    }
    else {
        Write-Host "Arquivo nao informado. Por favor execute:"
        Write-Host "----------------------------------------------"
        Write-Host "./extrairKLVBinario.ps1 <nome do arquivo de video .TS compativel com STANAG aqui> <caminho do arquivo destino e nome do arquivo>"
    }
}

function ConvertJSON {
    param($arquivo, $arquivodestino) # primeira linha
    
    Write-Host "Convertendo json..."
    # Write-Host "Esse comando terá como saída um arquivo JSON com todos os dados extraidos do arquivo binário .TS"
    if ($arquivo -and $arquivodestino) {
        # python .\metadataToJsonDistinctLatLongValueOnly.py ($arquivo + '.bin') $arquivodestino
        python .\modules\python\klv2json.py $($arquivo) $($arquivodestino)
        #python C:\ScriptsPowerShell\metadataToJson.py $arquivo $arquivodestino
    } 
    else {
        Write-Host "Arquivo não informado ou destino não informado. Por favor execute:"
        Write-Host "----------------------------------------------"
        Write-Host ".\lerMetadados.ps1 <nome do arquivo binario aqui> <nome do arquivo destino aqui>"
    }
}