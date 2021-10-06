function ExtractAudio {

    param($in,$out)

    Write-Host "Extraindo audio..."

    if(Test-Path -Path $in -PathType Leaf){
        # $dir = (Get-Item $in).DirectoryName
        # $base = (Get-Item $in).Basename
        # $file = $dir + '\' + (Get-Item $in).Basename
        # $ext = (Get-Item $in).Extension
        
        ffmpeg -i $in -vn -ac 1 $out'.wav' -y
    }
}

function SpikeRemove {
    
    param($in,$out)

    Write-Host "Removendo picos..."       
    
    if(Test-Path -Path $in -PathType Leaf){
        
        $file = (Get-Item $in).DirectoryName + '\' + (Get-Item $in).Basename
        $ext = (Get-Item $in).Extension
            
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
        $Extension=$Text | ForEach-Object{$_ -replace ":","|"} `
        | ForEach-Object{$_ -replace "dBTP","|"} `
        | ForEach-Object{$_ -replace "\s+",""} `
        | Where-Object { $_ -notmatch "size"} `
        | Where-Object { $_ -notmatch "Summary"} `
        
        foreach ($element in $Extension) {
        
            $item = $element
            $item=$item.split('|');
                
            if($item.count -eq 3 -and $item[0] -eq "InputTruePeak") {
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
        $Extension=$Text | ForEach-Object{$_ -replace "t:","|"} `
        | ForEach-Object{$_ -replace "TARGE",""} `
        | ForEach-Object{$_ -replace "dBFS",""} `
        | ForEach-Object{$_ -replace "FTPK:","|"} `
        | ForEach-Object{$_ -replace "TPK:","|"} `
        | ForEach-Object{$_ -replace "LUFS",""} `
        | ForEach-Object{$_ -replace "LU",""} `
        | ForEach-Object{$_ -replace "M:","|"} `
        | ForEach-Object{$_ -replace "I:","|"} `
        | ForEach-Object{$_ -replace "S:","|"} `
        | ForEach-Object{$_ -replace "LRA:","|"} `
        | ForEach-Object{$_ -replace "-inf","-80"} `
        | ForEach-Object{$_ -replace "\s+",""} `
        | Where-Object { $_ -notmatch "size"} `
        | Where-Object { $_ -notmatch "Summary"} `


        ###compor linha de comando do ffmpeg para remoção do ruido considerando deltaT atualmente 0.1 segundos
        # sintaxe: volume=enable='between(t,<tempo> - deltaT,<tempo> + deltaT)':volume=0
        $aFTPK = @();
        $aTime = @();
        $i=0;
        
        foreach ($element in $Extension) { 
        
            $item = $element	
            $item=$item.split('|');
            if($item.count -eq 9){
                $aTime += $item[1]
                $aFTPK += $item[7]       
                $i++        
            }
        }
        #Write-Host "Total de Elementos: $($i)."

        $Clip=""
        $p = 0

        For ($t=0; $t -lt $i - 0 ; $t++) {  
            if([double]$aFTPK[$t] -eq 0){
            
                #$tCenter = [double]$aTime[$t] 
                $tLeft = [double]$aTime[$t] - 0.15
                $tRight = [double]$aTime[$t] + 0.15
                $Clip+="volume=enable='between(t,$([double]($tLeft)),$([double]$tRight))':volume=0"
                $p++
            }
        }
            
        # Write-Host "------------------------------------------------------------"
        # Write-Host "Foram encotrados: $($p) picos."
        # $temp = $clip
        # $temp = $temp.Replace("0vo","0|vo")
        # $temp = $temp.Split("|")
        # Write-Host "------------------------------------------------------------"
        # For($i=0 ; $i -lt $temp.Count ; $i++){
        #     Write-Host "Pico $($i+1): $($temp[$i])"
        # }
        #  Write-Host "------------------------------------------------------------" 
        
        if(-Not ($clip -eq "")) {
            #Filtrar arquivo gerado removendo os picos de volume como saida final arquivo de audio
            #ffmpeg -i $in -af "$($clip.Replace("0vo","0,vo"))" $out'_spikeless'$ext -y
            ffmpeg -i $in -af "$($clip.Replace("0vo","0,vo"))" $out -y
        }
            
        else {
        
        }
            
        #Apaga os arquivos temporários gerados
        
        
        Remove-Item ($file + '_lowpass' + $ext)
        Remove-Item ($file + '_lowpass_boost' + $ext)
        Remove-Item ($file + '_lowpass.txt')
        Remove-Item ($file + '_ebur128.txt')
        #Rename-Item ($out + '_spikeless' + $ext) ($out + $ext)
    }
}

function EnhanceAudio {

    param($in,$out)

    Write-Host "Normalizando audio..."

    if(Test-Path -Path $in -PathType Leaf){
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
        $Extension=$Text | ForEach-Object{$_ -replace "max_volume:","|Max|"} `
        | ForEach-Object{$_ -replace "dB",""} `
        | ForEach-Object{$_ -replace "\s+",""} `
        | Where-Object { $_ -notmatch "size"} `
        | Where-Object { $_ -notmatch "Summary"} `



        foreach ($element in $Extension) 
        { 
            $item = $element	
            $item=$item.split('|');
            if($item.count -eq 3 -and $item[1] -eq "Max"){$MaxVolume = $item[2]}    
        }

        $VolumeBoost = - $MaxVolume - 1

      
        #Ajuste de volume máximo para -1dB
        ffmpeg -i $in -af "volume=$($VolumeBoost)dB" $out -y
              
        
        Remove-Item $file'_volumedetect.txt'
        # Remove-Item $in
    }

}

function SplitAudio {

    param($in,$out)
    Write-Host 'Fatiando audio...'

    if(Test-Path -Path $in -PathType Leaf){
        $dir = (Get-Item $in).DirectoryName
        $base = (Get-Item $in).Basename
        $file = $dir + '\' + (Get-Item $in).Basename
        $ext = (Get-Item $in).Extension
        
        
        # $in = '.\Data\LTMMOEST.ts'
        # $out = '.\Data\LTMMOEST2.wav'
        
        
        #Utiliza a silencedetect para mapear no vetor todas as posições para realizar os cortes, a Inlet precisar ser um wav para aumentar o desempenho 
        #Pega a duração e o bitrate do audio original
        ffmpeg -i $in -af "silencedetect=n=-60dB:d=0.5" -f null - 2>$file'_silencedetect.txt' | Format -y
        
        #Leitura do arquivo de texto com os valores de silence detect
        $Text = Get-Content $file'_silencedetect.txt'
        
        #Transformando as linhas do arquivo em um array 
        $Text.GetType() | Format-Table -AutoSize
        
        #Listando as linhas do arquivo
        #Aplicando substituições para leitura do arquivo de texto
        $Extension=$Text | ForEach-Object{$_ -replace "tart:","|"} `
                      | ForEach-Object{$_ -replace "nd:","|"} `
                      | ForEach-Object{$_ -replace "]","|"} `
                      | ForEach-Object{$_ -replace "\s+",""} `
                      | Where-Object { $_ -notmatch "size"} `
                      | Where-Object { $_ -notmatch "Summary"} `
                      
        $aStart = @()
        $aEnd = @()


        foreach ($element in $Extension) {
             $item = $element
             $item=$item.split('|');
             

             if($item.count -ge 3) {
                if($item[1] -eq 'silence_e'){
                    $aStart += $item[2]
                }
                elseif ($item[1] -eq 'silence_s') {
                    $aEnd += $item[2]
                }
            }
            
        }
        
        # Write-Host "Start: $($aStart.Length)"
        # Write-Host "End: $($aEnd.Length)"
        
        #expurta primeiro end
        $aEnd = $aEnd[1..($aEnd.Length-1)]
        #expurga último start
        $aStart = $aStart[0..($aStart.Length-2)]

        # Write-Host "Start: $($aStart.Length)"
        # Write-Host "End: $($aEnd.Length)"

        # Write-Host "Primeiro Start: $($aStart[0])"
        # Write-Host "Primeiro End: $($aEnd[0])"
        
        # Write-Host "Ultimo Start: $($aStart[$aStart.length-1])"
        # Write-Host "Ultimo End: $($aEnd[$aEnd.length-1])"

        
        # $newfolder = $base + '_split'
        # If(!(Test-Path ($dir + '\' + $newfolder + '\'))) {
        #     New-Item $dir -Name $newfolder -ItemType "directory"
        # }
        $newfolder = Split-Path $out -Leaf

        $out2 = $out.Replace($newfolder,'')

        If(!(Test-Path $out)) {
            New-Item $out2 -Name $newfolder -ItemType "directory"
        }

        # Divide os arquivos com base nos vetores mapeados
        For ($i=0; $i -lt $aStart.length ; $i++) {  
            
            $Duration = [double]$aEnd[$i]-[double]$aStart[$i]
            # $name = $dir + '\' + $newfolder + '\' + $base + '_' + [string]$aStart[$i] + '_' + [string]$aEnd[$i] + $ext
            $name = $out + '\' + $base + '#' + [string]$aStart[$i] + '#' + [string]$aEnd[$i] + $ext
            ffmpeg -ss $aStart[$i] -i $in -t $Duration -c copy $name -y

        }

        Remove-Item ($file + '_silencedetect.txt')
    }
}

function FMVVideo {
    param($In, $Out, $Overwrite)
    
    #Verifica se Arquivo já existe, caso sim não reprocessa
    if(Test-Path -Path $Out'.mp4') {
        Write-Host "Arquivo existente"
    }
    else {

        Write-Host "Extraindo video..."
   
        if ($In -and $Out){

            ffmpeg -i $In -c:v libx264 -ac 1 -movflags +faststart -vf "yadif=1,scale=-2:720" $Out'.mp4'
        }
        else {

            Write-Host "Arquivo n�o informado ou destino n�o informado Por favor execute:"
            Write-Host "----------------------------------------------"
            Write-Host "./converterParaMPEG.ps1 <nome do arquivo de video .TS> <caminho e nome do arquivo destino com extens�o .mp4>"
        }
    }
}

function FMVAudio {
    param($in,$out)
    
    $ext = (Get-Item $in).Extension
    $temp = $out.Substring(0,$out.Length - $ext.Length) + '_mono'

    ExtractAudio $in $temp

    $temp = $temp + '.wav'
    $temp2 = $temp + '_spikeless.wav'
    
    SpikeRemove $temp $temp2
    Remove-Item $temp

    EnhanceAudio $temp2 $($out + '.wav')
    Remove-Item $temp2

    Write-Host 'Concluido'
    
}

function FMVData {
    param($in,$out)
    
}

function FMVSTT {
    param($in,$out)
    
    $ext = (Get-Item $in).Extension
    $temp = $out.Substring(0,$out.Length - $ext.Length) 

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
        $NewName = ($_.BaseName).Replace('.wav','')
        Rename-Item -Path $_.FullName -NewName ($NewName + '.wav')
    }


    
}

function Iterator {
    param($Inlet,$Extension,[scriptblock]$Call,$Outlet)
    
    $Origem = Convert-Path $Inlet
    
    #verifica se já existe. Se não, cria
    if(-Not (Test-Path -Path $Outlet)) {
            mkdir $Outlet
    }
        
    #itera a lista de arquivos na pasta e cria pasta se arquivo atender ao critério de tipo
    Get-ChildItem -Recurse -Path $Inlet -File -Include $Extension | ForEach-Object -Process {
            
        Write-Host "------------------------------------------------------------------------------------------------------"
        Write-Host "Arquivo a ser processado: $($_.Name)"
        $sub = ($_.FullName).Replace($Origem,'')
        $dir = ($_.DirectoryName).Replace($Origem,'')
        $destinovideo = $Outlet + $sub
        
        $dir = $Outlet + $dir + '\' 
        
        #verifica se já existe. Se não, cria
        if(-Not (Test-Path -Path $dir)) {
            Write-Host "Criando pasta: $($dir)"
            New-Item -ItemType directory -Path $dir
        }
        else {
            Write-Host "Pasta $($dir) ja criada"
        }

        $arquivoorigem=$_.FullName;
        $arquivodestino=$destinovideo;
        $Call.Invoke($arquivoorigem, $arquivodestino)
    }	                        
}