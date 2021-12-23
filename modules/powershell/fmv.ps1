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
        
        Remove-Item $temp
    }
    else {
        Write-Host "Arquivo existente, sem parametro substituir."
        Write-Host "Nada a ser feito."
    }

}

function FMVSTT {
    param($in, $out)
    
    $ext = (Get-Item $in).Extension
    $temp = $out.Substring(0, $out.Length - $ext.Length) 

    ExtractAudio $in $temp

    $temp = $temp + '.wav'

    SplitAudio $temp ($out + '_mono')
    
    Remove-Item $temp
    
    $Entrada = $out + '_mono'
    $Sobre = '*.wav'
    $Saida = $out
   
    Iterator $Entrada $Sobre -Call $function:FMVAudio $Saida

    Remove-Item -LiteralPath $Entrada -Force -Recurse

    Get-ChildItem -Recurse -Path $Saida -File -Include *.wav | ForEach-Object -Process {
        $NewName = ($_.BaseName).Replace('.wav', '')
        Rename-Item -Path $_.FullName -NewName ($NewName + '.wav')
    }


    
}