function Get-OMPlusClientData {
    $RegularPath    = 'HKLM:\SOFTWARE\PlusTechnologies\OMPlus'
    $x86Path        = 'HKLM:\SOFTWARE\Wow6432Node\PlusTechnologies\OMPlus'
    if (Test-Path -Path $RegularPath) {
        $OMClientPath = $RegularPath
    }
    elseif ( Test-Path -Path $x86Path) {
        $OMClientPath = $x86Path
    }
    else {
        return 'The OMPlus Client does not appear to be installed'
    }

    $ClientDir = Get-ItemProperty -Path $OMClientPath -Name pathdir | Select-Object -ExpandProperty pathdir 
    $FilePath = [System.IO.Path]::Combine($ClientDir, 'omplusjava', 'omplus.txt')
    Get-Content -Path $FilePath | ForEach-Object {
        $key, $value = $_ -split '\s', 2 
        [PSCustomObject]@{
            Key     = $key 
            Value   = $value
        }
    }
}