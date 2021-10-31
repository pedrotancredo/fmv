
$directorypath = Split-Path $MyInvocation.MyCommand.Path
Set-Location -Path $directorypath
$libpath = $directorypath + "\library.ps1"
. $libpath

#Import-Module ".\library.psm1"

#Mede o tempo da execução da varredura
Measure-Command {

    $FMVVideo = 0
    $FMVAudio = 0
    $FMVSTT   = 1
    $FMVData  = 0
       
    # $Entrada = 'Z:\'
    $Entrada = '.\Data\'
    $Sobre = '*.ts'

    if($FMVVideo) {

        $Saida = '.\Output\TS_Video'
        Iterator $Entrada $Sobre -Call $function:ExtractAudio $Saida
    
    }
    
    if($FMVAudio) {
        
        $Saida = '.\Output\TS_audios2021'
        # $Saida = 'Y:\TS_audios'
        $Parametros = '-debug' #-replace -debug -remove
        Iterator $Entrada $Sobre -Call $function:FMVAudio $Saida $Parametros

    }

    if($FMVSTT) {

        $Saida = '.\Output\TS_STT2'
        # $Saida = 'D:\Output\TS_STT'
        Iterator $Entrada $Sobre -Call $function:FMVSTT $Saida

    }

    if($FMVData) {
    
        # $Saida = '.\Output\TS_Dados'
        $Saida = 'Y:\TS_dados'
        $Parametros = '-debug' #-replace -debug -remove
        Iterator $Entrada $Sobre -Call $function:FMVData $Saida $Parametros

    }

}

