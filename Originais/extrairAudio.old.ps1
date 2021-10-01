param($arquivo, $arquivodestino) # primeira linha

$pshost = Get-Host              # Get the PowerShell Host.
$pswindow = $pshost.UI.RawUI    # Get the PowerShell Host's UI.
# $host.UI.RawUI.MaxPhysicalWindowSize.Width

$newsize = $pswindow.BufferSize # Get the UI's current Buffer Size.
$newsize.width = 274            # Set the new buffer's width to 150 columns.
$pswindow.buffersize = $newsize # Set the new Buffer Size as active.

#$newsize = $pswindow.windowsize # Get the UI's current Window Size.
#$newsize.width = 274            # Set the new Window Width to 150 columns.
#$pswindow.windowsize = $newsize # Set the new Window Size as active.



Write-Host "Essse comando terá como saída um arquivo de audio com extensão aac extraído diretamente do arquivo .TS compativel com STANAG 4609 / MISB 0601 e MISB 0102 filtrado para redução de ruídos 'clip' "
if ($arquivo -and $arquivodestino){
#Original
#ffmpeg -i $arquivo -vn -acodec copy $arquivodestino'.wav'

#Nova convertendo para mono
###ffmpeg -i $arquivo -vn -ac 1 $arquivodestino'.aac'
#Gerando mapa para remoção de ruidos
ffmpeg -i $arquivodestino'.aac'  -hide_banner -nostats -filter_complex ebur128="peak=+true" -f null - 2> $arquivodestino'.txt' | Format
###interpretar o arquivo mapeado e armazenar em vetor valores para tempo e FTPK
#Caso FTPK > -3.5 adiciona ao vetor

#Lendo um arquivo txt
$Text = Get-Content $arquivodestino'.txt'
#Transformando as linhas do arquivo em um array 
$Text.GetType() | Format-Table -AutoSize
#Listando as linhas do arquivo

$clip="";
$deltaT=0.2;

$filtro=$Text | %{$_ -replace "\s+"," "} |where { $_ -notmatch "size"} |where { $_ -notmatch "Summary"} 

#|where { $_ -match "Parsed_ebur128"}

###compor linha de comando do ffmpeg para remoção do ruido considerando deltaT atualmente 0.2 segundos
# sintaxe: volume=enable='between(t,<tempo> - deltaT,<tempo> + deltaT)':volume=0

$ftpkMatriz = @();
$tempoMatriz = @();
$i=0;
$fatorCorte=1;

foreach ($element in $filtro) 
{ 
    $tempo=$element.Split('t:')[1].Split('TARGET')[0];
     
    $ftpk=$element.Split('FTPK:')[1].Split('dBFS')[0];
    
    $ftpkMatriz[$i] = $ftpk;

    $tempoMatriz[$i] = $tempo;

    $vetortst=$element.Split('t:')

    Write-Host "DADOS:------------------";
    Write-Host $tempo ;
    Write-Host $ftpk;
    Write-Host "SPLITs:------------------";

    Write-Host $vetortst[0]
    Write-Host $vetortst[1]

    Write-Host "----------------------------";


    $i++;

}

For ($i=0; $i -le $ftpkMatriz.Count-2 ; $i++) {
    
    if (-not [string]::IsNullOrEmpty($ftpkMatriz[$i])) {

        if([math]::Abs( [double]$ftpkMatriz[$i]/([math]::Pow($ftpkMatriz[$i+1],2))) -gt $fatorCorte ){
   
      $clip+="volume=enable='between(t,$([double]($tempoMatriz[$i])),$([double]$tempoMatriz[$i]+[double]$deltaT))':volume=0"
       
    }
    }

    }




  

     Write-Host "Valor de Clip: -------------------" + $clip
      

if(-Not ($clip -eq "")){
    $clip.Replace("0vo","0,vo")
    #Filtrar arquivo gerado removendo os picos de volume como saida final arquivo de audio
    #ffmpeg -i .\LTGUPMIC_T0274_T0295_P1.aac -af "volume=enable='between(FTPK,0,-4)':volume=0"
    #ffmpeg -i $arquivodestino'.aac' -af "volume=enable='between(t,38.2,38.6)':volume=0,volume=enable='between(t,81.3,81.7)':volume=0,volume=enable='between(t,165.5,165.9)':volume=0,volume=enable='between(t,165.6,166)':volume=0,volume=enable='between(t,170.2,170.6)':volume=0,volume=enable='between(t,198.4,198.8)':volume=0" saidafiltrada.aac
    ffmpeg -i $arquivodestino'.aac' -af "$($clip.Replace("0vo","0,vo"))" $arquivodestino'_.aac'

    #Apaga o arquivo com ruído e o arquivo txt de referencia mapeado
    del $arquivodestino'.aac'
    del $arquivodestino'.txt'
    #Renomeia o arquivo filtrado
    ren $arquivodestino'_.aac' $arquivodestino'.aac'

}else {

#Apaga arquivo txt de referencia mapeado e mantem o .aac com ruido
    del $arquivodestino'.txt'

}





} else {
Write-Host "Arquivo não informado ou destino não informado Por favor execute:"
Write-Host "----------------------------------------------"
Write-Host "./extrairAudio.ps1 <nome do arquivo de video .TS compativel com STANAG aqui> <caminho e nome do arquivo destino>"
}








