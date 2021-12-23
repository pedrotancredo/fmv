$LibraryPath = ".\modules\powershell"
$Extension = ".ps1"

Get-ChildItem -Recurse -Path $LibraryPath -File -Include $Extension | ForEach-Object -Process {
    . $_.FullName
}