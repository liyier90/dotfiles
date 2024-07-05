#########
# Aliases
#########

New-Alias which Get-Command

###################
# PSReadline Config
###################

# Disable autocomplete suggestion
Set-PSReadlineOption -PredictionSource None

# Replace '\' with '/' on 'Shift+Enter' to makes paths work with bash
Set-PSReadLineKeyHandler -Chord Shift+Enter -ScriptBlock {
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

  $line = $line.Replace("\", "/")

  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert($line)
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

###############
# Custom prompt
###############

function prompt {
  $u_ = $Env:Username
  $h_ = $Env:UserDomain
  $git_ = $(git branch 2>$null | perl -ne 's/\* (.*)/\1/ && print $1')
  $w_ = $($executionContext.SessionState.Path.CurrentLocation)
  "`e[38;5;012m┌─[`e[01;32m$u_@$h_`e[38;5;012m][`e[01;33m$Env:CONDA_DEFAULT_ENV`e[38;5;012m][`e[38;5;4m$git_`e[38;5;012m][`e[38;5;63m$w_`e[38;5;012m]`n└─`e[38;5;27m$ `e[0m" ;
}

Register-ArgumentCompleter -Native -CommandName aws -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
        $env:COMP_LINE=$wordToComplete
        if ($env:COMP_LINE.Length -lt $cursorPosition){
            $env:COMP_LINE=$env:COMP_LINE + " "
        }
        $env:COMP_POINT=$cursorPosition
        aws_completer.exe | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
        Remove-Item Env:\COMP_LINE     
        Remove-Item Env:\COMP_POINT  
}

#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "$HOME\miniconda3\Scripts\conda.exe") {
    (& "$HOME\miniconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
}
#endregion

