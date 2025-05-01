#########
# Aliases
#########

Set-Alias -Name which -Value Get-Command
Set-Alias -Name vim -Value nvim

<#
.SYNOPSYS
    Invoke-LYCommandAsAdministrator runs a commands with elevated permissions
    of the Administrator.
.DESCRIPTION
    When running Invoke-LYCommandAsAdministrator, or using the its "sudo"
    alias, the command identified will be executed in another PowerShell
    process which will run as the Administrator.

    You will be asked for permission to use the elevated context by the UAC.
.PARAMETER Command
    The command to be run with elevated permissions. If the special value "!!"
    is used, executes the previous command without waiting for the new process
    to complete before returning control. The new PowerShell process does not
    exit automatically.
.PARAMETER NoExit
    Aliases: noe
    When used, the elevated shell does not close after completing the command.
.PARAMETER WaitForCompletion
    Aliases: wfc
    When used, blocks the current shell until the elevated shell completes the
    command and exits.
.PARAMETER CommandLine
    Collects the rest of the command line to be run with `Command`.
.NOTES
    Command Alias: "sudo"
#>
function Invoke-LYCommandAsAdministrator {
    [CmdletBinding()]
    [Alias("sudo")]
    param (
        [Parameter(Position=0)]
        [String]$Command,
        [Alias("noe")]
        [Switch]$NoExit,
        [Alias("wfc")]
        [Switch]$WaitForCompletion,
        [Parameter(ValueFromRemainingArguments=$true)]
        [String[]]$CommandLine
    )
    begin {
        $PowerShellEdition = $PSVersionTable["PSEdition"]
        $ParsedCommandLine = ""
        switch ($Command) {
            "!!" { $ParsedCommandLine = (Get-History | Select-Object -Last 1).CommandLine }
            default { $ParsedCommandLine = ($Command + " " + ($CommandLine -join " ")).Trim() }
        }
        if ([String]::IsNullOrWhiteSpace($ParsedCommandLine)) {
            $ParsedCommandLine = 'Write-Host "Administrative Shell launched from sudo"'
            $NoExit = $true
        }
        if ($NoExit) {
            $NoExitValue = "-NoExit"
            $ExitMessage = "needs to be manually closed"
        } else {
            $NoExitValue = ""
            $ExitMessage = "will automatically close"
        }
        if ($WaitForCompletion) {
            $WaitMessage = "wait until the shell closes"
        } else {
            $WaitMessage = "continue after launching the shell"
        }
        [String]$LogMessage = ("Executing {0}. The calling code will {1}. The shell will {2}." -f $ParsedCommandLine, $WaitMessage, $ExitMessage)
        Write-Verbose $LogMessage
    }
    process {
        switch ($PowerShellEdition) {
            "Core" { Start-Process -FilePath pwsh.exe -ArgumentList ($NoExitValue + " -Command " + $ParsedCommandLine) -Wait:$WaitForCompletion -Verb RunAs }
            "Desktop" { Start-Process -FilePath powershell.exe -ArgumentList ($NoExitValue + " " + $ParsedCommandLine) -Wait:$WaitForCompletion -Verb RunAs }
        }
    }
}

<#
.SYNOPSYS
    Enter-LYVenv activates the local venv enironment if present.
.DESCRIPTION
    When running Enter-LYVenv, or using the its "activate" alias, the .venv
    virtual environment found in the invokation directory will be activated.

    Displays a warning if no .venv is found.
.NOTES
    Command Alias: "activate"
#>
function Enter-LYVenv {
    [CmdletBinding()]
    [Alias("activate")]
    param ()
    process {
        $venvPath = ".venv"
        $activateScript = Join-Path -Path $venvPath -ChildPath "Scripts\activate.ps1"

        if ((Test-Path $venvPath -PathType Container) -and (Test-Path $activateScript)) {
            & $activateScript
        } else {
            Write-Warning "No .venv folder with an activate script found in the current directory."
        }
    }
}

###################
# PSReadline Config
###################

# Disable autocomplete suggestion
Set-PSReadlineOption -PredictionSource None

$OnViModeChange = [ScriptBlock]{
  if ($args[0] -eq 'Command') {
    Write-Host -NoNewLine "`e[1 q"
  } else {
    Write-Host -NoNewLine "`e[5 q"
  }
}
Set-PSReadlineOption -Editmode Vi
Set-PSReadlineOption -ViModeIndicator Script -ViModeChangeHandler $OnViModeChange

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

Set-PSReadLineKeyHandler -Chord Ctrl+Alt+p -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Chord Ctrl+Alt+n -Function HistorySearchForward

Set-PSReadLineKeyHandler -Chord Ctrl+Alt+p -ViMode Command -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Chord Ctrl+Alt+n -ViMode Command -Function HistorySearchForward

# Bash style completion
Set-PSReadLineKeyHandler -Key Tab -Function Complete

#######################
# Environment Variables
#######################
$env:VIRTUAL_ENV_DISABLE_PROMPT = $true

###############
# Custom prompt
###############

function prompt {
  $u_ = $Env:Username
  $h_ = $Env:UserDomain
  $e_ = if ($env:VIRTUAL_ENV_PROMPT -ne $null) { $env:VIRTUAL_ENV_PROMPT } else { $env:CONDA_DEFAULT_ENV }
  $git_ = $(git branch 2>$null | perl -ne 's/\* (.*)/\1/ && print $1')
  $w_ = $($executionContext.SessionState.Path.CurrentLocation)
  $osc7_ = ""
  if ($w_.Provider.Name -eq "FileSystem") {
      $AnsiEscape = [char]27
      $ProviderPath = $w_.ProviderPath -Replace "\\", "/"
      $osc7_ = "$AnsiEscape]7;file://${Env:COMPUTERNAME}/${ProviderPath}${AnsiEscape}\"
  }
  "${osc7_}`e[38;5;012m┌─[`e[01;32m$u_@$h_`e[38;5;012m][`e[01;33m$e_`e[38;5;012m][`e[38;5;4m$git_`e[38;5;012m][`e[38;5;63m$w_`e[38;5;012m]`n└─`e[38;5;27m$ `e[0m" ;
}

#############
# Third party
#############

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

. $PSScriptRoot\GitCompleter\EntryPoint.ps1

#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "$HOME\miniforge3\Scripts\conda.exe") {
    (& "$HOME\miniforge3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
}
#endregion

