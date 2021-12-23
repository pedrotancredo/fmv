function ForceResolvePath {
    <#
    .SYNOPSIS
        Calls Resolve-Path but works for files that don't exist.
    .REMARKS
        From http://devhawk.net/blog/2010/1/22/fixing-powershells-busted-resolve-path-cmdlet
    #>
    param (
        [string] $FileName
    )

    $FileName = Resolve-Path $FileName -ErrorAction SilentlyContinue `
        -ErrorVariable _frperror
    if (-not($FileName)) {
        $FileName = $_frperror[0].TargetObject
    }

    return $FileName
}
function Iterator {
    param($Inlet, $Extension, [scriptblock]$Call, $Outlet, $Params)
    
    $Origem = Convert-Path $Inlet
    
    #verifica se já existe. Se não, cria
    if (-Not (Test-Path -Path $Outlet)) {
        mkdir $Outlet
    }
        
    #itera a lista de arquivos na pasta e cria pasta se arquivo atender ao critério de tipo
    Get-ChildItem -Recurse -Path $Inlet -File -Include $Extension | ForEach-Object -Process {
            
        Write-Host "------------------------------------------------------------------------------------------------------"
        Write-Host "Arquivo a ser processado: $($_.Name)"
        if ($Origem.Substring($Origem.Length - 1, 1) -eq '\') {
            $Origem.Substring($Origem.Length - 1, 1)
            $Origem = $Origem.Substring(0, $Origem.Length - 1)
        }
        $sub = ($_.FullName).Replace($Origem, '')
        $dir = ($_.DirectoryName).Replace($Origem, '')
        $destinovideo = $Outlet + $sub
        
        $dir = $Outlet + $dir + '\' 
        
        #verifica se já existe. Se não, cria
        if (-Not (Test-Path -Path $dir)) {
            Write-Host "Criando pasta: $($dir)"
            New-Item -ItemType directory -Path $dir
        }
        else {
            Write-Host "Pasta $($dir) ja criada"
        }

        $arquivoorigem = $_.FullName;
        $arquivodestino = $destinovideo;
        $Call.Invoke($arquivoorigem, $arquivodestino, $Params)
    }	                        
}