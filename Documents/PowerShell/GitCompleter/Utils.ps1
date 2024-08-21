$invokeErrors = New-Object -TypeName System.Collections.ArrayList -ArgumentList 256

function Invoke-Utf8ConsoleCommand([ScriptBlock]$cmd) {
    $currentEncoding = [Console]::OutputEncoding
    $errorCount = $global:Error.Count
    try {
        # A native executable that writes to stderr AND has its stderr redirected will generate non-terminating
        # error records if the user has set $ErrorActionPreference to Stop. Override that value in this scope.
        $ErrorActionPreference = 'Continue'

        try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch [System.IO.IOException] {}
        & $cmd
    }
    finally {
        try { [Console]::OutputEncoding = $currentEncoding } catch [System.IO.IOException] {}

        # Clear out stderr output that was added to the $Error collection, putting those errors in a module variable
        if ($global:Error.Count -gt $errorCount) {
            $numNewErrors = $global:Error.Count - $errorCount
            $invokeErrors.InsertRange(0, $global:Error.GetRange(0, $numNewErrors))
            if ($invokeErrors.Count -gt 256) {
                $invokeErrors.RemoveRange(256, ($invokeErrors.Count - 256))
            }
            $global:Error.RemoveRange(0, $numNewErrors)
        }
    }
}

