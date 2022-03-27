# following the ms devblog https://devblogs.microsoft.com/scripting/use-powershell-to-get-the-number-of-the-week-of-the-year/

# get the weeknumber of a date
#$t = Get-Date -UFormat %V

$BasePath = "D:\github\fifty-two"
$Pictures = Get-ChildItem -Path $( Join-Path -Path $BasePath -ChildPath "src\pics\*" ) -Include *.jpg

$Shell = New-Object -ComObject Shell.Application
$ShellFolder = $Shell.Namespace($( Join-Path -Path $BasePath -ChildPath "src\pics" ))
#source: https://blog.jongallant.com/2021/03/organize-photos-powershell/

if (!($Pictures)) {
    Write-Host "No pictures to process."
    Write-Host "Exiting."
 }

foreach ($Pic in $Pictures) {
    #Create the File Object for the file property enumeration
    $ShellFile = $ShellFolder.ParseName($($Pic.Name))
   
    #Get creation time
    $exifDateTaken = ($ShellFolder.GetDetailsOf($ShellFile,12) -replace "`u{200e}") -replace "`u{200f}"
    if ($exifDateTaken) {
        $cw = $exifDateTaken | Get-Date -Uformat %V 
        } else {
        Write-Host "Could not get exif informations of $Pic.Name. Using the LastWriteTime."
        $cw = $Pic.LastWriteTime | Get-Date -Uformat %V
    }
    # Check if a week number even exists
    if (!$cw) {
        Write-Host "Could not get the week number of $Pic.Name"
        continue
    }

    Write-Host "Picture $Pic was taken in Week $cw"
    $pf = Join-Path -Path $BasePath -ChildPath "static" -AdditionalChildPath "images\week $cw"
    if (Test-Path -Path $pf) {
        if (Test-Path -Path $(Join-Path -Path $pf -ChildPath "*")) { 
            Write-Host "Folder $pf already contains pictures!"
            continue
        }
        Write-Host "Folder $pf already exists."   
    } else {
        New-Item -Path $pf -ItemType Directory | Out-Null
        Write-Host "Folder $pf created."
    }
    Move-Item -Path $Pic.PSPath -Destination $(Join-Path -Path $pf -ChildPath "week $cw.jpg")  | Out-Null
    Write-Host "Copied $Pic to $pf as week $cw.jpg"   
}
