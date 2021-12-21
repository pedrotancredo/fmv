#ffmpeg -ss 00:01:00 -i Data\2019\DRR\21-09-01\LTMMOEST.ts -t 00:01:00 -vf "yadif=2,scale=-2:720" -qscale:v 2 -r 1 Output\TS_frames\foo-%03d.jpeg
#ffmpeg -i Data\2019\DRR\21-09-01\LTMMOEST.ts -ss 00:01:00 -to 00:02:00 -vf "yadif=2,scale=-2:720" -qscale:v 2 -r 1 Output\TS_frames\bar-%03d.jpeg
#ffmpeg -i Data\2019\DRR\21-09-01\LTMMOEST.ts -r 1 -s WxH -f image2 Output\TS_frames\foo-%03d.jpeg
#ffmpeg -i Data\2019\DRR\21-09-01\LTMMOEST.ts -vf "yadif=1,scale=-2:720" -r 1 -f image2 Output\TS_frames\foo-%03d.jpeg



function FMVFrames {
    param($In, $Out, $Start, $Duration)

    #ffmpeg -ss $Start -i $In -t $Duration -vf "yadif=2,scale=-2:720" -qscale:v 2 -r 1 $Out
    ffmpeg -ss $Start -i $In -t $Duration -vf "yadif=2" -qscale:v 2 -r 1 $Out

}

foreach ($line in Get-Content .\string.txt) {
    #$In, $Out, $Start, $Duration = "Y:\2019\DRB\19-10-22\LTSMANIQ1_T0218_T0061.ts", "Output\TS_frames\bar#%03d.jpeg", "00:10:07", "00:01:02"
    $In, $Out, $Start, $Duration = Invoke-Expression $line
    FMVFrames $In $Out $Start $Duration
}