<#

    SCRIPT : BirthdayMemo.ps1
    
    DESCRIPTION : Ce script permet de lister les anniversaires passés, du jour et à venir
                  à partir des informations contenues dans un fichier CSV.
                  
                  => Structure du fichier CSV :
                      Surname;FirstName;FullName;DayOfBirth;MonthOfBirth;YearOfBirth

                  
    AUTEUR : Johann BARON
    
    VERSIONS :
    - 31/05/2021, v1.0
    
#>


$dataFile = 'C:\Users\Path\to\CSV\file\persons.csv'

$pastBirthdays = @()
$nextBirthdays = @()
$currentBirthdays = @()
$allPersonsArray = @()


Function Load-Data {
    $dataFileContent = Import-Csv $dataFile -Delimiter ";"
    
    foreach($dataContent in $dataFileContent){
        $personObj = "" | select "Surname","FirstName","FullName","DayOfBirth","MonthOfBirth","YearOfBirth"
        $personObj.Surname = $dataContent.Surname
        $personObj.FirstName = $dataContent.FirstName
        $personObj.FullName = $dataContent.FullName
        $personObj.DayOfBirth = $dataContent.DayOfBirth
        $personObj.MonthOfBirth = $dataContent.MonthOfBirth
        $personObj.YearOfBirth = $dataContent.YearOfBirth
        
        $script:allPersonsArray += $personObj
        
        $currentDate = Get-Date
        $birthDate = Get-Date "$($personObj.DayOfBirth)/$($personObj.MonthOfBirth)/$($currentDate.Year)"
        
        if($birthDate -eq $currentDate.Date){
            $script:currentBirthdays += @{$personObj.FirstName = Get-Date $birthDate -UFormat "%Y%m%d"}
        } elseif($birthDate -gt $currentDate.Date){
            $script:nextBirthdays += @{$personObj.FirstName = Get-Date $birthDate -UFormat "%Y%m%d"}
        } else {
            $script:pastBirthdays += @{$personObj.FirstName = Get-Date $birthDate -UFormat "%Y%m%d"}
        }
        
        $script:nextBirthdays += @{$personObj.FirstName = (Get-Date "$($personObj.DayOfBirth)/$($personObj.MonthOfBirth)/$($currentDate.AddYears(1).Year)" -UFormat "%Y%m%d")}
                
        $script:pastBirthdays += @{$personObj.FirstName = (Get-Date "$($personObj.DayOfBirth)/$($personObj.MonthOfBirth)/$($currentDate.AddYears(-1).Year)" -UFormat "%Y%m%d")}
    }
}



if(Test-Path $dataFile){
    Load-Data
} else {
    Write-Host "Aucune donnée à afficher" -ForegroundColor Red
}

Write-Host "`n`n"
Write-Host "Anniversaires passés :" -ForegroundColor Blue

$pastBirthdays | sort Values | select -Last 3 | foreach {
    $($_.Keys) + " le " + (Get-Culture).TextInfo.ToTitleCase(
        (Get-Date $($_.Values).Insert(6,"/").Insert(4,"/") -UFormat "%A %d %B %Y")
    )
}

Write-Host "`n`n"
Write-Host "Anniversaires aujourd'hui :" -ForegroundColor Blue

$currentBirthdays | sort Values | foreach {
    $($_.Keys) + " le " + (Get-Culture).TextInfo.ToTitleCase(
        (Get-Date $($_.Values).Insert(6,"/").Insert(4,"/") -UFormat "%A %d %B %Y")
    )
}

Write-Host "`n`n"
Write-Host "Anniversaires à venir :" -ForegroundColor Blue

$nextBirthdays | sort Values | select -First 3 | foreach {
    $($_.Keys) + " le " + (Get-Culture).TextInfo.ToTitleCase(
        (Get-Date $($_.Values).Insert(6,"/").Insert(4,"/") -UFormat "%A %d %B %Y")
    )
}

Write-Host "`n`t`t`t`t---> Appuyer sur une touche pour quitter <---" -ForegroundColor White$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")