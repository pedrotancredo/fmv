$drive="o:"

"CaminhoDoArquivo;NomeDoArquivo;NomeSugerido" > lista.csv


#itera a lista de diretórios na pasta
Get-ChildItem -Recurse -Path $drive\ -Exclude TS_* | where {$_.psiscontainer} |
  ForEach-Object -Process {
	
		""
        #concatena o caminho completo para o destino
        $video=$_.Name;

        "Pasta: " +$video;

        

		""
 
 }
        #itera a lista de arquivos na pasta
		Get-ChildItem -Path $drive -File |
            ForEach-Object -Process {
           
            if($_.Extension -eq ".ts") {
                

              $linha=$_.Directory.ToString() + ";" + $_.Name.ToString() + ";"+ $_.FullName.ToString() +";";

                $linha.ToString() >> lista.csv;

                "Arquivo a ser processado: "+$_.Name;
            
   

             }


            }	
            	
 
 
 
