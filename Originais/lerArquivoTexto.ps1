#Lendo um arquivo txt
$Text = Get-Content LTGUPMIC_T0274_T0295_P1.txt 
#Transformando as linhas do arquivo em um array 
$Text.GetType() | Format-Table -AutoSize
#Listando as linhas do arquivo

$clip=""
$deltaT=0.2

$filtro=$Text |where { $_ -match "Parsed_ebur128"}|where { $_ -notmatch "size"} |where { $_ -notmatch "Summary"} | %{$_ -replace "\s+"," "}

foreach ($element in $filtro) 
{ 
    $tempo=$element.Split(' ')[4]
     
    $ftpk=$element.Split(' ')[18]
    
   # $tempo , $ftpk

    if([double]$ftpk -ge -3.5 -and -not ([string]::IsNullOrEmpty($ftpk))){
   
      $clip+="volume=enable='between(t,$([double]($tempo-$deltaT)),$([double]$tempo+[double]$deltaT))':volume=0"
        
    }
  
   
   
}
$clip
$clip.Replace("0vo","0,vo")
