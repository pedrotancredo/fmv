$drive="i:"

"CaminhoDoArquivo;NomeDoArquivo;NomeSugerido;Tamanho;Extensão" > lista.csv



        #itera a lista de arquivos na pasta
		Get-ChildItem -Recurse -Path $drive -File |
            ForEach-Object -Process {
           
           
                

              $linha=$_.Directory.ToString() + ";" + $_.Name.ToString() + ";"+ $_.FullName.ToString() +";"+ $_.Length.ToString() +";"+ $_.Extension.ToString() +";";

                $linha.ToString() >> lista.csv;

                #"Arquivo a ser processado: "+$_.Name;
            
   

            


            }	
            	
 
 
 
