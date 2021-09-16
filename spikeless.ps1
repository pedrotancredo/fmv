param($arquivo, $arquivodestino) # primeira linha

Measure-Command {
$pshost = Get-Host              # Get the PowerShell Host.
$pswindow = $pshost.UI.RawUI    # Get the PowerShell Host's UI.
# $host.UI.RawUI.MaxPhysicalWindowSize.Width

#$newsize = $pswindow.BufferSize # Get the UI's current Buffer Size.
$newsize.width = 300            # Set the new buffer's width to 150 columns.
$pswindow.buffersize = $newsize # Set the new Buffer Size as active.

function ExtractAudio {

    param($in,$out,$ext)

    Write-Host "Extraí audio e converte para mono"
    ffmpeg -i $in -vn -ac 1 $out'.'$ext -y
}

function SpikeRemove {

    param($in,$out,$ext)

    #Cria um arquivo temporário para análise dos picos utilizando lowpass
    $lowpass = 20
    ffmpeg -i $in'.'$ext -af "lowpass=f=$($lowpass)" $out'_lowpass.'$ext -y

    #Análise da sonoridade do arquivo lowpass
    ffmpeg -i $in'_lowpass.'$ext -hide_banner -nostats -af 'loudnorm=I=-16:TP=-1.5:LRA=11:print_format=summary' -f null - 2>$out'_lowpass.txt' | Format -y

    #Leitura do arquivo de texto com a sonoridade do arquivo lowpass
    $Text = Get-Content $in'_lowpass.txt'

    #Transformando as linhas do arquivo em um array 
    $Text.GetType() | Format-Table -AutoSize

    #Listando as linhas do arquivo
    #Aplicando substituições para leitura do arquivo de texto
    $filtro=$Text | ForEach-Object{$_ -replace ":","|"} `
                  | ForEach-Object{$_ -replace "dBTP","|"} `
                  | ForEach-Object{$_ -replace "\s+",""} `
                  | Where-Object { $_ -notmatch "size"} `
                  | Where-Object { $_ -notmatch "Summary"} `

    foreach ($element in $filtro) {
        $item = $element
	    $item=$item.split('|');
   
        if($item.count -eq 3 -and $item[0] -eq "InputTruePeak") {
            $InputTruePeak = $item[1]
        }
    }

    #Amplificando o sinal da saída para detectação dos picos
    $Boost = 15;
    $InputTruePeak = $Boost - $InputTruePeak
    ffmpeg -i $in'_lowpass.'$ext -af "volume=$($InputTruePeak)dB" $out'_lowpass_volup.'$ext -y
    
    #Gerando mapa para remoção de ruidos a partir da leitura dos picos na saída do filtro EBU R128
    ffmpeg -i $in'_lowpass_volup.'$ext  -hide_banner -nostats -filter_complex ebur128="peak=+true" -f null - 2> $out'_ebur128.txt' | Format -y

    #Lendo arquivo de saída da EBU R128
    $Text = Get-Content $in'_ebur128.txt'
    
    #Transformando as linhas do arquivo em um array 
    $Text.GetType() | Format-Table -AutoSize
    
    #Listando as linhas do arquivo
    $filtro=$Text | ForEach-Object{$_ -replace "t:","|"} `
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

    foreach ($element in $filtro) { 

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
    For ($t=0; $t -lt $i - 2 ; $t++) {  
        if([double]$aFTPK[$t] -eq 0){

            #$tCenter = [double]$aTime[$t] 
            $tLeft = [double]$aTime[$t] - 0.2
            $tRight = [double]$aTime[$t] + 0.1     
            $Clip+="volume=enable='between(t,$([double]($tLeft)),$([double]$tRight))':volume=0"
            $p++
        }
    }

    #Write-Host "------------------------------------------------------------"
    #Write-Host "Foram encotrados: $($p) picos."
    $temp = $clip
    $temp = $temp.Replace("0vo","0|vo")
    $temp = $temp.Split("|")
    #Write-Host "------------------------------------------------------------"
    #For($i=0 ; $i -lt $temp.Count ; $i++){
    #    Write-Host "Pico $($i+1): $($temp[$i])"
    #}
    # Write-Host "------------------------------------------------------------" 

    if(-Not ($clip -eq "")) {
        #Filtrar arquivo gerado removendo os picos de volume como saida final arquivo de audio
        ffmpeg -i $in'.'$ext -af "$($clip.Replace("0vo","0,vo"))" $out'_spikeless.'$EXT -y            
    }
    
    else {

    #Apaga arquivo txt de referencia mapeado e mantem o .aac com ruido
    #del $arquivodestino'.txt'

    }
    
    #Apaga os arquivos temporários gerados
    Remove-Item $in'.'$ext
    Remove-Item $in'_lowpass.'$ext
    Remove-Item $in'_lowpass_volup.'$ext
    Remove-Item $in'_lowpass.txt'
    Remove-Item $in'_ebur128.txt'
    Rename-Item $out'_spikeless.'$ext $arquivodestino'.'$ext
}

function EnhanceAudio {
    param($in,$out,$ext)
    
    $suffix = "_spikeless"
    $in += $suffix    
    $out += $suffix

    $suffix = "_anlmdn"
    $out += $suffix

    ffmpeg -i $in'.'$ext -af "anlmdn" $out'.'$ext -y

    #Apaga temporário do spikeless
    Remove-Item $in'.'$ext

    
    $in = $out
    $suffix = "_volumeup"
    $out += $suffix


    #Exporta arquivo com informações sobre o volume
    ffmpeg -i $in'.'$ext -hide_banner -nostats -af "volumedetect" -f null - 2>$in'_volumedetect.txt' | Format -y
  

    #Leitura do arquivo de texto com as informações sobre o volume
    $Text = Get-Content $in'_volumedetect.txt'

    #Transformando as linhas do arquivo em um array
    $Text.GetType() | Format-Table -AutoSize

    #Listando as linhas do arquivo
    #Aplicando substituições para leitura do arquivo de texto
    $filtro=$Text | ForEach-Object{$_ -replace "max_volume:","|Max|"} `
                  | ForEach-Object{$_ -replace "dB",""} `
                  | ForEach-Object{$_ -replace "\s+",""} `
                  | Where-Object { $_ -notmatch "size"} `
                  | Where-Object { $_ -notmatch "Summary"} `



    foreach ($element in $filtro) 
    { 
        $item = $element	
	    $item=$item.split('|');
        if($item.count -eq 3 -and $item[1] -eq "Max"){$MaxVolume = $item[2]}    
    }

    $VolumeBoost = - $MaxVolume - 1

    #Apaga temporário do volume txt
    Remove-Item $in'_volumedetect.txt'

    #Ajuste de volume máximo para -1dB
    ffmpeg -i $in'.'$ext -af "volume=$($VolumeBoost)dB" $out'.'$ext -y

    #Apaga temporário do spikeless
    Remove-Item $in'.'$ext      

    
    #Remover a posteriori
    #Remove Clips e Clicks
    $in = $out
    $suffix = "_click"
    $out += $suffix

    ffmpeg -i $in'.'$ext -af "adeclick" $out'.'$ext -y

    #Apaga temporário do volume
    Remove-Item $in'.'$ext

    Rename-Item $out'.'$ext $arquivodestino'.'$ext

}

if ($arquivo -and $arquivodestino) {

    $ext = "wav"

    ExtractAudio $arquivo $arquivodestino $ext

    SpikeRemove $arquivodestino $arquivodestino $ext

    #EnhanceAudio $arquivodestino $arquivodestino $ext


    }
    else {
    
    Write-Host "Arquivo não informado ou destino não informado Por favor execute:"
    Write-Host "----------------------------------------------"
    Write-Host "./extrairAudio.ps1 <nome do arquivo de video .TS compativel com STANAG aqui> <caminho e nome do arquivo destino>"
    }
}