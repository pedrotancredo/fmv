param($entrada, $arquivodestino) # primeira linha

Measure-Command {
    $pshost = Get-Host              # Get the PowerShell Host.
    $pswindow = $pshost.UI.RawUI    # Get the PowerShell Host's UI.
    $host.UI.RawUI.MaxPhysicalWindowSize.Width

    $newsize = $pswindow.BufferSize # Get the UI's current Buffer Size.
    $newsize.width = 300            # Set the new buffer's width to 150 columns.
    $pswindow.buffersize = $newsize # Set the new Buffer Size as active.

    . ".\library.ps1"

    if(Test-Path -Path $entrada -PathType Leaf){
        $file = (Get-Item $entrada).DirectoryName + '\' + (Get-Item $entrada).Basename
        
        
        $in = $entrada
        $out = $file + '_out' 
        $ext = '.wav'

        ExtractAudio $in $out $ext

        $in = $out + $ext
        $out = $arquivodestino# + $ext

        SpikeRemove $in $out

        #EnhanceAudio $arquivodestino $arquivodestino $ext

    }
    else {
        
        Write-Host "Arquivo não informado ou destino não informado Por favor execute:"
        Write-Host "----------------------------------------------"
        Write-Host "./extrairAudio.ps1 <nome do arquivo de video .TS compativel com STANAG aqui> <caminho e nome do arquivo destino>"

    }
}