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
    $FMVSlice = 0
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
$inputfile = "Z:\TS_trechos\2019\DRN\19-07-02\LTBFLCHP_LTCHPRSD_LTADRCHP.ts\LTBFLCHP_LTCHPRSD_LTADRCHP#13.47#29.79.wav"
$outputfile = "Z:\TS_stt\2019\DRN\19-07-02\LTBFLCHP_LTCHPRSD_LTADRCHP.ts\LTBFLCHP_LTCHPRSD_LTADRCHP#13.47#29.79.txt"
ExtractText $inputfile $outputfile

# Itera sobre o diretório com a transcricao e procura arquivos que tenham a palavra esfera, considerando um preenchimento de 30s gere uma imagem por segundo destes trechos