
. ".\library.ps1"


#Mede o tempo da execução da varredura
Measure-Command {

    $FMVVideo = 0
    $FMVAudio = 0
    $FMVSTT   = 1
    $FMVData  = 0
    
    # $Entrada = '.\Data'
    
    $Entrada = '.\Data'
    $Sobre = '*.ts'

    if($FMVVideo) {

        $Saida = '.\Output\TS_Video'
        Iterator $Entrada $Sobre -Call $function:ExtractAudio $Saida
    
    }
    
    if($FMVAudio) {
        
        $Saida = '.\Output\TS_Audio'      
        Iterator $Entrada $Sobre -Call $function:FMVAudio $Saida

    }

    if($FMVSTT) {

        $Saida = '.\Output\TS_Test2'
        Iterator $Entrada $Sobre -Call $function:FMVSTT $Saida
        
    }
    
    if($FMVSTT) {
    
        $Saida = '.\Output\TS_Dados'
       
        Iterator $Entrada $Sobre -Call $function:FMVData $Saida

    }
}