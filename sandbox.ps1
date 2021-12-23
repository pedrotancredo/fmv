$directorypath = Split-Path $MyInvocation.MyCommand.Path
# Set-Location -Path $directorypath
$libpath = $directorypath + "\modules\import.ps1"
. $libpath

# Import-Module ".\library.psm1"

# Mede o tempo da execução da varredura
Measure-Command {
    #apenas um teste
    $FMVVideo = 1
    $FMVAudio = 0
    $FMVSTT = 1
    $FMVData = 0
       
    # $Entrada = 'Z:\'
    # $Entrada = '.\Data\'
    $Entrada = '.\test\input\'
    $Sobre = '*.ts'

    if ($FMVVideo) {

        $Saida = '.\test\output\TS_videos'
        Iterator $Entrada $Sobre -Call $function:FMVVideo $Saida
    
    }
    
    if ($FMVAudio) {
        
        $Saida = '.\test\output\TS_audios'
        # $Saida = 'Y:\TS_audios'
        $Parametros = '-debug' #-replace -debug -remove
        Iterator $Entrada $Sobre -Call $function:FMVAudio $Saida $Parametros

    }

    if ($FMVSTT) {

        $Saida = '.\test\output\TS_stt\'
        # $Saida = 'D:\Output\TS_STT2'
        Iterator $Entrada $Sobre -Call $function:FMVSTT $Saida

    }

    if ($FMVData) {
    
        # $Saida = '.\Output\TS_Dados'
        $Saida = '.\test\output\TS_dados'
        $Parametros = '-debug' #-replace -debug -remove
        Iterator $Entrada $Sobre -Call $function:FMVData $Saida $Parametros

    }

}

