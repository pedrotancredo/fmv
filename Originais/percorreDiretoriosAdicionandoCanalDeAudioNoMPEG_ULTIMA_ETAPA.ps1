param($driveOrigem,$driveDestino) # primeira linha

#Mede o tempo da execução da varredura
Measure-Command {


#verifica se já existe. Se não, cria
if(-Not (Test-Path -Path $driveDestino\TS_videos)) {
mkdir $driveDestino\TS_videos;

}

$extensaovideo=".mp4";
$pathVideos=$driveDestino+"\TS_videos\";
$pathAudios=$driveDestino+"\TS_audios\"

#itera a lista de diretórios na pasta
Get-ChildItem -Recurse -Path $driveOrigem\ -Exclude TS_* | where {$_.psiscontainer} | 
  ForEach-Object -Process {
	
		""
        #concatena o caminho completo para o destino
        $video=$pathVideos+$_.FullName.substring(3);

        #verifica se já existe. Se não, cria
        if(-Not (Test-Path -Path $video)) {
        "Criando pasta: " + $_.Name;
        New-Item -ItemType directory -Path $video
        }else {
             write-host("Pasta " + $_.Name + " já criada.")
            }
        
		""
}
 
        #itera a lista de arquivos na pasta
		Get-ChildItem -Recurse -Path $driveOrigem -File |
            ForEach-Object -Process {


           
            if($_.Extension -eq ".mp4") {

                #Verifica se existe seu homonimo em audio
               if(Test-Path -Path $pathAudios+$_.FullName.substring(3)+'.wav') {
                   
                    

                     "Arquivo a ser processado: "+$_.Name;
            
                    $destinovideo=$pathVideos+$_.FullName.substring(3);


                
                    #Verifica se Arquivo já existe, caso sim não reprocessa
                    if(Test-Path -Path $destinovideo'.mp4') {
                    
                                                         
                    $arquivoorigem=$pathAudios+$_.FullName.substring(3)+'.wav';
                    $arquivodestino=$destinovideo;

                    "Processando: " + $arquivodestino;

                    C:\ScriptsPowerShell\AdicionaCanalDeAudio.ps1 $arquivoorigem $arquivodestino

                    

                        #Do video    
                        }else {
                   
  
                                  "Arquivo "+ $destinovideo + " não existente! Não Processado." 
                        }

                #Do audio
                }else {
                 "Arquivo de audio "+ $_.FullName.substring(3) + " não existente! Não Processado."
                }


             }


            }	
            	
 
 }
 
