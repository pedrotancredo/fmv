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
    param($InputRootPath, $Extension, [scriptblock]$Call, $OutputRootPah, $Params)
    
    $AbsoluteRootPath = Convert-Path $InputRootPath
    
    #verifica se já existe. Se não, cria
    if (-Not (Test-Path -Path $OutputRootPah)) {
        mkdir $OutputRootPah
    }
        
    #itera a lista de arquivos na pasta e cria pasta se arquivo atender ao critério de tipo
    Get-ChildItem -Recurse -Path $InputRootPath -File -Include $Extension | ForEach-Object -Process {
            
        Write-Host "------------------------------------"
        Write-Host "Arquivo a ser processado: $($_.Name)"
        if ($AbsoluteRootPath.Substring($AbsoluteRootPath.Length - 1, 1) -eq '\') {
            $AbsoluteRootPath.Substring($AbsoluteRootPath.Length - 1, 1)
            $AbsoluteRootPath = $AbsoluteRootPath.Substring(0, $AbsoluteRootPath.Length - 1)
        }

        $AbsoluteRootPath = $AbsoluteRootPath.TrimEnd('/')
        $OutputRootPah = $OutputRootPah.TrimEnd('/')

        $sub = ($_.FullName).Replace($AbsoluteRootPath, '')
        $dir = ($_.DirectoryName).Replace($AbsoluteRootPath, '')
        $destinovideo = $OutputRootPah + $sub
        
        $dir = $OutputRootPah + $dir + '\' 
        
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