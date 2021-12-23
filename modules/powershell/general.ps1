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
    param($InputRootPath, $Extension, [scriptblock]$Call, $OutputRootPath, $Params)
       
    #Cria o diretório raiz da saída no caso dele não existir
    if (-Not (Test-Path -Path $OutputRootPath)) { mkdir $OutputRootPath }
    
    $AbsoluteInputRootPath = Convert-Path $InputRootPath.TrimEnd('\')
    $AbsoluteOutputRootPath = Convert-Path $OutputRootPath.TrimEnd('\')
        
    #Itera recursivamente, executando a função informada em $Call, sobre os arquivos no diretório raiz da entrada que atendam ao critério de extensão 
    Get-ChildItem -Recurse -Path $AbsoluteInputRootPath -File -Include $Extension | ForEach-Object -Process {
            
        Write-Host "------------------------------------"
        Write-Host "Arquivo a ser processado: $($_.Name)"

        $ItemRelativeDirectoryPath = $_.DirectoryName.Replace($AbsoluteInputRootPath, '')
        $ItemAbsoluteDirectoryPath = $AbsoluteOutputRootPath + $ItemRelativeDirectoryPath
        
        #Cria o diretório do item no caso dele não existir
        if (-Not (Test-Path -Path $ItemAbsoluteDirectoryPath)) {
            Write-Host "Criando pasta: $($ItemAbsoluteDirectoryPath)"
            New-Item -ItemType directory -Path $ItemAbsoluteDirectoryPath
        }
        else {
            Write-Host "Pasta $($ItemAbsoluteDirectoryPath) ja criada"
        }

        #Define as chamadas de $Call
        $ItemInput = $_.FullName;
        $ItemRelativeFilePath = ($_.FullName).Replace($AbsoluteInputRootPath, '')
        $ItemOutput = $AbsoluteOutputRootPath + $ItemRelativeFilePath
        

        $Call.Invoke($ItemInput, $ItemOutput, $Params)
    }	                        
}