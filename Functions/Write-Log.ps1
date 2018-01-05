###############################################################################################################
# Filename     :  Write-Log
# Autor        :  Julien MAZOYER
# Description  :  Ecrit des logs dans la console et dans un fichier simultanément
# 
###############################################################################################################

<#
    .SYNOPSIS
    Ecrit des logs dans la console et dans un fichier simultanément
                 
    .DESCRIPTION         
    Ecrit des logs dans la console et dans un fichier simultanément
                                 
    .EXAMPLE
    Write-Log -Level "INFO" -Message "Message d'info" -LogPath "C:\Windows\Temp\log.log"
    Write-Log -Level "WARN" -Message "Message d'avertissement" -LogPath "C:\Windows\Temp\log.log"
    Write-Log -Level "ERROR" -Message "Message d'erreur" -LogPath "C:\Windows\Temp\log.log"

    [11:26:05]  [INFO]    Message d'info
    [11:26:05]  [WARNING] Message d'avertissement
    [11:26:05]  [ERROR]   Message d'erreur

	.EXAMPLE  
        Logguer des étapes :

        Write-Log -Level "INFO" -Message "Message d'info" -LogPath "C:\Windows\Temp\log.log" -Step
        Write-Log -Level "STEPOK" -Message "Etape réussi !" -LogPath "C:\Windows\Temp\log.log"

        [11:28:18]  [INFO]    Message d'info    [Etape réussi !]


        Write-Log -Level "INFO" -Message "Message d'info" -LogPath "C:\Windows\Temp\log.log" -Step
        Write-Log -Level "STEPERROR" -Message "Etape en erreur" -LogPath "C:\Windows\Temp\log.log"

        [11:29:04]  [INFO]    Message d'info    [Etape en erreur]
#>

function Write-Log
{ 
    [CmdletBinding()] 
    Param 
    ( 
        [Parameter(Mandatory = $true, 
            ValueFromPipelineByPropertyName = $true)] 
        [ValidateNotNullOrEmpty()] 
        [Alias("LogContent")] 
        [string]$Message, 
 
        [Parameter(Mandatory = $true)] 
        [Alias('LogPath')] 
        [string]$Path, 

        [Parameter(Mandatory = $false)] 
        [switch]$Step, 
         
        [Parameter(Mandatory = $false)] 
        [ValidateSet("Error", "Warn", "Info", "StepOK", "StepError")] 
        [string]$Level = "Info" 
        
    ) 
 
    Begin
    { 
        
        $VerbosePreference = 'Continue'
    } 
    Process
    { 
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $FormattedHour = Get-Date -Format "HH:mm:ss" 

        # Creation du fichier de Log si celui ci n'existe pas
        if (!(Test-Path $Path))
        { 
            New-Item $Path -Force -ItemType File |Out-Null

            "#########################################################" | Out-File -FilePath $Path
            "ScriptName : $ScriptName"                                  | Out-File -FilePath $Path
            "Executed on : $FormattedDate"                              | Out-File -FilePath $Path
            "ComputerName: $env:COMPUTERNAME DOMAINE:$env:USERDOMAIN"   | Out-File -FilePath $Path
            "UserName : $env:USERNAME"                                  | Out-File -FilePath $Path
            "#########################################################" | Out-File -FilePath $Path

        } 
             
        # Affichage Console
        switch ($Level)
        { 
            'Error'
            {
                $LevelText = "ERROR  "
                Write-Host "[$FormattedHour] " -NoNewline
                Write-Host " [ERROR]  " -NoNewline -ForegroundColor Red
                Write-Host " $Message"

                # Ecriture vers le fichier
                "[$FormattedHour][$LevelText] $Message" | Out-File -FilePath $Path -Append 
            } 
            'Warn'
            { 
                $LevelText = "WARNING"
                Write-Host "[$FormattedHour] " -NoNewline
                Write-Host " [WARNING]" -NoNewline -ForegroundColor Yellow
                Write-Host " $Message"

                # Ecriture vers le fichier
                "[$FormattedHour][$LevelText] $Message" | Out-File -FilePath $Path -Append 
            } 
            'Info'
            {
                $LevelText = "INFO   "
                Write-Host "[$FormattedHour] " -NoNewline
                Write-Host " [INFO]   " -NoNewline -ForegroundColor Cyan
                if ($Step)
                {
                    Write-Host " $Message" -NoNewline
                    $script:StepMessage = $Message
                }
                else
                {
                    Write-Host " $Message"
                    # Ecriture vers le fichier
                    "[$FormattedHour][$LevelText] $Message" | Out-File -FilePath $Path -Append 
                } 
            }
            'StepOK'
            {
                $Line = "`t[$Message]"
                Write-Host $Line -ForegroundColor Green
                # Ecriture vers le fichier
                "[$FormattedHour][INFO   ] $StepMessage --> [$Line]" | Out-File -FilePath $Path -Append 
            }
            'StepError'
            {
                $Line = "`t[$Message]"
                Write-Host $Line -ForegroundColor Red
                # Ecriture vers le fichier
                "[$FormattedHour][INFO   ] $StepMessage --> [$Line]"  | Out-File -FilePath $Path -Append
            } 
        } 
    } 
    End
    { 
    } 
}



