param($driveOrigem,$driveDestino) # primeira linha

. ".\library.ps1"

#Mede o tempo da execução da varredura
Measure-Command {

#verifica se já existe. Se não, cria
if(-Not (Test-Path -Path $driveDestino\TS_videos)) {
mkdir $driveDestino\TS_videos;

}

#$extensaovideo=".mp4";
$pathVideos=$driveDestino+"\TS_videos\";

#itera a lista de diretórios na pasta
Get-ChildItem -Recurse -Path $driveOrigem\ -Exclude TS_* | Where-Object {$_.psiscontainer} | 
  ForEach-Object -Process {
	
		""
        #concatena o caminho completo para o destino
        $video=$pathVideos+$_.FullName.substring(3);

        #verifica se já existe. Se não, cria
        if(-Not (Test-Path -Path $video)) {
        "Criando pasta: " + $_.Name;
        New-Item -ItemType directory -Path $video
        }else {b
             write-host("Pasta " + $_.Name + " já criada.")
            }
        
		""
}
 
        #itera a lista de arquivos na pasta
		Get-ChildItem -Recurse -Path $driveOrigem -File |
            ForEach-Object -Process {
           
            if($_.Extension -eq ".ts") {
                "Arquivo a ser processado: "+$_.Name;
            
                $destinovideo=$pathVideos+$_.FullName.substring(3);


                
                #Verifica se Arquivo já existe, caso sim não reprocessa
                if(Test-Path -Path $destinovideo'.mp4') {
                    "Arquivo "+ $destinovideo + " já existente! Nada a ser feito."

                    
                }else {
                    $arquivoorigem=$_.FullName;
                    $arquivodestino=$destinovideo;
                    "Processa bin a partir de: " +$arquivoorigem +  " DESTINO: " + $arquivodestino;
                    # C:\ScriptsPowerShell\converterParaMPEG.ps1 $arquivoorigem $arquivodestino
                    # D:\OneDrive\Documentos\GitHub\fmv\percorreDiretoriosConvertendoParaMPEG.ps1 $arquivoorigem $arquivodestino
                    ConverteVideo $arquivoorigem $arquivodestino

                    
                }


             }


            }	
            	
 
 }
 
