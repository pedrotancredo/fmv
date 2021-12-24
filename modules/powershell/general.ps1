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

    # A função Iterador tem como objetivo iterar recursivamente, executando a função informada em $Call,
    # sobre os arquivos no diretório raiz da entrada que atendam ao critério de extensão

    # $InputRootPath: Uma string contendo o caminho raiz onde se encontram os arquivos de entrada (pode ser absoluto ou relativo)
    #     $Extension: Uma lista de strings ou uma única string com espressões dotadas de wildcard cujo a correspondência indica os arquivos que serão processados pela $Call (Exemplo: *.ts')
    #         $$Call: Um bloco de código com a chamada da função que será aplicada aos arquivos iteráveis (Exemplo: $function:FMVVideo)
    #        $Params: Uma string contendo flags de parâmetros que são simplesmente repassados para a função indicada em $Call, 
    #                 para uma referência das flags existentes consultar a documentação da função (Exemplo: '-replace -debug -remove')

    param($InputRootPath, $Extension, [scriptblock]$Call, $OutputRootPath, $Params)
       
    # Cria o diretório raiz da saída no caso dele não existir
    if (-Not (Test-Path -Path $OutputRootPath)) { 

        New-Item -ItemType Directory -Path $OutputRootPath
        
    }
    
    $AbsoluteInputRootPath = Convert-Path $InputRootPath.TrimEnd('\')
    $AbsoluteOutputRootPath = Convert-Path $OutputRootPath.TrimEnd('\')

    Get-ChildItem -Recurse -Path $AbsoluteInputRootPath -File -Include $Extension | ForEach-Object -Process {

        Write-Host "------------------------------------"
        Write-Host "Arquivo a ser processado:"
        Write-Host $($_.FullName)

        $ItemAbsoluteDirectoryPath = $AbsoluteOutputRootPath + $_.DirectoryName.Replace($AbsoluteInputRootPath, '')
        
        # Cria o diretório do item no caso dele não existir
        if (-Not (Test-Path -Path $ItemAbsoluteDirectoryPath)) {
            Write-Host "Criando diretorio: $($ItemAbsoluteDirectoryPath)"
            New-Item -ItemType Directory -Path $ItemAbsoluteDirectoryPath
        }

        # Define as chamadas de $Call
        $ItemInput = $_.FullName;
        $ItemOutput = $AbsoluteOutputRootPath + $_.FullName.Replace($AbsoluteInputRootPath, '')

        $Call.Invoke($ItemInput, $ItemOutput, $Params)
    }	                        
}