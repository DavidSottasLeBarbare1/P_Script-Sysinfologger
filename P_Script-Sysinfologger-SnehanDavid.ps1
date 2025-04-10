<#
.NOTES
    *****************************************************************************
    ETML
    Nom du script:	P_Script-Sysinfologger-SnehanDavid.ps1
    Auteur:	David Sottas et Snehan Gnanassorian
    Date:	03.04.2025
 	*****************************************************************************
    Modifications
 	Date  : -
 	Auteur: -
 	Raisons: -
 	*****************************************************************************
.SYNOPSIS
	Information succincte concernant l'utilité du script, comme un titre
 	
.DESCRIPTION
    Description plus détaillée du script, avec les actions et les tests effectuées ainsi que les résultats possibles
  	
.PARAMETER IP
    Description du premier paramètre avec les limites et contraintes
	
.PARAMETER Param2
    Description du deuxième paramètre avec les limites et contraintes
 	
.PARAMETER Param3
    Description du troisième paramètre avec les limites et contraintes

.OUTPUTS
	Ce qui est produit par le script, comme des fichiers et des modifications du système
	
.EXAMPLE
	.\CanevasV3.ps1 -Param1 Toto -Param2 Titi -Param3 Tutu
	La ligne que l'on tape pour l'exécution du script avec un choix de paramètres
	Résultat : par exemple un fichier, une modification, un message d'erreur
	
.EXAMPLE
	.\CanevasV3.ps1
	Résultat : Sans paramètre, affichage de l'aide
	
.LINK
    D'autres scripts utilisés dans ce script
#>

<# Le nombre de paramètres doit correspondre à ceux définis dans l'en-tête
   Il est possible aussi qu'il n'y ait pas de paramètres mais des arguments
   Un paramètre peut être typé : [string]$Param1
   Un paramètre peut être initialisé : $Param2="Toto"
   Un paramètre peut être obligatoire : [Parameter(Mandatory=$True][string]$Param3
#>
# La définition des paramètres se trouve juste après l'en-tête et un commentaire sur le.s paramètre.s est obligatoire 
param($IP, $Param2, $Param3)

###################################################################################################################
# Zone de définition des variables et fonctions, avec exemples
# Commentaires pour les variables
$Date = Get-Date
###################################################################################################################
# Zone de tests comme les paramètres renseignés ou les droits administrateurs

# Affiche l'aide si un ou plusieurs paramètres ne sont par renseignés, "safe guard clauses" permet d'optimiser l'exécution et la lecture des scripts
<# if(!$IP -or !$Credential -or !$Param3)
{
    Get-Help $MyInvocation.Mycommand.Path
	exit
} #>

###################################################################################################################
# Corps du script
Set-Item WSMan:\localhost\Client\TrustedHosts $IP -Force

$CIM = New-CimSession -ComputerName $IP

$ComputerName = (Get-CimInstance -CimSession $CIM -Class CIM_ComputerSystem).Name


$OS = (Get-CimInstance -CimSession $CIM -Class CIM_OperatingSystem).Version

$RAM = [math]::round((Get-CimInstance CIM_ComputerSystem).TotalPhysicalMemory / 1GB, 2)

$CPU = Get-CimInstance -Class CIM_Processor

$AppRunning  = (Get-CimInstance -CimSession $CIM -Class CIM_Product).name

$diskUsage = Get-CimInstance -CimSession $CIM -ClassName CIM_LogicalDisk | Where-Object {$_.DriveType -eq 3}

Write-Output("---------------------------------------------------------------------------------
|                                 SYSINFO LOGGER                                |
|-------------------------------------------------------------------------------|
| Log date:$Date`t`t`t`t`t`t`t|
---------------------------------------------------------------------------------`n
Name : $ComputerName`n`nOS Version : $OS`n`nRAM : $RAM`n`nCPU : $CPU`n`nProgram : $AppRunning`n`nDisk : $($diskUsage.DeviceID) $($diskUsage| ForEach-Object {"($($_.Size - $_.FreeSpace)* 100)/$_.Size%"})") >> sysloginfo.log  

Remove-CimSession -CimSession $CIM

# Ce que fait le script