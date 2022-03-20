#Transforma em string com casas fixas, mesmo se inteiro https://arcanecode.com/2021/07/19/fun-with-powershell-string-formatting/
#"{0:n2}" -f [math]::Round($a,2)

function FMVFrames3 {
    param($In, $Out)
    
    # O nome do arquivo contido na entrada deve possuir os separadores # indicando inicio e fim do trecho, ex.: "LTSMANIQ1_T0218_T0061#637.88#640.11.wav"

    $Padding = 30            #Tempo extra adicionado ao início e ao fim do trecho específicado
    $ImagesPerSecond = 1    #Quantidade de imagens por segundo


    $Start = [double]$NomeArquivo.Split('#')[1] - $Padding
    $End = [double]$NomeArquivo.Split('#')[2].Replace('.wav', '') + $Padding
    $Duration = $End - $Start
    
    # https://stackoverflow.com/questions/21842175/convert-seconds-to-hhmmss-fff-format-in-powershell  
    # $StartTime = ("{0:hh\:mm\:ss\.ff}" -F [Timespan]::FromSeconds($Start))

    # Tive que usar um for normal para manter a rastreabilidade das imagens
    For ($i = 0; $i -le [Math]::Ceiling($Duration*$ImagesPerSecond); $i++) {
        $CurrentTime = "{0:n2}" -f ($Start+$i/$ImagesPerSecond) -Replace ',','.'
        ffmpeg -ss $CurrentTime -i $In -vf "yadif=2" -frames:v 1 -qscale:v 1 -shortest "E:\OneDrive\Documentos\GitHub\fmv\test\output\TS_frames\output#$($CurrentTime).jpg" -y
    }
}
# foreach ($line in Get-Content .\string.txt) {
# $In, $Out, $Start, $Duration = "E:\OneDrive\Documentos\GitHub\fmv\test\input\2019\DRB\19-10-22\LTSMANIQ1_T0218_T0061.ts", "E:\OneDrive\Documentos\GitHub\fmv\test\output\TS_frames\bar#%d.jpeg"
#     $In, $Out, $Start, $Duration = Invoke-Expression $line
# FMVFrames $In $Out $Start $Duration
# }