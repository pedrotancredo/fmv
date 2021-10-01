$Entrada = '.\Data'
$Sobre = ('*.ts')
$Saida = '.\Output\TS_Audio'

Iterator $Entrada $Sobre -Call $function:ExtractAudio $Saida

# $Entrada = '.\Output\TS_Audio'
# $Sobre = ('*.wav')
# $Saida = '.\Output\TS_Spikeless'

# Iterator $Entrada $Sobre -Call $function:SpikeRemove $Saida