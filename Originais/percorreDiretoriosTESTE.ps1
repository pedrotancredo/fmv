$drive="i:"

"CaminhoDoArquivo;NomeDoArquivo;NomeSugerido" > lista.csv


#itera a lista de diretórios na pasta
Get-ChildItem -Recurse -Path $drive\ -Exclude TS_* | where {$_.psiscontainer} |
  ForEach-Object -Process {
	
		""
        #concatena o caminho completo para o destino
        $video=$_.FullName;

        "Pasta: " +$video;

        
		""
}
 
        #itera a lista de arquivos na pasta
		Get-ChildItem -Recurse -Path $drive'\' -File |
            ForEach-Object -Process {
"---------------------------------------------------------------"           
'BaseName:' + $_.BaseName
'Directory:' + $_.Directory
'DirectoryName:' + $_.DirectoryName
'FullName:' + $_.FullName.substring(2)
'Name:' + $_.Name
'Parent:' + $_.Parent
'Root:' + $_.Root
'Target:' + $_.Target
'self: '+$_.
"---------------------------------------------------------------"


            }	
            	
 
 
 
