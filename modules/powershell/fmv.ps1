function FMVVideo {
    param($In, $Out, $Overwrite)

    #Verifica se Arquivo já existe, caso sim não reprocessa
    if (Test-Path -Path $Out'.mp4') {
        Write-Host "Arquivo existente"
    }
    else {

        Write-Host "Extraindo video..."
   
        if ($In -and $Out) {

            ffmpeg -i $In -c:v libx264 -ac 1 -movflags +faststart -vf "yadif=1,scale=-2:720" $Out'.mp4'
        }
        else {

            Write-Host "Arquivo nao informado ou destino nao informado Por favor execute:"
            Write-Host "----------------------------------------------"
            Write-Host "./converterParaMPEG.ps1 <nome do arquivo de video .TS> <caminho e nome do arquivo destino com extensao .mp4>"
        }
    }
}
function FMVAudio {
    param($in, $out, $params)
    
    $output = $out + '.wav'

    $exists = Test-Path -Path $output
    $replace = $params -Like '*-replace*'
    
    if ($replace -or (-not $exists)) {

        $ext = (Get-Item $in).Extension
        $temp = $out.Substring(0, $out.Length - $ext.Length) + '_mono'
    
        ExtractAudio $in $temp
    
        $temp = $temp + '.wav'
        $temp2 = $temp + '_spikeless.wav'
        
        SpikeRemove $temp $temp2
        Remove-Item $temp
    
        EnhanceAudio $temp2 $output
        Remove-Item $temp2
    }

    else {
        Write-Host "Arquivo existente, sem parametro substituir."
        Write-Host "Nada a ser feito."
    }

            

    Write-Host 'Concluido.'
    
}

function FMVData {
    param($in, $out, $params)

    $ext = (Get-Item $in).Extension
    $temp = $out.Substring(0, $out.Length - $ext.Length)

    $output = $out + '.json'

    $exists = Test-Path -Path $output
    $replace = $params -Like '*-replace*'
    
    if ($replace -or (-not $exists)) {

        ExtractData $in $temp
        
        $temp = $temp + '.bin'
        
        ConvertJSON $temp $out
        
        # Remove-Item $temp
    }
    else {
        Write-Host "Arquivo existente, sem parametro substituir."
        Write-Host "Nada a ser feito."
    }

}

function FMVSlice {
    param($InputFilePath, $OutputDirectoryPath, $Params)
    
    # Divide o arquivo enviado ($InputFilePath) na entrada em trechos de voz salvos um diretório temporário através do uso da função SplitAudio.
    # A seguir, aplica para cada um destes trechos, as operações de remoção de pico e melhoria do som contidas na função FMVAudio.
    # Por fim os arquivos tratados são salvos no diretório de saída ($OutputDirectoryPath) e os arquivos temporários apagados.

    #       $InputFilePath: Uma string contendo o caminho para o arquivo de entrada
    # $OutputDirectoryPath: Uma string contendo o caminho onde serão salvos trechos de audio
    #              $Params: Uma string contendo flags de parâmetros que alteram o funcionamento da função.
    #                       Atualmente a única flag disponível para esse método é a -replace.
    
    #            - replace: Se utilizada a função removerá os arquivos gerados anteriormente e prosseguirá a criação de novos.

    # No caso de nenhuma flag ser informada a função ignorará o arquivo de entrada se o diretório de saída já existir.

    $Exists = Test-Path -Path $OutputDirectoryPath
    $Replace = $Params -Like '*-replace*'
    
    if ($Replace -or (-not $Exists)) {

        # Apaga, no caso de existirem arquivos anteriores 
        Remove-Item -LiteralPath $OutputDirectoryPath -Force -Recurse

        # Gera arquivos de trechos de voz
        $Temp = $OutputDirectoryPath + '_temp'        
        SplitAudio $InputFilePath $Temp
       
        # Remove picos do audio e amplifica voz
        $Entrada = $Temp
        $Sobre = '*.wav'
        $Saida = $OutputDirectoryPath   
        Iterator $Entrada $Sobre -Call $function:FMVAudio $Saida

        # Remove diretório que contém os arquivos temporários
        Remove-Item -LiteralPath $Entrada -Force -Recurse

        # Renomeia os arquivos para o valor de saída
        Get-ChildItem -Recurse -Path $Saida -File -Include *.wav | ForEach-Object -Process {
            $NewName = ($_.BaseName).Replace('.wav', '')
            Rename-Item -Path $_.FullName -NewName ($NewName + '.wav')
        }
    }
    else {

        Write-Host "Diretorio existente, sem parametro substituir."
        Write-Host "Nada a ser feito."
    }

    
}
function FMVSTT {
    param($in, $out, $params)

    $ext = (Get-Item $in).Extension
    $out = $out.Substring(0, $out.Length - $ext.Length)

    $output = $out + '.txt'

    $exists = Test-Path -Path $output
    $replace = $params -Like '*-replace*'
    
    if ($replace -or (-not $exists)) {

        ExtractText $in $output
    
    }
    else {
        Write-Host "Arquivo existente, sem parametro substituir."
        Write-Host "Nada a ser feito."
    }

}

function FMVFrames {
    param($In, $Out)

    #Leitura do arquivo de texto com as informações sobre o volume
    $Text = Get-Content $In

    #Transformando as linhas do arquivo em um array
    $Text.GetType() | Format-Table -AutoSize

    #Listando as linhas do arquivo
    #Aplicando substituições para leitura do arquivo de texto
    # $Extension = $Text | ForEach-Object { $_ -replace "max_volume:", "|Max|" } `
    # | ForEach-Object { $_ -replace "dB", "" } `
    # | ForEach-Object { $_ -replace "\s+", "" } `
    # | Where-Object { $_ -notmatch "size" } `
    # | Where-Object { $_ -notmatch "Summary" } `



    foreach ($element in $Text) { 
        $item = $element.split(';')
        $InputFile = $item[0]
        $OutputFile =  $InputFile.Replace("Y:\","Z:\TS_frames\")
        $Start = [double]$item[1]
        $End = [double]$item[2]

        $OutputFilePath = $OutputFile.Replace($OutputFile.Split('\')[-1],"")
        
        if (-Not (Test-Path -Path $OutputFilePath)) {
            Write-Host "Criando diretorio: $($OutputFilePath)"
            New-Item -ItemType Directory -Path $OutputFilePath
        }
        # O nome do arquivo contido na entrada deve possuir os separadores # indicando inicio e fim do trecho, ex.: "LTSMANIQ1_T0218_T0061#637.88#640.11.wav"
    

        # $Padding = 0            #Tempo extra adicionado ao início e ao fim do trecho específicado
        $ImagesPerSecond = 1 / 5    #Quantidade de imagens por segundo


        # $Start = [double]$NomeArquivo.Split('#')[1] - $Padding
        # $End = [double]$NomeArquivo.Split('#')[2].Replace('.wav', '') + $Padding
        $Duration = $End - $Start
    
        # https://stackoverflow.com/questions/21842175/convert-seconds-to-hhmmss-fff-format-in-powershell  
        # $StartTime = ("{0:hh\:mm\:ss\.ff}" -F [Timespan]::FromSeconds($Start))

        # Tive que usar um for normal para manter a rastreabilidade das imagens
        For ($i = 0; $i -le [Math]::Ceiling($Duration * $ImagesPerSecond); $i++) {
            $CurrentTime = "{0:f2}" -f ($Start + $i / $ImagesPerSecond) -Replace ',', '.'
            ffmpeg -ss $CurrentTime -i $InputFile -vf "yadif=2" -frames:v 1 -qscale:v 1 -shortest "$($OutputFile)#$($CurrentTime).jpg" -y
        }
    }
}