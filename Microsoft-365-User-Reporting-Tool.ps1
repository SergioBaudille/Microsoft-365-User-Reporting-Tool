# ==========================================
# Microsoft 365 User Reporting Tool v1.0
# Author: Sergio Baudille
# ==========================================

try {

    if (!(Get-MgContext)) {

        Connect-MgGraph -Scopes "User.Read.All"
    }

}
catch {

    Write-Host ""
    Write-Host "Failed to connect to Microsoft Graph." -ForegroundColor Red
    Write-Host $_.Exception.Message
    return
}

try {

    $Global:Users = Get-MgUser -All -ErrorAction Stop

}
catch {

    Write-Host ""
    Write-Host "Failed to retrieve users from Microsoft Graph." -ForegroundColor Red
    Write-Host $_.Exception.Message
    return
}

$Global:ReportFile = ".\Reports\M365Users_$TimeStamp.csv"

# ==========================================
# List All Users
# ==========================================

function Get-AllUsers {

    Clear-Host

    $Global:Users |
    Select-Object `
        DisplayName,
        UserPrincipalName,
        Mail |
    Format-Table -AutoSize
}

# ==========================================
# Search User
# ==========================================

function Search-User {

$SearchTerm = Read-Host "Enter user name"

if ([string]::IsNullOrWhiteSpace($SearchTerm)) {

    Write-Host ""
    Write-Host "Search term cannot be empty." -ForegroundColor Yellow
    return
}

    $Results = $Global:Users |
    Where-Object {

        $_.DisplayName -like "*$SearchTerm*"
    }

    if ($Results) {

        $Results |
        Select-Object `
            DisplayName,
            UserPrincipalName,
            Mail |
        Format-Table -AutoSize
    }
    else {

        Write-Host ""
        Write-Host "No users found." -ForegroundColor Yellow
    }
}

# ==========================================
# User Statistics
# ==========================================

function Get-UserStatistics {

    $TotalUsers = $Global:Users.Count

    $UsersWithMail = (
        $Global:Users |
        Where-Object {
            $_.Mail
        }
    ).Count

    $UsersWithoutMail =
    $TotalUsers - $UsersWithMail

    Write-Host ""
    Write-Host "========== USER STATISTICS ==========" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total Users      : $TotalUsers"
    Write-Host "Users With Mail  : $UsersWithMail"
    Write-Host "Users Without Mail : $UsersWithoutMail"
    Write-Host ""
}

# ==========================================
# Export CSV Report
# ==========================================

function Export-UserReport {

    try {

        $Global:Users |
        Select-Object `
            DisplayName,
            UserPrincipalName,
            Mail |
        Export-Csv `
            $Global:ReportFile `
            -NoTypeInformation `
            -ErrorAction Stop

        Write-Host ""
        Write-Host "Report exported successfully." -ForegroundColor Green
        Write-Host $Global:ReportFile -ForegroundColor Cyan
    }
    catch {

        Write-Host ""
        Write-Host "Failed to export report." -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}

# ==========================================
# User Details
# ==========================================

function Get-UserDetails {

    $SearchTerm = Read-Host "Enter user name"

    $User = $Global:Users |
    Where-Object {

        $_.DisplayName -like "*$SearchTerm*"
    } |
    Select-Object -First 1

    if ($User) {

        Write-Host ""
        Write-Host "========== USER DETAILS ==========" -ForegroundColor Cyan
        Write-Host ""

        Write-Host "Name : $($User.DisplayName)"
        Write-Host "UPN  : $($User.UserPrincipalName)"
        Write-Host "Mail : $($User.Mail)"
        Write-Host "ID   : $($User.Id)"

        Write-Host ""
    }
    else {

        Write-Host ""
        Write-Host "User not found." -ForegroundColor Yellow
    }
}

# ==========================================
# Tenant Information
# ==========================================

function Get-TenantInformation {

    try {

        Clear-Host

        Get-MgOrganization -ErrorAction Stop |
        Select-Object `
            DisplayName,
            Id,
            CountryLetterCode |
        Format-List

    }
    catch {

        Write-Host ""
        Write-Host "Unable to retrieve tenant information." -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}


# ==========================================
# Main Menu
# ==========================================

do {

    Clear-Host

    Write-Host "========================================="
    Write-Host " Microsoft 365 User Reporting Tool v1.0"
    Write-Host "========================================="
    Write-Host ""
    Write-Host "1. List All Users"
    Write-Host "2. Search User"
    Write-Host "3. User Details"
    Write-Host "4. User Statistics"
    Write-Host "5. Export CSV Report"
    Write-Host "6. Show Tenant Information"
    Write-Host "7. Exit"
    Write-Host ""

    $Choice = Read-Host "Choose an option"

    switch ($Choice) {

        "1" { Get-AllUsers }

        "2" { Search-User }

        "3" { Get-UserDetails }

        "4" { Get-UserStatistics }

        "5" { Export-UserReport }
         
        "6" { Get-TenantInformation }

        "7" {
    Write-Host ""
    Write-Host "Exiting application..." -ForegroundColor Yellow
    return
}

        default {

            Write-Host ""
            Write-Host "Invalid option." -ForegroundColor Yellow
        }
    }

    if ($Choice -ne "7") {

        Pause
    }

}
while ($true)