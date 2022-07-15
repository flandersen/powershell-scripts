<#
.SYNOPSIS
  Positions the main window of processes determined by name on different screens.
.DESCRIPTION
  The script determines the running processes by the specified names. Then, it moves the main window by 
.INPUTS
  None.
.Parameter ProcessName 
  Specifies the name of the processes whose main window is being moved. 
.OUTPUTS
  None.
.NOTES
  Version:        1.0
  Author:         Flandersen
  Creation Date:  15.07.2022
  Purpose/Change: Initial version.
.EXAMPLE
  You can run this script on system start up after the specified processes have been started.
  
  powershell .\Set-ProcessWindowPos.ps1 -ProcessName procexp64

  The following hides the powershell window from the user.
  powershell -WindowStyle hidden C:\scripts\Set-ProcessWindowPos.ps1 -ProcessName procexp64

  If the execution policy does not 
  powershell -WindowStyle hidden -ExecutionPolicy ByPass C:\scripts\Set-ProcessWindowPos.ps1 -ProcessName procexp64
#>

param (
  [string] $ProcessName
)

Import-Module .\Set-Window.ps1

Add-Type -AssemblyName System.Windows.Forms

$AllScreens = [System.Windows.Forms.Screen]::AllScreens
$LeftMostScreen = $AllScreens | Sort-Object -Property { $_.WorkingArea.X } | Select-Object -First 1
$RunningProcesses = Get-Process | Where-Object { $_.Name -eq $ProcessName }

if ($RunningProcesses.Count -gt $AllScreens.Count)
{
  Write-Error "More processes running than screens available." -ErrorAction Stop
}

$Count = 0
$X = $LeftMostScreen.WorkingArea.X
$Y = 0

foreach($Process in $RunningProcesses)
{
  $ScreenHeight = $AllScreens[$Count].WorkingArea.Height
  $ScreenWidth = $AllScreens[$Count].WorkingArea.Width
  
  if ($Count -gt 0)
  {
    $PrevScreenWidth = $AllScreens[$Count-1].WorkingArea.Width
    $X += $PrevScreenWidth
  }

  Set-Window -ProcessId $Process.Id -X $X -Y $Y -Width $ScreenWidth -Height $ScreenHeight -Passthru
  $Count++
}