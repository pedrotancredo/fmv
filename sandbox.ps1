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
    $FMVData = 1
    $FMVSTT = 0
       
    # $Entrada = '.\Data\'
    # $Entrada = '.\test\input\'
    $Entrada = 'F:\FMV_TEMP\up\HD'
    # $Entrada = 'F:\FMV_TEMP\up\'
    # $Entrada = 'C:\Users\pedro\OneDrive\Documentos\GitHub\fmv\test\input'
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

        $Saida = '.\test\output\TS_trechos\'
        # $Saida = 'Z:\TS_trechos'
        $Parametros = '' #-replace -debug -remove
        Iterator $Entrada $Sobre -Call $function:FMVSlice $Saida $Parametros

    }

    if ($FMVData) {
    
        # $Saida = '.\Output\TS_Dados'
        $Saida = '.\test\output\TS_dados\TESTE'
        $Parametros = '-debug' #-replace -debug -remove
        Iterator $Entrada $Sobre -Call $function:FMVData $Saida $Parametros

    }

    if ($FMVSTT) {
    
        $Sobre = '*.wav'
        $Entrada = 'Z:\TS_trechos'
        $Saida = 'Z:\TS_transcricao'
        $Parametros = '-debug' #-replace -debug -remove
        Iterator $Entrada $Sobre -Call $function:FMVSTT $Saida $Parametros

    }

}

# FMVFrames "E:\OneDrive\Documentos\GitHub\fmv\overlap20s.txt" "PIT"
# $inputfile = "Z:\TS_trechos\2019\DRN\19-07-02\LTBFLCHP_LTCHPRSD_LTADRCHP.ts\LTBFLCHP_LTCHPRSD_LTADRCHP#13.47#29.79.wav"
# $inputfile =  "E:\OneDrive\Documentos\GitHub\fmv\test\output\TS_trechos\2020\DRQ\20-07-27\LTIABTPR2_T0122.ts\LTIABTPR2_T0122#11.6467#20.9609.wav"
# $outputfile = "Z:\TS_stt\2019\DRN\19-07-02\LTBFLCHP_LTCHPRSD_LTADRCHP.ts\LTBFLCHP_LTCHPRSD_LTADRCHP#13.47#29.79.txt"
# $outputfile = "E:\OneDrive\Documentos\GitHub\fmv\test\output\TS_stt\2020\DRQ\20-07-27\LTIABTPR2_T0122.ts\LTIABTPR2_T0122#11.6467#20.9609.txt"
# ExtractText $inputfile $outputfile

# Itera sobre o diretório com a transcricao e procura arquivos que tenham a palavra esfera, considerando um preenchimento de 30s gere uma imagem por segundo destes trechos