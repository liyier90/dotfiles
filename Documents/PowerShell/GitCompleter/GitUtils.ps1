function Get-AliasPattern($cmd) {
    $aliases = @($cmd) + @(Get-Alias | Where-Object { $_.Definition -match "^$cmd(\.exe)?$" } | ForEach-Object Name)
    "($($aliases -join '|'))"
}
