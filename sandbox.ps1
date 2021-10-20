
$directorypath = Split-Path $MyInvocation.MyCommand.Path
Set-Location -Path $directorypath
$libpath = $directorypath + "\library.ps1"
. $libpath

#Import-Module ".\library.psm1"

#Mede o tempo da execução da varredura
Measure-Command {

    $FMVVideo = 0
    $FMVAudio = 0
    $FMVSTT   = 0
    $FMVData  = 1
       
    $Entrada = 'Z:\'
    # $Entrada = '.\Data\2020\DRL'
    $Sobre = '*.ts'

    if($FMVVideo) {

        $Saida = '.\Output\TS_Video'
        Iterator $Entrada $Sobre -Call $function:ExtractAudio $Saida
    
    }
    
    if($FMVAudio) {
        
        # $Saida = '.\Output\TS_audios2020'
        $Saida = 'Y:\TS_audios'
        $Parametros = '-debug' #-replace -debug -remove
        Iterator $Entrada $Sobre -Call $function:FMVAudio $Saida $Parametros

    }

    if($FMVSTT) {

        # $Saida = '.\Output\TS_STT'
        $Saida = 'D:\Output\TS_STT'
        Iterator $Entrada $Sobre -Call $function:FMVSTT $Saida

    }

    if($FMVData) {
    
        # $Saida = '.\Output\TS_Dados'
        $Saida = 'Y:\TS_dados'
        $Parametros = '-debug' #-replace -debug -remove
        Iterator $Entrada $Sobre -Call $function:FMVData $Saida $Parametros

        # $Entrada = '.\Output\TS_Dados3'
        # $Sobre = '*.bin'
        # $Saida = '.\Output\TS_Dados4'
        # Iterator $Entrada $Sobre -Call $function:ConvertJSON $Saida
    }

}



# ffmpeg -i .\Data\2020\DRL\LTCHPFDI_LTCAMFDI_T0229.ts -vn -ac 1 .\Output\TESTE\Issoai.wav -y 2>&1 | Select-String -Pattern 'time=(.*?)bit.*?speed=([\s0-9]+)x' -AllMatches | ForEach-Object { Write-Progress $_}

# SpikeRemove 'D:\Output\TS_STT\2020\DRL\LTCHPFDI_LTCAMFDI_T0229.ts\LTCHPFDI_LTCAMFDI_T0229#3584.95#3585_mono.wav' 'D:\Output\Aqui.wav'

