
$directorypath = Split-Path $MyInvocation.MyCommand.Path
Write-Host $directorypath

$libpath = $directorypath + "\library.ps1"
. $libpath

#Import-Module ".\library.psm1"

#Mede o tempo da execução da varredura
Measure-Command {

    $FMVVideo = 0
    $FMVAudio = 1
    $FMVSTT   = 0
    $FMVData  = 0
    
    # $Entrada = '.\Data'    
    # $Entrada = 'F:\2021\DRG'
    
    $Entrada = 'Z:\'
    $Sobre = '*.ts'

    if($FMVVideo) {

        $Saida = '.\Output\TS_Video'
        Iterator $Entrada $Sobre -Call $function:ExtractAudio $Saida
    
    }
    
    if($FMVAudio) {
        
        # $Saida = '.\Output\TS_audios'
        $Saida = 'Y:\TS_audios'
        $Parametros = '-debug' #-replace -debug -remove
        Iterator $Entrada $Sobre -Call $function:FMVAudio $Saida $Parametros

    }

    if($FMVSTT) {

        $Saida = '.\Output\TS_STT'
        Iterator $Entrada $Sobre -Call $function:FMVSTT $Saida

    }

    if($FMVData) {
    
        $Saida = '.\Output\TS_Dados'
       
        Iterator $Entrada $Sobre -Call $function:FMVData $Saida

        $Entrada = '.\Output\TS_Dados3'
        $Sobre = '*.bin'
        $Saida = '.\Output\TS_Dados4'
        Iterator $Entrada $Sobre -Call $function:ConvertJSON $Saida
    }

}