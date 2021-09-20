#Accept input paramenters 
param(
[string]$UserName, 
[SecureString]$Password, 
[switch]$MFA,
[int]$Action
) 


$Version = "v1.8.0"
<#
    .ZUSAMMENFASSUNG
    Überprüft eine definierte Datenbank ob das Feld INT_Todo = 1 ist und legt diese Benutzer an - Setzt danach das Feld auf 0 und füllt das Feld 'AngelegtAm' mit dem CurrentDate()
    Legt zwei Logdateien unter C:\Logs an. Ein Errorlog für's Debuggen und ein Userlog [Userlog wird überlegt, ob es benötigt wird]


    .MODULE
    - Active Directory | User wird im AD mit allen Informationen angelegt [inkl. Kopieren einer Vorlage für die Gruppen]
    - Exchange | User wird im Exchange mit allen Informationen angelegt [Verbesserung: Datenbankauswahl]
    - Fileserver | User wird auf einem Fileserver mit erweiteren Freigaben angelegt
    - Dispotool | User wird im Dispotool angelegt (Datenbankverbindung von Frank)
    - myTime | siehe Dispotool
    - Teams & Telefonie | Leider durch die Verzögerung der Lizenzen nicht möglich. Wird trotzdem für die Nummernzuweisung benutzt
    - Office Lizenz | Möglichkeit zum Hinzufügen von einer Office Lizenz, sollte er keine Teams Lizenz bekommen
    - Verteiler Intern_Handy Abfrage | Automatisches Hinzufügen zum Mailverteiler "Intern_Mobilfunk", wenn der User ein Handy bekommt
    - Ticket wird erstellt | Zammad API läuft am 04.22 aus. Vorher neues Token erstellen
    - Excelsheet wird zur Doku erstellt
    
    
    .HÄNDISCHE ANLAGE
    Docuware [X] - Keine Möglichkeit Archiv, Briefkorb & Importjob anzulegen | TODO auf dem MAGVDW01 einen Ordner erstellen
    Mailstore [X] - Keine Möglichkeit 
    CO [X] - Keine Möglichkeit
    
        
    .CHANGELOG
    1.2.0 - Dokumentation ExcelSheet (not tested yet live & with multiple users)
    1.2.1 - Ticket wird erstellt (not tested yet live & with multiple users)
    1.3.0 - Implentierung Testumgebung myTime & Ressourcenmanagement
    1.4.0 - Code gesäubert und Errorlogging eingeführt
    1.5.0 - BUGFIXES Fileserver
    1.6.0 - Tourenplanung & myTime auf Liveservern
    1.7.0 - versch. Standorte
    1.8.0 - $SQLUpdate = "UPDATE dbo.MAG_Stammdaten SET INT_TODO = 2, AngelegtAM = GETDATE(), AngelegtVon = '$($SQLAngelegtVon)' WHERE Username = '$($newUserID.sAMAccountName)'" 

    
    .TODO
    Log mit Rufnummer an Zentrale, Yvonne und IT (AD Gruppe erstellen für Empfänger)
    OU Verschiebung bei Monteuren
    Daten
    ggf. Script in verschiedene Module splitten, um einzeln Auszuführen


    .CRITICAL BUGS
    Userlog wird nicht abgeschnitten [wird wahrscheinlich entfernt]
    Teams Telefonie funktioniert nicht, da die Sync zu langsam ist für die Befehle
#>

$otitle = $host.ui.RawUI.WindowTitle
$host.ui.RawUI.WindowTitle = "merTens Admin Tool $Version"
                                                                                             
#VARIABLEN LOGIN
$ExchangeServer = "MAGVEX02"
$DCServer = "MAGVDC02"
$FileServer = "MAGVFS02"
$DWServer = "MAGVDW01"
$User = "mag\administrator"
$Pwd = Read-Host -AsSecureString "Bitte geben Sie das Adminkennwort ein, um sich mit allen benötigten Servern zu verbinden"
$SecCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $pwd
Clear-Host
#region Connections

#region DCCon
#Verbindung mit Domaincontroller
if (!(Get-PSSession | Where-Object { $_.ConfigurationName -eq "Microsoft.PowerShell" })) 
{ 
    Write-Host "      Verbinden zum Domaincontroller:" -NoNewline
    $DCSession = New-PSSession -ComputerName $DCServer -Credential $SecCred
    Import-PSSession $DCSession -Module ActiveDirectory -ErrorAction SilentlyContinue -AllowClobber > $null
    if($DCSession -ne $null)
    {
        Write-Host " Done!" -ForegroundColor Green
    }
    else
    {
        Write-Host " Error!" -ForegroundColor Red
        $error[0]
    }            
}
else
{
    Write-Host "      $DCServer ist bereits verbunden - Skipping ..." -ForegroundColor Green
}
#endregion DCCon

#region EXCon
#Verbindung mit Exchange
if (!(Get-PSSession | Where-Object { $_.ConfigurationName -eq "Microsoft.Exchange" }))
{
    Write-Host "      Verbinden zum Exchangeserver:" -NoNewline
    $EXSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$ExchangeServer/PowerShell/ -Credential $SecCred -Authentication Kerberos 
    Import-PSSession $EXSession -DisableNameChecking -AllowClobber -ErrorAction SilentlyContinue > $null 
    if($EXSession -ne $null)
    {
        Write-Host " Done!" -ForegroundColor Green
    }
    else
    {
        Write-Host " Error!" -ForegroundColor Red
        $error[0]
    }
}
else
{
    Write-Host "      $ExchangeServer ist bereits verbunden - Skipping ..." -ForegroundColor Green
}
#endregion EXCon

#region FSCon
#Verbindung mit FileServer für Benutzerdaten
if (!(Get-CimSession | Where-Object { $_.ComputerName -eq $FileServer }))
{
    Write-Host "      Verbinden zum Fileserver:" -NoNewline
    $FSSession = New-CimSession -ComputerName $FileServer -Credential $SecCred
    $FSSession > $null
    If($FSSession -ne $null)
    {
        Write-host " Done!" -ForegroundColor Green
    }
    else
    {
        Write-Host " Error!" -ForegroundColor Red
        $error[0]
    }
}
else
{
    Write-Host "      $FileServer ist bereits verbunden - Skipping ..." -ForegroundColor Green
}

#endregion FSCon


#region DWServerCon
#Verbindung mit DocuwareServer für Importjobs
if (!(Get-CimSession | Where-Object { $_.ComputerName -eq $DWServer }))
{
    Write-Host "      Verbinden zum DW Server:" -NoNewline
    $DWSession = New-CimSession -ComputerName $DWServer -Credential $SecCred
    $DWSession > $null
    If($DWSession -ne $null)
    {
        Write-host " Done!" -ForegroundColor Green
    }
    else
    {
        Write-Host " Error!" -ForegroundColor Red
        $error[0]
    }
}
else
{
    Write-Host "      $DWServer ist bereits verbunden - Skipping ..." -ForegroundColor Green
}

#endregion DWServerCon

#region TEAMSCon
#Verbindung mit Teams
$Module=Get-Module -Name MicrosoftTeams -ListAvailable 
if($Module.count -eq 0)
{
    Write-Host MicrosoftTeams module is not available  -ForegroundColor yellow 
    $Confirm= Read-Host Are you sure you want to install module? [J] Ja [N] Nein
    if($Confirm -match "[jJ]")
    {
        Install-Module MicrosoftTeams
    }
    else
    {
        Write-Host MicrosoftTeams module is required.Please install module using Install-Module MicrosoftTeams cmdlet.
        Exit
    }
}

Write-Host "      Verbinden zu Teams: " -NoNewline
#Autentication using MFA
if($mfa.IsPresent)
{
    $Team=Connect-MicrosoftTeams
    $sfboSession = New-CsOnlineSession -Credential $Credential
    Import-PSSession $sfboSession -AllowClobber > $null
}

#Authentication using non-MFA
else
{
    #Storing credential in script for scheduling purpose/ Passing credential as parameter
    if(($UserName -ne "") -and ($Password -ne ""))
    {
        $SecuredPassword = ConvertTo-SecureString -AsPlainText $Password -Force
        $Credential  = New-Object System.Management.Automation.PSCredential $UserName,$SecuredPassword
        $Team=Connect-MicrosoftTeams -Credential $Credential
        $sfboSession = New-CsOnlineSession -Credential $Credential
        Import-PSSession $sfboSession -AllowClobber > $null
    }
    else
    {  
        $Team=Connect-MicrosoftTeams
        $sfboSession = New-CsOnlineSession -Credential $Credential
        Import-PSSession $sfboSession -AllowClobber > $null
    }
}

#Check for Teams connectivity
If($Team -ne $null)
{
    Write-host " Done!" -ForegroundColor Green
}
else
{
    Write-Host " Error!" -ForegroundColor Red
    $error[0]
}
#endregion TEAMSCon
#endregions Connections



#-----------------------------------Globale Variablen-----------------------------------#
#region globalVars
$ExecutingUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$Date = get-date -format "dd-MM-yyyy-HH_mm"
$SQLServer = "MAGVSQ03"
$SQLDBName = "MAG_Mitarbeiter"
#$SQLSecurity = "Integrated Security = false"
$SQLSelect = "SELECT * FROM dbo.MAG_Stammdaten WHERE INT_TODO = 1"
$SQLUsername = "MAG-RO"
$SQLPassword = "N49@nM_1Du"
$SQLAngelegtVon = $ExecutingUser
$SQLAngelegtProg = "Powershell Script $Version"

$RetentionPolicy = "Default MRM Policy" #Exchange Aufbewahrungsrichtlinie
$EXDB1 = "merTensAG01"
$EXDB2 = "merTensAG02"

$SMTPServer = "mail.mertens.ag"
$logMailEmpfang = "d.artz@mertens.ag"
$logMailSender = "d.artz@mertens.ag"
$logMailBetreff = "Neuer Mitarbeiter"

$Global:PhoneExtension = @()

$logFile = "C:\Logs\userlog.txt"
If (Test-Path $logFile) 
{
}
Else 
{
    Start-Sleep 1
    New-Item -Path "$logFile" -ItemType Directory | Out-Null
}


$ADTargetOU = "OU=Teams,OU=Willich,OU=Mitarbeiter,OU=Benutzer,OU=merTens,DC=mertens,DC=ag"
$TemplateOU = "OU=Templates,OU=Benutzer,OU=merTens,DC=mertens,DC=ag"
$ADTargetOU_WB = "OU=Teams,OU=Wiesbaden,OU=Mitarbeiter,OU=Benutzer,OU=merTens,DC=mertens,DC=ag"
$ADTargetOU_GB = "OU=Teams,OU=Berlin,OU=Mitarbeiter,OU=Benutzer,OU=merTens,DC=mertens,DC=ag"
$ADTargetOU_BER = "OU=Teams,OU=Berlin,OU=Mitarbeiter,OU=Benutzer,OU=merTens,DC=mertens,DC=ag"
$ADTargetOU_AreaOffice = "OU=Teams,OU=AreaOFFICE,OU=Mitarbeiter,OU=Benutzer,OU=merTens,DC=mertens,DC=ag"
$ADTargetOU_MONTAGE = "OU=Teams,OU=Monteure,OU=Mitarbeiter,OU=Benutzer,OU=merTens,DC=mertens,DC=ag"
$ADTargetOU_Finance = "OU=Teams,OU=Finanzbuchhaltung,OU=Willich,OU=Mitarbeiter,OU=Benutzer,OU=merTens,DC=mertens,DC=ag"
$OfficeOU = "OU=Officegruppen,OU=Sicherheitsgruppen,OU=Gruppen,OU=merTens,DC=mertens,DC=ag"

$Template_Willich = @("Vorlage.AM", "Vorlage.KAM", "Vorlage.CWPD", "Vorlage.Montage", "Vorlage.Dispo")
$Template_Berlin = @("Vorlage.Berlin")
$Template_WB = @("Vorlage.WB")
$Template_AreaOffice = @("Vorlage.AreaOffice")

$Username = @()
$UniqueUserName = @()
$UsernameSAMNoSpecial = @() #Array für den SAMAccountNamen ohne Sonderzeichen
$FirstNameNoSpecial = @() #Array für den Vornamen ohne Sonderzeichen
$LastNameNoSpecial = @() #Array für den Nachnamen ohne Sonderzeichen
$StellenbeschreibungNoSpecial = @()
$EmailAddress = @()
$PrimaryEmailDomain = "@mertens.ag"
$DomainName = "mag"
$TempPassword = "merTens0815"
$DefaultAddress = "Stahlwerk Becker 8"
$DefaultState = "NRW"
$DefaultZip = "47877"
$DefaultCountry = "DE"
$DefaultCity = "Willich"
$DefaultCompany = "merTens AG"
$FileServer = "\\magvfs02\maguser$"
$DWServer = "\\magvdw01"
$wWWHomePage = "www.mertens.ag"
$DefaultOffice = "Experience- & InnovationCENTER Willich"
$ErrorActionPreference = 'SilentlyContinue'
#endregion GlobalVars
#-----------------------------------Globale Variablen Ende------------------------------#


#-----------------------------------Errorlog schreiben----------------------------------#
$errorLog = "C:\Logs\"
$errorFile = "Errorlog.txt"
Write-Host "      Errorlog wird erstellt unter: $errorLog$errorFile - " -NoNewline
[System.IO.Directory]::CreateDirectory('C:\Logs\') > $null
if(!(Test-Path -Path "$errorLog$errorFile"))
{
    New-Item $errorlog$errorFile -ItemType File -ErrorAction SilentlyContinue | Out-Null
    "-Start-- $Date ---------------------------------------" | Add-Content "$errorLog$errorFile"
    Write-Host " Done" -ForegroundColor Green
}
else
{
    New-Item $errorlog$errorFile -ItemType File -ErrorAction SilentlyContinue | Out-Null
    "-Start-- $Date ---------------------------------------" | Add-Content "$errorLog$errorFile"
    Write-Host " Done" -ForegroundColor Green
}

#-----------------------------------Errorlog schreiben Ende----------------------------#

#-----------------------------------Löschen des Logfiles | Kann auskommentiert werden, wenn man ALLE Meldungen im Logfile behalten möchte------------------------------#
del $logFile -ErrorAction Ignore #Logfile ist für Yvonne, IT, Zentrale (Daten über User)

#--------------------------------Verbindung zum SQL Server und Query------------------#
#region SQL Connect
try
{
    Write-Host "      SQL Verbindung wird aufgebaut:" -NoNewline
    $SqlCon = New-Object System.Data.SqlClient.SqlConnection
    $SqlCon.ConnectionString = "Server=$SQLServer;uid=$SQLUsername; pwd=$SQLPassword;Database=$SQLDBName"
    $SqlCon.Open()
    
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.Connection = $SqlCon
    $SqlCmd = $SqlCon.CreateCommand()
    $SqlCmd.CommandText = $SQLSelect
    
    $Result = $SqlCmd.ExecuteReader()
    $Table = New-Object System.Data.DataTable
    $Table.Load($Result)
    Write-Host " Done" -ForegroundColor Green
}
Catch
{
    Write-Host " Error" -ForegroundColor Red
    $error[0] | Add-Content "$errorLog$errorFile"
    exit
}   
#endregion SQL Connect
#--------------------------------Verbindung zum SQL Server und Query Ende------------------#
#cls
#----------------------------------------------------Create User Start------------------------------------------------------#
foreach($Item in $Table)
{
    $Eintrittsdatum = $Item.Eintrittsdatum
    $Eintrittsdatum_short = Get-Date $Eintrittsdatum -Format dd.MM.yyyy
    $Stellenbeschreibung = $Item.Stellenbeschreibung
    
    #Array für die Userdaten
    $newUserID=@{
        Name = $Item.Vorname + " " + $Item.Nachname
        DisplayName = $Item.Vorname+" "+$Item.Nachname
        sAMAccountName = $Item.Username
        GivenName = $Item.Vorname
        Surname = $Item.Nachname
        StreetAddress = $DefaultAddress
        City = $DefaultCity
        State = $DefaultState
        Description = $Item.Stellenbeschreibung
        Title = $Item.Stellenbeschreibung
        PostalCode = $DefaultZip
        UserPrincipalName = $Item.Email
        Company = $DefaultCompany
        Email = $Item.Email
        Homepage = $wWWHomePage
        Office = $DefaultOffice
        Path = $ADTargetOU
        Country = $DefaultCountry
    }

    Try
    {   
        #Uservariables   
        $LastName = $newUserID.Surname
        $FirstName = $newUserID.GivenName
        $UniqueUserName = $newUserID.sAMAccountName
        $UniqueDisplayName = $newUserID.DisplayName
        $EmailAddress = $newUserID.Email 
        $FirstNameNoSpecial = $Firstname.replace('ä','ae').Replace('Ä','Ae').Replace('ö','oe').Replace('Ö','Oe').Replace('ü','ue').Replace('Ü','Ue').Replace('ß', 'ss')
        $LastNameNoSpecial = $LastName.replace('ä','ae').Replace('Ä','Ae').Replace('ö','oe').Replace('Ö','Oe').Replace('ü','ue').Replace('Ü','Ue').Replace('ß', 'ss')
        $StellenbeschreibungNoSpecial = $Stellenbeschreibung.replace('ä','ae').Replace('Ä','Ae').Replace('ö','oe').Replace('Ö','Oe').Replace('ü','ue').Replace('Ü','Ue').Replace('ß', 'ss')
               
        Write-Host "`n`n"
        Write-Host "      Folgender User wird jetzt erstellt: $($newUserID.GivenName) $($newUserID.Surname) | $($newUserID.Email) | $($newUserID.Description) | NB: $(if($Item.Notebook -eq 1){"Ja"}else{"Nein"}) | Handy: $(if($Item.Handy -eq 1){"Ja"}else{"Nein"})" -BackgroundColor Black -ForegroundColor Cyan



#----------------------------------------------------Funktion: Kopiert die Usergruppen von einem Template Start------------------------------------------------#            
        #region Usercopy       
        $UserPrincipleName = $EmailAddress 
        Write-Host "`n      Wählen sie eins der verfügbaren Templates aus, um die Gruppen zu kopieren `r`n"
        $Templates = Get-ADUser -Filter * -SearchBase $TemplateOU | Select -ExpandProperty SAMAccountName | Sort-Object -Property SAMAccountName
        Get-ADUser -Filter * -SearchBase $TemplateOU | Select -ExpandProperty SAMAccountName | Sort-Object -Property SAMAccountName
        $UserTemplateCopyFrom = (Read-Host -Prompt "`r`nWelchen Account möchten Sie gerne kopieren? | Leer lassen, um keine Gruppen zu kopieren.")
        
        function TemplateUserCheck 
        {
            $UserTemplateCheck = Get-ADUser -SearchBase $TemplateOU -Filter "SamAccountName -like '$UserTemplateCopyFrom'"
            if ($UserTemplateCheck = [string]::IsNullOrWhiteSpace($UserTemplateCheck))
            {            
                Write-Warning "Es wurden keine Gruppen kopiert. Bitte prüfen sie die Gruppen später manuell im AD"
            }
            else
            {
                Write-Host "Gruppen erfolgreich kopiert" -ForegroundColor Green           
            }
        }
        TemplateUserCheck
        #endregion Usercopy

        if($UserTemplateCopyFrom = 'Vorlage.Finance')
        {
            $newUserID.Path = $ADTargetOU_Finance
        }
        else
        {
            continue
        }

        if($UserTemplateCopyFrom = 'Vorlage.Montage')
        {
            $newUserID.Path = $ADTargetOU_Montage
        }
        else
        {
            continue
        }

        
        #region Officeauswahl
        Write-Host ""
        Write-Host "1. Willich" -ForegroundColor Cyan
        Write-Host "2. Berlin" -ForegroundColor Cyan
        Write-Host "3. Großbeeren" -ForegroundColor Cyan
        Write-Host "4. Wiesbaden" -ForegroundColor Cyan
        Write-Host "5. AreaOffice" -ForegroundColor Cyan
        Write-Host ""
        $NewOffice = Read-Host "In welchem Office wird der Mitarbeiter tätig sein (1-5)? Leer lassen für $($DefaultOffice)" 

        switch($NewOffice)
        {
           1{  
                $newUserID.StreetAddress = $DefaultAddress
                $newUserID.City = $DefaultCity
                $newUserID.State = $DefaultState
                $newUserID.PostalCode = $DefaultZip
                $newUserID.Office = $DefaultOffice
                $newUserID.Path = $ADTargetOU
            }

           2{
                $newUserID.StreetAddress = "Stresemannstraße 65"
                $newUserID.City = "Berlin"
                $newUserID.State = "Berlin"
                $newUserID.PostalCode = "10963"
                $newUserID.Office = "Business- & InspirationOFFICE Hauptstadtquartier"
                $newUserID.Path = $ADTargetOU_BER
            }

           3{
                $newUserID.StreetAddress = "Am Wall 4"
                $newUserID.City = "Großbeeren"
                $newUserID.State = "Brandenburg"
                $newUserID.PostalCode = "14979"
                $newUserID.Office = "Business- & InspirationOFFICE Großbeeren"
                $newUserID.Path = $ADTargetOU_GB
            }

           4{
                $newUserID.StreetAddress = "Mainzer Strasse 97"
                $newUserID.City = "Wiesbaden"
                $newUserID.State = "Hessen"
                $newUserID.PostalCode = "65189"
                $newUserID.Office = "Business- & InspirationOFFICE Wiesbaden"
                $newUserID.Path = $ADTargetOU_WB
            }

           5{
                $newUserID.StreetAddress = $DefaultAddress
                $newUserID.City = $DefaultCity
                $newUserID.State = $DefaultState
                $newUserID.PostalCode = $DefaultZip
                $newUserID.Office = "AreaOFFICE"
                $newUserID.Path = $ADTargetOU_AreaOffice
            }

     default{
                $newUserID.StreetAddress = $DefaultAddress
                $newUserID.City = $DefaultCity
                $newUserID.State = $DefaultState
                $newUserID.PostalCode = $DefaultZip
                $newUserID.Office = $DefaultOffice
                $newUserID.Path = $ADTargetOU
            }
        }
        #endregion Officeauswahl

#----------------------------------------------------Funktion: Kopiert die Usergruppen von einem Template Ende-------------------------------------#

        #Erstellt den User
        New-ADUser @newUserID -ErrorAction SilentlyContinue -AccountPassword (ConvertTo-SecureString $TempPassword -AsPlainText -Force) -Passthru > $null
        Write-Host "`r`n      PLASE WAIT 15 Seconds! Erstelle User & Mailbox...: " -NoNewline
        Enable-ADAccount -Identity $UniqueUserName -ErrorAction SilentlyContinue > $null
        Start-Sleep -Seconds 15
        Enable-Mailbox -Identity $UserPrincipleName -Database $EXDB1 > $null
        #Create new email address based on companies defaults
        Set-Mailbox $UserPrincipleName -EmailAddresses @{add=$EmailAddress} -EmailAddressPolicyEnabled $False > $null
        #Set email retention policies
        Set-Mailbox $UserPrincipleName -PrimarySmtpAddress $EmailAddress -RetentionPolicy $RetentionPolicy > $null
        #Disable Active Sync
        Set-CasMailbox -Identity $UserPrincipleName  -ActiveSyncEnabled $true > $null
        
        Write-Host " $($newUserID.sAMAccountName) erstellt!" -ForegroundColor green
        "Der User: $($newUserID.sAMAccountName) wurde erstellt! `r`n Telefonnummer: $($newUserID.Telephone) `r`n Position: $($newUserID.Description) `r`n Beginn: $Eintrittsdatum_short `r`n Notebook: $($Item.Notebook) `r`n Handy: $($Item.Handy)" >> $logFile
         $_ >> $logFile
        
        #Kopieren des Templates auf den User
        get-ADuser -identity $UserTemplateCopyFrom -properties memberof | select-object memberof -expandproperty memberof | Add-AdGroupMember -Members $newUserID.sAMAccountName

   
#----------------------------------------------------Create Home Drive Start------------------------------------------------#
        #region Home Drive
        
        try
        {
            Write-Host "      Creating Home Drive:" -NoNewline
            $UniqueUserNameLower = $UniqueUserName.ToLower()
            new-item -path "$FileServer\$Lastname, $Firstname\$UniqueUserNameLower" -ItemType Directory > $null
            $ACL = get-acl "$FileServer\$Lastname, $Firstname\$UniqueUserName" #Out-Null
            $FileSystemRights = [System.Security.AccessControl.FileSystemRights]"FullControl"
            $AccessControlType = [System.Security.AccessControl.AccessControlType]::Allow
            $InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
            $PropagationFlags = [System.Security.AccessControl.PropagationFlags]"InheritOnly"
            $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ("$DomainName\$UniqueUserName", $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType) #Out-Null
            $ACL.AddAccessRule($AccessRule) #$null
            
            $SmbshareName = "$UniqueUserName$"
            #Erweiterte Freigabe + Berechtigungen
            New-SmbShare -Name $SmbshareName -Path "D:\Benutzer\$Lastname, $FirstName\$UniqueUsername" -CimSession $FSSession -FullAccess "Jeder" > $null
            Set-Acl -Path "$FileServer\$Lastname, $Firstname\$UniqueUserName" -AclObject $ACL -ea Stop > $null
            Write-Host " Done" -ForegroundColor Green
        }
        Catch
        {
            Write-Host " Error" -ForegroundColor Red
            $error[0] | Add-Content "$errorLog$errorFile"
            {continue} > $null   
        }
        #endregion Home Drive

#-----------------------------------------------------Create Home Drive End-------------------------------------------------#

#UNGETESTET
<#
        #region DW01 Folder

        try
        {
            Write-Host "      Creating DW01 Sharefolder:" -NoNewline
            New-Item -Path "$DWServer\$UniqueUserNameLower" -ItemType Directory > $null
            $ACL = Get-Acl "$DWServer\$UniqueUserName" 
            
            New-SmbShare -Name $SmbshareName -Path "D:\DW_Benutzer_Scan\$UniqueUserName" -CimSession $DWSession -FullAccess "Jeder" > $null
            Set-Acl -Path "$DWServer\$UniqueUserNameLower" -AclObject $ACL -ea Stop > $null
            Write-Host " Done" -ForegroundColor Green

        }
        Catch
        {
            Write-Host " Error" -ForegroundColor Red
            $error[0] | Add-Content "$errorLog$errorFile"
            {continue} > $null 
        }

        #endregion DW01 Folder
#>


#-----------------------------------------------------Verteiler Handy Start--------------------------------------------------------#
                                                             
        #region Verteiler Handy                      
        if($Item.Handy -eq 1)
        {
            #Adde den User in Intern_Mobilfunk
            Add-ADGroupMember -Identity Intern_Mobilfunk-1-132458637 -Members $UniqueUserName >> $null
        }
        else
        {
            {continue} > $null 
        }            
        #endregion Verteiler Handy
                                                             
#-----------------------------------------------------Verteiler Handy Ende--------------------------------------------------------#
        #Setzt das Feld INT_TODO in der Datenbank auf 2 für den bearbeitenden User und fülle weitere Felder aus (Variable $SQLUpdate bitte anpassen)
        $GUID = Get-ADUser -Identity $Username -Properties ObjectGUID | Select-Object ObjectGUID
        $str_GUID = [System.Convert]::ToString($GUID.ObjectGUID.ToString())

        $SQLUpdate = "UPDATE dbo.MAG_Stammdaten SET INT_TODO = 2, AngelegtAM = GETDATE(), AngelegtVon = '$($SQLAngelegtVon)', AngelegtProg = '$($SQLAngelegtProg)', UID_AzureID = '$($str_GUID)'  WHERE Username = '$($newUserID.sAMAccountName)'" 

        #Write-Host $SQLUpdate | ONLY DEBUG | Zeigt den Update String an
        Write-Host "      INT_Todo auf 2 ändern: " -NoNewline
        try
        {   
            $sqlcmd = new-object "System.data.sqlclient.sqlcommand"  | Out-Null 
            $SqlCmd = $SqlCon.CreateCommand()
            $SqlCmd.CommandText = $SQLUpdate
            #$affectedRows = $SqlCmd.ExecuteNonQuery() | ONLY DEBUG FUNCTION
            $SqlCmd.ExecuteNonQuery() | Out-Null
            #Write-Host ("Rows Affected by Update=$affectedRows") | ONLY DEBUG FUNCTION
            Write-Host " Done" -ForegroundColor Green 
        }
        Catch
        {
            Write-Host " Error" -ForegroundColor Red
            $error[0] | Add-Content "$errorLog$errorFile"
            {continue} > $null
        }
#----------------------------------------------------TourenPlanung & myTime----------------------------------------------------------#
#region myTime & RM 
        
        #$SqlCon.Close() #nicht sicher ob benötigt - schließt die alte Verbindung
        [void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data") 
        
        #Variablen
        $SQLServer_mt_rm = "10.30.2.132" #Testserver 10.30.2.130 
        $SQLUsername_mt_rm = "admin"
        $SQLPassword_mt_rm = "RUEcXfU6eN"
        $SQLDBName_rm = "mt_rm" #Testserver = mt_rm_live_20200422
        $SQLDBName_mt = "mt_project" #Testserver = mt_project_live_20200210 
        $UID_RM =                     
        
        $SQLInsert_rm = "INSERT INTO mr_user(user_name, ldap_user, user_pw, user_role, email, vorname, nachname, freigegeben) 
                         VALUES('$($newUserID.sAMAccountName)', 
                         '$($newUserID.sAMAccountName)', 
                         'merTens0815', 
                         'user', 
                         '$($newUserID.UserPrincipalName)', 
                         '$($newUserID.GivenName)', 
                         '$($newUserID.Surname)', 
                         'ja')"
        
        $SQLInsert_mt = "INSERT INTO mt_user(user, ldap_user, email, pw, gruppe, gid, freigegeben, vorname, nachname, anzeigename, agb_confirm) 
                         VALUES('$($newUserID.sAMAccountName)', 
                         '$($newUserID.sAMAccountName)', 
                         '$($newUserID.UserPrincipalName)', 
                         'merTens0815', 
                         'user', 
                         '200', 
                         'Ja', 
                         '$($newUserID.GivenName)', 
                         '$($newUserID.Surname)', 
                         'Benutzername', 
                         'init')"         
        #Abfrage myTime
        Write-Host "Soll der User in der myTime angelegt werden?" -ForegroundColor Yellow
        $Confirm = Read-Host " [J] Ja [N] Nein "
        if($Confirm -match "[jJ]")
        {
            $myTime = 1 > $null
            #Verbindungsaufbau MT
            $ConString_mt = "Server=$SQLServer_mt_rm; Port=3306; Database=$SQLDBName_mt; Uid=$SQLUsername_mt_rm; Pwd=$SQLPassword_mt_rm"
            $SQLCon_mt = New-Object MySql.Data.MySqlClient.MySqlConnection
            $SQLCon_mt.ConnectionString = $ConString_mt
            $SQLCon_mt.Open()
        
            #INSERT INTO Query
            $sqlcmd_mt = New-Object -TypeName MySql.Data.MySqlClient.MySqlCommand
            $SqlCmd_mt = $SqlCon_mt.CreateCommand()
            $SqlCmd_mt.CommandText = $SQLInsert_mt
            $SqlCmd_mt.ExecuteNonQuery() 
        
            #Verbindung MT trennen
            $SQLCon_mt.Close()
        }
        else
        {
               {continue}  > $null
        }        
        #Abfrage Dispotool
        Write-Host "Soll der User im Dispotool angelegt werden?" -ForegroundColor Yellow
        $Confirm = Read-Host "[J] Ja [N] Nein "
        if($Confirm -match "[jJ]")
        {         
            $DispoTool = 1 > $Null                        
            #Verbindungsaufbau Ressource Management / Dispotool
            $ConString_rm = "Server=$SQLServer_mt_rm; Port=3306; Database=$SQLDBName_rm; Uid=$SQLUsername_mt_rm; Pwd=$SQLPassword_mt_rm"
            $SQLCon_rm = New-Object MySql.Data.MySqlClient.MySqlConnection
            $SQLCon_rm.ConnectionString = $conString_rm
            $SQLCon_rm.Open()
        
            #INSERT INTO Query
            $sqlcmd_rm = New-Object -TypeName MySql.Data.MySqlClient.MySqlCommand
            $SqlCmd_rm = $SqlCon_rm.CreateCommand()
            $SqlCmd_rm.CommandText = $SQLInsert_rm
            $SqlCmd_rm.ExecuteNonQuery() 
            
            #Verbindung Ressource Management / Dispotool trennen
            $SQLCon_rm.Close()
        }
        else
        {
            {continue}  > $null
        }    
            
        #endregion myTime & RM
#--------------------------------------------------TourenPlanung & myTime Ende-------------------------------------------------------#

#--------------------------------------------------Teams & Nummernzuweisung Start---------------------------------------------------------------#
        #region Teams & Nummernzuweisung
        function AddOfficeGroup
        {
            $AddOfficeGroup = Get-ADGroup -SearchBase $OfficeOU -Filter "SamAccountName -like '$OfficeLicense'"
            if ($AddOfficeGroup = [string]::IsNullOrWhiteSpace($AddOfficeGroup))
            {
               Write-Warning "Keine Lizenz zugewiesen"
               {continue} > $null 
            }
            else
            {
                Write-Host "Lizenz erfolgreich hinzugefügt" -ForegroundColor Green
                {continue} > $null
            }                        
        }
        
        
        Write-Host "Soll der User Teams-Telefonie benutzen?" -ForegroundColor Yellow
        $Confirm = Read-Host "[J] Ja [N] Nein "          
        if($Confirm -match "[jJ]")
        {
            Add-ADGroupMember -Identity OG_MAG_M365_E3_Standard_InklPhone -Members $UniqueUserName >> $null
            Get-CsOnlineUser -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | Where-Object  { $_.LineURI -notlike $null }| select UserPrincipalName, LineURI | sort LineURI | Out-GridView
            $Global:PhoneExtension = (Read-Host -Prompt '4-stellige Durchwahl bitte eingeben')     
                                 
            function PhoneCheck 
            {
                if ($Global:PhoneExtension -match '[0-9][0-9][0-9][0-9]' -and ($Global:PhoneExtension.Length -eq 4))
                {
                }
                elseif ([string]::IsNullOrWhiteSpace($Global:PhoneExtension))
                {
                    $Global:PhoneExtension = $null
                }
                else
                {
                    $Global:PhoneExtension = $null 
                    $Global:PhoneExtension = Read-Host -Prompt 'Die Durchwahl muss 4stellig sein!'
                    PhoneCheck
                }
            }
        PhoneCheck
        }
        else
        {
            Write-Host "Soll der User eine andere Office Lizenz bekommen? ENTER drücken um keine zu vergeben" -ForegroundColor Yellow
            $Readhost = Read-Host "[J] Ja [N] Nein "
            if($Readhost -match "[jJ]")
            {
                Write-Host "Bitte wählen sie eine der folgenden Gruppen aus, damit der User hinzugefügt wird `r`n"
                Get-ADGroup -Filter * -SearchBase $OfficeOU | Select -ExpandProperty SAMAccountName | Sort-Object -Property SAMAccountName
                $OfficeLicense = (Read-Host -Prompt "`r`nWelche Lizenz möchten Sie gerne hinzufügen?")
                AddOfficeGroup
            }
            else
            {
                Write-Warning "Keine Lizenz zugewiesen"
                {continue}  > $null
            }           
        }
        
        $PhoneExt = $Global:PhoneExtension
        $Teams_Phone = "tel:+4921544705" + $PhoneExt
        Set-CsUser -Identity $newUserID.UserPrincipalName -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI $Teams_Phone > $null
        Grant-CsOnlineVoiceRoutingPolicy -Identity $newUserID.UserPrincipalName -PolicyName VoiceRoutePolicy > $null          
        $ADNumber_Phone = "+49" + " " + "2154" + " " + "4705" + " " + $PhoneExt
        Set-ADUser $newUserID.sAMAccountName -OfficePhone $ADNumber_Phone > $null        
        #endregion Teams & Nummernzuweisung
#--------------------------------------------------Teams & Nummernzuweisung Ende---------------------------------------------------------------#

#-----------------------------------------------------Office Lizenz Start--------------------------------------------------------#
#region Office Lizenz  (IN DER TEAMS REGION)  
           # Write-Host "Möchten Sie dem User eine oder mehrere Office Lizenz zuteilen? Enter drücken um keine Lizenz zu vergeben" -ForegroundColor Yellow
           # $Readhost = Read-Host " (J / N) "
           # Switch ($Readhost)
           # {
           #     J{
           #         Write-Host "Bitte wählen sie eine der folgenden Gruppen aus, damit der User hinzugefügt wird `r`n"
           #         Get-ADGroup -Filter * -SearchBase $OfficeOU | Select -ExpandProperty SAMAccountName | Sort-Object -Property SAMAccountName
           #         $OfficeLicense = (Read-Host -Prompt "`r`nWelche Lizenz möchten Sie gerne hinzufügen?")
           #
           #         function AddOfficeGroup
           #         {
           #             $AddOfficeGroup = Get-ADGroup -SearchBase $OfficeOU -Filter "SamAccountName -like '$OfficeLicense'"
           #             if ($AddOfficeGroup = [string]::IsNullOrWhiteSpace($AddOfficeGroup))
           #             {
           #                Write-Warning "Keine Lizenz zugewiesen"
           #                {continue}   
           #             }
           #             else
           #             {
           #                 Write-Host "Lizenz erfolgreich hinzugefügt" -ForegroundColor Green
           #                 {continue}
           #             }                        
           #         }
           #         AddOfficeGroup
           #      }
           #
           #     N{
           #         Write-Warning "Keine Lizenz zugewiesen"
           #      }
           #
           #     Default{Continue}
           # } 
#endregion Office Lizenz (IN DER TEAMS REGION)   
#-----------------------------------------------------Office Lizenz Ende--------------------------------------------------------#

#--------------------------------------------------Excel Dokumentation Start---------------------------------------------------------------#
        #region Excel
        #LONG Werte Bündigkeit - https://docs.microsoft.com/de-de/office/vba/api/excel.xlhalign
        Write-Host "      Erstelle Excel Tabelle:" -NoNewline
        try
        {
            $xlColorIndexBlue = 5
            #open excel
            $excel = New-Object -ComObject excel.application
            $excel.visible = $True
            #add a default workbook
            $workbook = $excel.Workbooks.Add()
            #Worksheet Name
            $ws = $workbook.Worksheets.Item(1)
            $ws.Name = 'User Checklist'
            
            #region Excel Boarders
            $xlAutomatic = -4105
            $xlBottom = -4107
            $xlCenter = -4108
            $xlContext = -5002
            $xlContinuous = 1
            $xlDiagonalDown = 5
            $xlDiagonalUp = 6
            $xlEdgeBottom = 9
            $xlEdgeLeft = 7
            $xlEdgeRight = 10
            $xlEdgeTop = 8
            $xlInsideHorizontal = 12
            $xlInsideVertical = 11
            $xlNone = -4142
            $xlThin = 2 
            $xlMedium = 4
            $selection = $ws.Range("A1:D32")
            $selection.select() > $null
            $selection.HorizontalAlignment = $xlCenter
            $selection.VerticalAlignment = $xlBottom
            $selection.WrapText = $false
            $selection.Orientation = 0
            $selection.AddIndent = $false
            $selection.IndentLevel = 0
            $selection.ShrinkToFit = $false
            $selection.ReadingOrder = $xlContext
            $selection.MergeCells = $false
            #Horizontale Ränder
            $selection.Borders.Item($xlInsideHorizontal).Weight = $xlThin
            $selection.Borders.Item($xlInsideHorizontal).LineStyle = $xlContinuous
            $selection.Borders.Item($xlInsideHorizontal).ColorIndex = $xlAutomatic 
            #Vertikale Ränder
            $selection.Borders.Item($xlInsideVertical).Weight = $xlThin
            $selection.Borders.Item($xlInsideVertical).LineStyle = $xlContinuous
            $selection.Borders.Item($xlInsideVertical).ColorIndex = $xlAutomatic 
            
            #Dicker Rahmen
            $ws.Range("A1:D32").BorderAround($xlContinuous,$xlMedium)     > $null
            $ws.Range("A1:D2").BorderAround($xlContinuous,$xlMedium)      > $null
            $ws.Range("A3:D5").BorderAround($xlContinuous,$xlMedium)      > $null
            $ws.Range("A7:D32").BorderAround($xlContinuous,$xlMedium)     > $null
            #endregion Excel Boarders
            
            #Hintergrund Farbe
            $ColorGreen = [System.Drawing.Color]::FromArgb(255,230,179)
            $ws.Range("A1:D32").Interior.Color = $ColorGreen
            
            #region Überschrift
            #Erstellt eine Überschrift
            $row = 1
            $Column = 1
            $ws.Cells.Item($row,$column)= 'User Checkliste'
            #Titel Formatierung
            $MergeCells = $ws.Range("A1:D2")
            $MergeCells.Select() > $null
            $MergeCells.MergeCells = $true
            $ws.Cells(1, 1).HorizontalAlignment = -4108
            #Titel Formatierung
            $ws.Cells.Item(1,1).Font.Size = 24
            $ws.Cells.Item(1,1).Font.Bold=$True
            $ws.Cells.Item(1,1).Font.Name = "Cambria"
            $ws.Cells.Item(1,1).Font.ThemeFont = 1
            $ws.Cells.Item(1,1).Font.ThemeColor = 4
            $ws.Cells.Item(1,1).Font.ColorIndex = 55
            $ws.Cells.Item(1,1).Font.Color = 8210719
            #endregion Überschrift
            
            #region Befüllen der Felder
            $ws.Cells.Item(3,1) = 'Vorname'
            $ws.Cells.Item(3,1).Font.Bold=$True 
            $ws.Cells.Item(3,2) = $Item.Vorname
            $ws.Cells.Item(3,3) = 'Nachname'
            $ws.Cells.Item(3,3).Font.Bold=$True
            $ws.Cells.Item(3,4) = $Item.Nachname
            $ws.Cells.Item(4,1) = 'Abteilung'
            $ws.Cells.Item(4,1).Font.Bold=$True
            $ws.Cells.Item(4,2) = $Item.Stellenbeschreibung
            $ws.Cells.Item(4,3) = 'Eintritt'
            $ws.Cells.Item(4,3).Font.Bold=$True
            $ws.Cells.Item(4,4) = $Item.Eintrittsdatum
            $ws.Cells.Item(5,1) = 'Handy'
            $ws.Cells.Item(5,1).Font.Bold=$True
            $ws.Cells.Item(5,2) = if($Item.Handy -eq 1){"ja"}else{"Nein"}
            $ws.Cells.Item(5,3) = 'Notebook'
            $ws.Cells.Item(5,3).Font.Bold=$True 
            $ws.Cells.Item(5,4) = if($Item.Notebook -eq 1){"ja"}else{"Nein"}
            
            $ws.Cells.Item(7,1) = 'Benutzer angelegt'
            $ws.Cells.Item(7,1).Font.Bold=$True
            $MergeCells = $ws.Range("A7:A8")
            $MergeCells.Select() > $null
            $MergeCells.MergeCells = $true
            
            $ws.Cells.Item(7,2) = 'MA Kürzel'
            $ws.Cells.Item(7,2).Font.Bold=$True 
            $MergeCells = $ws.Range("B7:B8")
            $MergeCells.Select() > $null
            $MergeCells.MergeCells = $true
            
            $ws.Cells.Item(7,3) = 'Lizenz'
            $ws.Cells.Item(7,3).Font.Bold=$True
            $MergeCells = $ws.Range("C7:C8")
            $MergeCells.Select() > $null
            $MergeCells.MergeCells = $true
            
            $ws.Cells.Item(7,4) = 'Bemerkungen'
            $ws.Cells.Item(7,4).Font.Bold=$True
            $MergeCells = $ws.Range("D7:D8")
            $MergeCells.Select() > $null 
            $MergeCells.MergeCells = $true
            
            $ws.Cells.Item(9,1) = 'AD'
            $ws.Cells.Item(9,1).Font.Bold=$True
            $ws.Cells.Item(9,1).HorizontalAlignment = -4131
            $ws.Cells.Item(9,2) = $ExecutingUser
            
            $ws.Cells.Item(10,1) = 'Benutzergruppen'
            $ws.Cells.Item(10,2) = $ExecutingUser
            
            $ws.Cells.Item(11,1) = 'OUs'
            $ws.Cells.Item(11,2) = $ExecutingUser
            
            $ws.Cells.Item(12,1) = 'Benutzer Stammdaten'
            $ws.Cells.Item(12,2) = $ExecutingUser
            
            $ws.Cells.Item(12,4) = $PhoneExt
            
            $ws.Cells.Item(13,1) = 'Office Gruppe'
            $ws.Cells.Item(13,2) = $ExecutingUser
            
            $ws.Cells.Item(14,1) = 'MAGVFS02'
            $ws.Cells.Item(14,1).Font.Bold=$True
            $ws.Cells.Item(14,1).HorizontalAlignment = -4131
            $ws.Cells.Item(14,2) = $ExecutingUser
            
            $ws.Cells.Item(15,1) = '$Freigabe'
            $ws.Cells.Item(15,2) = $ExecutingUser
            
            $ws.Cells.Item(16,1) = 'Berechtigungen'
            $ws.Cells.Item(16,2) = "CURRENTLY BUGGED - BITTE PRÜFEN"
            
            $ws.Cells.Item(17,1) = 'Exchange'
            $ws.Cells.Item(17,1).Font.Bold=$True
            $ws.Cells.Item(17,1).HorizontalAlignment = -4131
            $ws.Cells.Item(17,2) = $ExecutingUser
            
            $ws.Cells.Item(18,1) = 'Docuware'
            $ws.Cells.Item(18,1).Font.Bold=$True
            $ws.Cells.Item(18,1).HorizontalAlignment = -4131
            $ws.Cells.Item(18,2) = $ExecutingUser
            $ws.Cells.Item(18,4) = "Händisch noch das Archiv, Briefkorb, Userfreigabe auf DW01 und Importjob auf DW06 anlegen | ggf noch Auswahllisten anpassen"
            
            $ws.Cells.Item(19,1) = 'Mailstore'
            $ws.Cells.Item(19,1).Font.Bold=$True
            $ws.Cells.Item(19,1).HorizontalAlignment = -4131
            $ws.Cells.Item(20,1) = 'Sync'
            $ws.Cells.Item(21,1) = 'Job aktiviert'
            $ws.Cells.Item(22,1) = 'CO7 / CO7 MIG'
            $ws.Cells.Item(22,1).Font.Bold=$True 
            $ws.Cells.Item(22,1).HorizontalAlignment = -4131
            $ws.Cells.Item(23,1) = 'Gruppen/Rechte'
            $ws.Cells.Item(24,1) = 'Drucksteuerung'
            
            $ws.Cells.Item(25,1) = 'Zeiterfassung'
            $ws.Cells.Item(25,1).Font.Bold=$True
            $ws.Cells.Item(25,1).HorizontalAlignment = -4131
            $ws.Cells.Item(25,2) = if($myTime -eq 1){$ExecutingUser}else{"nicht angelegt"}
            $ws.Cells.Item(25,4) = 'http://10.30.2.131:8020/'
            
            $ws.Cells.Item(26,1) = 'Dispotool'
            $ws.Cells.Item(26,1).Font.Bold=$True
            $ws.Cells.Item(26,1).HorizontalAlignment = -4131
            $ws.Cells.Item(26,2) = if($DispoTool -eq 1){$ExecutingUser}else{"nicht angelegt"}
            $ws.Cells.Item(26,4) = 'http://10.30.2.131:1088/touren/index'
            
            $ws.Cells.Item(27,1) = 'CRM'
            $ws.Cells.Item(27,1).Font.Bold=$True
            $ws.Cells.Item(27,1).HorizontalAlignment = -4131
            $ws.Cells.Item(27,4) = 'Wenn benötigt bitte händisch anlegen | http://10.30.2.131:8030/'
            
            $ws.Cells.Item(28,1) = ''
            
            $ws.Cells.Item(29,1) = 'Verteiler Handy'
            $ws.Cells.Item(29,2) = if($Item.Handy -eq 1){$ExecutingUser}else{""}

            $ws.Cells.Item(30,1) = 'Teams'
            $ws.Cells.Item(30,4) = " 1. Teams_Connect.ps1 | auf GitHub zu finden`n 2. Set-CsUser -Identity '$($EmailAddress)' -EnterpriseVoiceEnabled $" + "true -HostedVoiceMail $" + "true -OnPremLineURI tel:+4921544705" + "$PhoneExt `n 3. Grant-CsOnlineVoiceRoutingPolicy -Identity '$($EmailAddress)' -PolicyName VoiceRoutePolicy"
              
            #endregion Befüllen der Felder
            
            #adjusting the column width so all data's properly visible
            $usedRange = $ws.UsedRange	
            $usedRange.EntireColumn.AutoFit() | Out-Null
            
            #saving & closing the file
            $excelLogFile = "M:\00 IT\010 Standortdokumentation\Willich\UserClientsDoku\UserDoku\$Lastname, $Firstname.xlsx"
            $workbook.SaveAs($excelLogFile)
            $excel.Quit()
            Write-Host " Done" -ForegroundColor Green
        }
        Catch
        {
            Write-Host " Error" -ForegroundColor Red
            $error[0] | Add-Content "$errorLog$errorFile"
            {continue} > $null
        }
         #endregion Excel
#--------------------------------------------------Excel Dokumentation Ende----------------------------------------------------------------#

#--------------------------------------------------Create a Ticket in Zammad----------------------------------------------------------------#
        
        #region Ticket in Zammad
        if($Item.Notebook -eq 1){$Notebook = "ja"}else{$Notebook = "Nein"}
        if($Item.Handy -eq 1){$Handy = "ja"}else{$Handy = "Nein"}
        Write-Host "      Erstelle Ticket in Zammad:" -NoNewline
        try
        {
            $apiEntry = "http://ticket.mertens.ag/api/v1/tickets"
            $apiToken = "nNFmXS7AXt-i4iAfe-966VFcLXPY_amLK6nXYvdJ6S6TATox_nJKNG8cBTJUe5EF" #gültig bis 02.04.22
        
            $headers = @{ "Authorization" = "Token $apitoken"}
            $body = @{ 
                title="Neuer Mitarbeiter: $FirstNameNoSpecial $LastNameNoSpecial | $Eintrittsdatum_short"
                group="IT"
                customer="it@mertens.ag"
                type=""
                extern_intern="true"
                kontaktart="vom Agent aus"
                owner_id="3" #IT Abteilung
                state_id="2" #2 = Offen
                article=@{
                    content_type="text/html"
                    subject="Neuer Mitarbeiter | $FirstNameNoSpecial $LastNameNoSpecial | $Eintrittsdatum_short"
                    body="<b>Name:</b> $FirstNameNoSpecial $LastNameNoSpecial <br> <b>Beginnt am:</b> $Eintrittsdatum_short <br><b>Position:</b> $StellenbeschreibungNoSpecial <br><b>Notebook:</b> $Notebook <br><b>Handy:</b> $Handy <br><b>Angelegt durch:</b> $ExecutingUser <br> <b>Dokumentation unter:</b> M:\00 IT\010 Standortdokumentation\Willich\UserClientsDoku\UserDoku"
                    type="note" #InternalNote
                    tags="Neuer Mitarbeiter"
                }    
            }
        $response = Invoke-RestMethod -Uri $apientry -Body ($body|ConvertTo-Json) -ContentType 'application/json' -Headers $headers -Method POST
        Write-Host " Done" -ForegroundColor Green
        }
        Catch
        {
            Write-Host " Error" -ForegroundColor Red
            $error[0] | Add-Content "$errorLog$errorFile"
            {continue} > $null
        }
        #endregion Ticket in Zammad
        

        If (Test-Path $logFile)
        { 
            Send-MailMessage -From $logMailSender -Subject "$($logMailBetreff) $($NewUserID.Displayname) | $($Eintrittsdatum_short)" -To $logMailEmpfang -Body "Der Mitarbeiter/Die Mitarbeiterin $($newUserID.GivenName) $($newUserID.Surname) wurde erstellt! `r`n Telefonnummer: $ADNumber_Phone `r`n Position: $($newUserID.Description) `r`n Beginn: $Eintrittsdatum_short" -SmtpServer $SMTPServer 
        }
        Else
        { 
            {continue}  > $null
        }

#--------------------------------------------------Create a Ticket in Zammad Ende----------------------------------------------------------------#
    }
    Catch
    {
        Write-Host "Es gab ein Problem mit dem erstellen des Users: $($newUserID.sAMAccountName). Der Account wurde nicht erstellt!" -ForegroundColor Red
        "Es gab ein Problem mit dem erstellen des Users: $newUserID.$samAccountName" >>  $logFile
        $_ >> $logFile
        $error[0] | Add-Content "$errorLog$errorFile"
    }
}