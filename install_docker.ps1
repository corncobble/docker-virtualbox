$ErrorActionPreference = 'Stop'
$DockerVer = '20.10.22'
$DockerComposeVer = '2.15.1'

## Taken from: https://stackoverflow.com/a/69239861
function Add-Path {

  param(
    [Parameter(Mandatory, Position=0)]
    [string] $LiteralPath,
    [ValidateSet('User', 'CurrentUser', 'Machine', 'LocalMachine')]
    [string] $Scope 
  )

  Set-StrictMode -Version 1; $ErrorActionPreference = 'Stop'

  $isMachineLevel = $Scope -in 'Machine', 'LocalMachine'
  if ($isMachineLevel -and -not $($ErrorActionPreference = 'Continue'; net session 2>$null)) { throw "You must run AS ADMIN to update the machine-level Path environment variable." }  

  $regPath = 'registry::' + ('HKEY_CURRENT_USER\Environment', 'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment')[$isMachineLevel]

  # Note the use of the .GetValue() method to ensure that the *unexpanded* value is returned.
  $currDirs = (Get-Item -LiteralPath $regPath).GetValue('Path', '', 'DoNotExpandEnvironmentNames') -split ';' -ne ''

  if ($LiteralPath -in $currDirs) {
    Write-Verbose "Already present in the persistent $(('user', 'machine')[$isMachineLevel])-level Path: $LiteralPath"
    return
  }

  $newValue = ($currDirs + $LiteralPath) -join ';'

  # Update the registry.
  Set-ItemProperty -Type ExpandString -LiteralPath $regPath Path $newValue

  # Broadcast WM_SETTINGCHANGE to get the Windows shell to reload the
  # updated environment, via a dummy [Environment]::SetEnvironmentVariable() operation.
  $dummyName = [guid]::NewGuid().ToString()
  [Environment]::SetEnvironmentVariable($dummyName, 'foo', 'User')
  [Environment]::SetEnvironmentVariable($dummyName, [NullString]::value, 'User')

  # Finally, also update the current session's `$env:Path` definition.
  # Note: For simplicity, we always append to the in-process *composite* value,
  #        even though for a -Scope Machine update this isn't strictly the same.
  $env:Path = ($env:Path -replace ';$') + ';' + $LiteralPath

  Write-Verbose "`"$LiteralPath`" successfully appended to the persistent $(('user', 'machine')[$isMachineLevel])-level Path and also the current-process value."

}

## https://docs.docker.com/engine/install/binaries/#install-server-and-client-binaries-on-windows
Write-Host "Downloading and installing Docker (server and client binaries)..."
Start-BitsTransfer -Source "https://download.docker.com/win/static/stable/x86_64/docker-$DockerVer.zip" -Destination $Env:tmp\docker-$DockerVer.zip
Expand-Archive $Env:tmp\docker-$DockerVer.zip -DestinationPath $Env:ProgramFiles
Add-Path $Env:ProgramFiles\Docker
[Environment]::SetEnvironmentVariable("DOCKER_HOST", "tcp://localhost:2375", "User")

## https://docs.docker.com/compose/install/other/#on-windows-server
Write-Host "Downloading and installing Docker Compose..."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Start-BitsTransfer -Source "https://github.com/docker/compose/releases/download/v$DockerComposeVer/docker-compose-Windows-x86_64.exe" -Destination $Env:ProgramFiles\Docker\docker-compose.exe

Write-Host "Installation of Docker successful. Sign out and sign in for changes to take effect."
