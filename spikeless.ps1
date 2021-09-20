param($entrada, $saida) # primeira linha

Measure-Command {
    $pshost = Get-Host              # Get the PowerShell Host.
    $pswindow = $pshost.UI.RawUI    # Get the PowerShell Host's UI.
    $host.UI.RawUI.MaxPhysicalWindowSize.Width

    $newsize = $pswindow.BufferSize # Get the UI's current Buffer Size.
    $newsize.width = 300            # Set the new buffer's width to 150 columns.
    $pswindow.buffersize = $newsize # Set the new Buffer Size as active.

    . ".\library.ps1"

    if(Test-Path -Path $entrada -PathType Leaf){
        $base = (Get-Item $entrada).Basename
        $dir = (Get-Item $entrada).DirectoryName
        $file = $dir + '\' + $base

        
        # Extraí o audio (Entrada = Arquivo a ser lido, Saída = Arquivo convertido, Ext = Extensão do arquivo convertido)
        $in = $entrada
        $out = $file + '_mono.wav'
         
        ExtractAudio $in $out        
        
        #  Divide o arquivo em partes com audio (Entrada = Arquivo a ser dividido, Saida = Diretório onde serão armazenadas as partes)
        $in = $out
        $out = $file + '_mono_split\'
        
        SplitAudio $in $out
        
        # Remove-Item $in

        # Itera sobre todos os arquivos no diretório
        Get-ChildItem $out -Filter *.wav | Foreach-Object {

            $in = $_.FullName
            $out2 = $_.DirectoryName + '\' + $_.BaseName + '_spikeless' + $_.Extension

            SpikeRemove $in $out2

            Remove-Item $in
            
            $in = $out2 
            $out = $out2 + '_out.wav'
            
            EnhanceAudio $in $out

            Remove-Item $in


        }       

    }
    else {
        
        Write-Host "Arquivo não informado ou destino não informado Por favor execute:"
        Write-Host "----------------------------------------------"
        Write-Host "./extrairAudio.ps1 <nome do arquivo de video .TS compativel com STANAG aqui> <caminho e nome do arquivo destino>"

    }
}