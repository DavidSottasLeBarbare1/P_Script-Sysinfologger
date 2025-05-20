<#
.NOTES
    *****************************************************************************
    ETML
    Nom du script:	P_Script-Sysinfologger-SnehanDavid.ps1
    Auteur:	David Sottas et Snehan Gnanassorian
    Date:	03.04.2025
 	*****************************************************************************
    Modifications
 	Date  : 07.05.2025
 	Auteur: David
 	Raisons: Finalisation du script
 	*****************************************************************************
.SYNOPSIS
	Collecte d'informations système d'une machine distante
 	
.DESCRIPTION
    Création d'un fichier journal log contenant les informations systèmes de la machine distante tel que : 
    son nom, version de l'OS, l'utilisation du disque, capacité de la RAM, liste des programmes installés et les caractèristiques du CPU grâce à son adresse IP
  	
.PARAMETER IP
    IP de la machine distante. Elle sert à lancer la session CIM
	
.OUTPUTS
	Un fichier journal nommé sysloginfo.log contenant les informations.
	
.EXAMPLE
	
	Résultat : par exemple un fichier, une modification, un message d'erreur
	
.EXAMPLE
	.\P_Script-Sysinfologger-SnehanDavid.ps1 -IP 169.254.249.9

	Résultat : Il sera affiché dans le fichier .log : 
---------------------------------------------------------------------------------
|                                 SYSINFO LOGGER                                |
|-------------------------------------------------------------------------------|
| Log date: 05/06/2025 09:28:00						                        	|
---------------------------------------------------------------------------------

Name : PC2

OS Version : 10.0.19044

RAM : 4 GB

CPU : Win32_Processor : Intel64 Family 6 Model 167 Stepping 1 (DeviceID = "CPU0")

Program : VirtualBox PowerShell 7-x64 Microsoft Update Health Tools CIM Explorer

Disk : C: 64.13% S: 0.31% T: 0.25%
	
#>

# La définition des paramètres se trouve juste après l'en-tête et un commentaire sur le.s paramètre.s est obligatoire 
param($IP)
 
###################################################################################################################
# Zone de définition des variables et fonctions, avec exemples
# Commentaires pour les variables
$date = Get-Date -Format "yyyy.MM.dd hh:mm:ss"             #Variable pour la date et l'heure actuelle

###################################################################################################################
# Corps du script

# Vérifie de la version de powershell utilisée
#Requires -Version 7

if ($IP) {
    if (Test-Connection -ComputerName $IP -Count 1 -Quiet) {
        $cim = New-CimSession -ComputerName $IP
    }
    else {
        "$IP est injoignable"
    }
}
else {
    throw [System.Management.Automation.PSArgumentException]::New("Veuillez entrer une IP")
}

if (-not $cim) {
    throw [System.Management.Automation.PSInvalidCastException]::New("Machine injoignable")
}

$computerSystem = (Get-CimInstance -CimSession $cim -Class CIM_ComputerSystem)

$computerName = $computerSystem.Name

$os = (Get-CimInstance -CimSession $cim -Class CIM_OperatingSystem).Version

$ram = [math]::round($computerSystem.TotalPhysicalMemory / 1GB, 2)

$cpu = (Get-CimInstance -CimSession $cim -Class CIM_Processor).Name

$appsRunning = Get-CimInstance -CimSession $cim -Class CIM_Product

$diskUsage = Get-CimInstance -CimSession $cim -ClassName CIM_LogicalDisk | Where-Object { $_.DriveType -eq 3 }


Write-Output(
"---------------------------------------------------------------------------------
|`t`t`t`tSYSINFO LOGGER`t`t`t`t`t|
|-------------------------------------------------------------------------------|
| Log date: $date`t`t`t`t`t`t`t|
---------------------------------------------------------------------------------`n

Name : $computerName`n
OS Version : $os`n
RAM : $ram GB`n
CPU : $cpu`n
Programs : $($appsRunning | ForEach-Object {"$($_.Name), "})`n
Disk : $($diskUsage| ForEach-Object {"$($_.DeviceID) $($([math]::Round(($_.Size - $_.FreeSpace)/$_.Size * 100, 2)))%"})") >> sysloginfo.log

Remove-CimSession -CimSession $cim