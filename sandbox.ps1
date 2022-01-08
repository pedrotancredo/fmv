$directorypath = Split-Path $MyInvocation.MyCommand.Path
Set-Location -Path $directorypath
$libpath = $directorypath + "\modules\import.ps1"
. $libpath

# Import-Module ".\library.psm1"

# Mede o tempo da execução da varredura
Measure-Command {
    #apenas um teste
    $FMVVideo = 0
    $FMVAudio = 0
    $FMVSlice = 1
    $FMVData = 0
       
    # $Entrada = '.\Data\'
    $Entrada = '.\test\input\'
    # $Entrada = 'Y:\'
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
 
    if ($FMVSlice) {

        $Saida = '.\test\output\TS_trechos5\'
        # $Saida = 'Z:\TS_trechos'
        $Parametros = '' #-replace -debug -remove
        Iterator $Entrada $Sobre -Call $function:FMVSlice $Saida $Parametros

    }

    if ($FMVData) {
    
        # $Saida = '.\Output\TS_Dados'
        $Saida = '.\test\output\TS_dados'
        $Parametros = '-debug' #-replace -debug -remove
        Iterator $Entrada $Sobre -Call $function:FMVData $Saida $Parametros

    }

}