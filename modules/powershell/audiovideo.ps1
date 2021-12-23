function ExtractAudio {

    param($in, $out, $params)

    Write-Host "Extraindo audio..."

    if (Test-Path -Path $in -PathType Leaf) {
        # $dir = (Get-Item $in).DirectoryName
        # $base = (Get-Item $in).Basename
        # $file = $dir + '\' + (Get-Item $in).Basename
        # $ext = (Get-Item $in).Extension
        
        # https://stackoverflow.com/questions/33913878/how-to-get-the-captured-groups-from-select-string
        # Multiline com Duration /(?s)Duration:\s*(.*?),.*time=(.*?)\s*bit.*?speed=\s*([0-9]+)x/gm

        ffmpeg -i $in -vn -ac 1 $out'.wav' -y 2>&1 | Select-String -Pattern 'time=(.*?)bit.*?speed=([\s0-9]+)x' -AllMatches | ForEach-Object { Write-Progress 'Extraindo audio: ' $_ }
    }
}
function SpikeRemove {
    
    param($in, $out)

    Write-Host "Removendo picos..."       
    
    if (Test-Path -Path $in -PathType Leaf) {
        
        # $file = (Get-Item $in).DirectoryName + '\' + (Get-Item $in).Basename
        $temp = $out.Substring(0, $out.Length - $ext.Length) 
        $file = ForceResolvePath($temp)
        $ext = (Get-Item $in).Extension
        $outfile = ForceResolvePath $out
            
        #Cria um arquivo temporário para análise dos picos utilizando lowpass
        $lowpass = 20
        ffmpeg -i $in -af "lowpass=f=$($lowpass)" $file'_lowpass'$ext -y
        
        #Análise da sonoridade do arquivo lowpass
        ffmpeg -i $file'_lowpass'$ext -hide_banner -nostats -af 'loudnorm=I=-16:TP=-1.5:LRA=11:print_format=summary' -f null - 2>$file'_lowpass.txt' | Format -y 

        #Leitura do arquivo de texto com a sonoridade do arquivo lowpass
        $Text = Get-Content $file'_lowpass.txt'

        #Transformando as linhas do arquivo em um array 
        $Text.GetType() | Format-Table -AutoSize

        #Listando as linhas do arquivo
        #Aplicando substituições para leitura do arquivo de texto
        $Extension = $Text | ForEach-Object { $_ -replace ":", "|" } `
        | ForEach-Object { $_ -replace "dBTP", "|" } `
        | ForEach-Object { $_ -replace "\s+", "" } `
        | Where-Object { $_ -notmatch "size" } `
        | Where-Object { $_ -notmatch "Summary" } `
        
        foreach ($element in $Extension) {
        
            $item = $element
            $item = $item.split('|');
                
            if ($item.count -eq 3 -and $item[0] -eq "InputTruePeak") {
                $InputTruePeak = $item[1]
            }
        }
            
        #Amplificando o sinal da saída para detectação dos picos
        $Boost = 15;
        $InputTruePeak = $Boost - $InputTruePeak
        ffmpeg -i $file'_lowpass'$ext -af "volume=$($InputTruePeak)dB" $file'_lowpass_boost'$ext -y
            
        #Gerando mapa para remoção de ruidos a partir da leitura dos picos na saída do Extension EBU R128
        ffmpeg -i $file'_lowpass_boost'$ext  -hide_banner -nostats -filter_complex ebur128="peak=+true" -f null - 2> $file'_ebur128.txt' | Format -y

        #Lendo arquivo de saída da EBU R128
        $Text = Get-Content $file'_ebur128.txt'
        
        #Transformando as linhas do arquivo em um array 
        $Text.GetType() | Format-Table -AutoSize
        
        #Listando as linhas do arquivo
        $Extension = $Text | ForEach-Object { $_ -replace "t:", "|" } `
        | ForEach-Object { $_ -replace "TARGE", "" } `
        | ForEach-Object { $_ -replace "dBFS", "" } `
        | ForEach-Object { $_ -replace "FTPK:", "|" } `
        | ForEach-Object { $_ -replace "TPK:", "|" } `
        | ForEach-Object { $_ -replace "LUFS", "" } `
        | ForEach-Object { $_ -replace "LU", "" } `
        | ForEach-Object { $_ -replace "M:", "|" } `
        | ForEach-Object { $_ -replace "I:", "|" } `
        | ForEach-Object { $_ -replace "S:", "|" } `
        | ForEach-Object { $_ -replace "LRA:", "|" } `
        | ForEach-Object { $_ -replace "-inf", "-80" } `
        | ForEach-Object { $_ -replace "\s+", "" } `
        | Where-Object { $_ -notmatch "size" } `
        | Where-Object { $_ -notmatch "Summary" } `


        ###compor linha de comando do ffmpeg para remoção do ruido considerando deltaT atualmente 0.1 segundos
        # sintaxe: volume=enable='between(t,<tempo> - deltaT,<tempo> + deltaT)':volume=0
        # $aFTPK = @();
        $aPeakTime = @();
        # $i=0;
        
        foreach ($element in $Extension) { 
        
            $item = $element	
            $item = $item.split('|');
            if ($item.count -eq 9) {
                if ([double]$item[7] -eq 0) {
                    $aPeakTime += $item[1]
                    $p++
                }                
            }
        }
        #Write-Host "Total de Elementos: $($i)."
        if ($aPeakTime.Count -ne 0 ) {

            # $Clip=""
            # For ($t=0; $t -lt $i - 0 ; $t++) {  
            #     if([double]$aFTPK[$t] -eq 0){
                    
            #         #$tCenter = [double]$aTime[$t] 
            #         $p++
            #         $tLeft = [double]$aPeakTime[$t] - 0.15
            #         $tRight = [double]$aPeakTime[$t] + 0.15
            #         $Clip+="volume=enable='between(t,$([double]($tLeft)),$([double]$tRight))':volume=0"
            #     }
            # }
            
            # Write-Host "------------------------------------------------------------"
            # Write-Host "Foram encotrados: $($p) picos."
            # $temp = $clip
            # $temp = $temp.Replace("0vo","0|vo")
            # $temp = $temp.Split("|")
            # Write-Host "------------------------------------------------------------"
            # For($i=0 ; $i -lt $temp.Count ; $i++){
            #     Write-Host "Pico $($i+1): $($temp[$i])"
            # }
            # Write-Host "------------------------------------------------------------" 
            
            $stepsize = 300
            $numofsteps = [math]::floor([double]($p / $stepsize))
            $laststep = $p % $stepsize
            $temppeak = $file + '_0_' + $ext
            # $temp = (Get-Item $in).BaseName + '_0_' + $ext
            Copy-Item $in $temppeak
            
    
            # Multiplos
            for ($step = 0; $step -lt $numofsteps; $step++) {
                
                $Clip = ""
    
                for ($item = 0; $item -lt $stepsize; $item++) {
    
                    $t = $step * $stepsize + $item
                    # Write-Host 'Multiplos'  $t
                    $tLeft = [double]$aPeakTime[$t] - 0.15
                    $tRight = [double]$aPeakTime[$t] + 0.15
                    $Clip += "volume=enable='between(t,$([double]($tLeft)),$([double]$tRight))':volume=0"                
                }
                
                if (-Not ($clip -eq "")) {
                    $temppeak = $file + '_' + $step + '_' + $ext
                    $temppeak2 = $file + '_' + ($step + 1) + '_' + $ext
                    ffmpeg -i $temppeak -af "$($clip.Replace("0vo","0,vo"))" $temppeak2 -y
                }
            }
    
            # Se o número de picos for inferior ao batch o que aconteceu é que o último comando ffmpeg termina com nome temp2, e acaba sendo removido na etapa de limpeza
            # para resolver o problema é preciso encontrar uma maneira de renomear o arquivo final após todas as extrações
            $Clip = ""
    
            for ($item = 0; $item -lt $laststep; $item++) {
                $t = $step * $stepsize + $item
    
                # Write-Host 'Nao Multiplos' $t
                $tLeft = [double]$aPeakTime[$t] - 0.15
                $tRight = [double]$aPeakTime[$t] + 0.15
                $Clip += "volume=enable='between(t,$([double]($tLeft)),$([double]$tRight))':volume=0"                
            }
            
            if (-Not ($clip -eq "")) {
                $temppeak = $file + '_' + $step + '_' + $ext
                $temppeak2 = $file + '_' + ($step + 1) + '_' + $ext
                ffmpeg -i $temppeak -af "$($clip.Replace("0vo","0,vo"))" $temppeak2 -y
            
            }

    
    
            Rename-Item $temppeak2 $outfile
            
            #Apaga os arquivos temporários gerados        
            # Remove-Item ($file + '_lowpass' + $ext)
            # Remove-Item ($file + '_lowpass_boost' + $ext)
            # Remove-Item ($file + '_lowpass.txt')
            # Remove-Item ($file + '_ebur128.txt')
            #Rename-Item ($out + '_spikeless' + $ext) ($out + $ext)
    
            
        }
        else {
            # só poe a saida aki
            Copy-Item $in $outfile
        }
        Remove-Item ($file + '_*')
    }
}
function EnhanceAudio {

    param($in, $out)

    Write-Host "Normalizando audio..."

    if (Test-Path -Path $in -PathType Leaf) {
        $file = (Get-Item $in).DirectoryName + '\' + (Get-Item $in).Basename
        #$ext = (Get-Item $in).Extension
         
        #Exporta arquivo com informações sobre o volume
        ffmpeg -i $in -hide_banner -nostats -af "volumedetect" -f null - 2>$file'_volumedetect.txt' | Format -y
    

        #Leitura do arquivo de texto com as informações sobre o volume
        $Text = Get-Content $file'_volumedetect.txt'

        #Transformando as linhas do arquivo em um array
        $Text.GetType() | Format-Table -AutoSize

        #Listando as linhas do arquivo
        #Aplicando substituições para leitura do arquivo de texto
        $Extension = $Text | ForEach-Object { $_ -replace "max_volume:", "|Max|" } `
        | ForEach-Object { $_ -replace "dB", "" } `
        | ForEach-Object { $_ -replace "\s+", "" } `
        | Where-Object { $_ -notmatch "size" } `
        | Where-Object { $_ -notmatch "Summary" } `



        foreach ($element in $Extension) { 
            $item = $element	
            $item = $item.split('|');
            if ($item.count -eq 3 -and $item[1] -eq "Max") { $MaxVolume = $item[2] }    
        }

        $VolumeBoost = - $MaxVolume - 1

      
        #Ajuste de volume máximo para -1dB
        ffmpeg -i $in -af "volume=$($VolumeBoost)dB" $out -y
              
        
        Remove-Item $file'_volumedetect.txt'
        # Remove-Item $in
    }

}

function SplitAudio {

    param($in, $out)
    Write-Host 'Fatiando audio...'

    if (Test-Path -Path $in -PathType Leaf) {
        $dir = (Get-Item $in).DirectoryName
        $base = (Get-Item $in).Basename
        $file = $dir + '\' + (Get-Item $in).Basename
        $ext = (Get-Item $in).Extension
        
        $duration = 2       #Duração mínima para trecho ser considerado como silêncio
        $threshold = -60    #Valor mínimo de volume para trecho ser considerado como silêncio
                   
        #Utiliza a silencedetect para mapear no vetor todas as posições para realizar os cortes,
        #a entrada em wav aumenta drásticamente o desempenho

        $aStart = @(); $aEnd = @()

        ffmpeg -hide_banner -i $in -af "silencedetect=n=$($threshold)dB:d=$($duration)" -f null - 2>&1 `
        | Select-String -Pattern "silence_end:\s*([0-9]*\.*[0-9]*)\s*.*silence_duration:\s*([0-9]*\.*[0-9]*)"  -AllMatches `
        | ForEach-Object {$aStart+= [double]$_.Matches.Groups[1].Value; $aEnd+= $_.Matches.Groups[1].Value-$_.Matches.Groups[2].Value}
                  
        #Expurta primeiro end
        $aEnd = $aEnd[1..($aEnd.Length - 1)]
        #Expurga último start
        $aStart = $aStart[0..($aStart.Length - 2)]

        $newfolder = Split-Path $out -Leaf

        $out2 = $out.Replace($newfolder, '')

        If (!(Test-Path $out)) {
            New-Item $out2 -Name $newfolder -ItemType "directory"
        }

        # Divide os arquivos com base nos vetores mapeados
        For ($i = 0; $i -lt $aStart.length ; $i++) {  
            
            $Duration = [double]$aEnd[$i] - [double]$aStart[$i]

            if ($Duration -ge 1) {
                # $name = $dir + '\' + $newfolder + '\' + $base + '_' + [string]$aStart[$i] + '_' + [string]$aEnd[$i] + $ext
                $name = $out + '\' + $base + '#' + [string]$aStart[$i] + '#' + [string]$aEnd[$i] + $ext
                ffmpeg -ss $aStart[$i] -i $in -t $Duration -c copy $name -y
            }

        }

        Remove-Item ($file + '_silencedetect.txt')
    }
}