# Function to display a folder browser dialog and return the selected folder path
Function Get-Folder($initialDirectory="", $description="Select a folder")
{
    # Load the Windows Forms assembly for the folder browser dialog
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    # Create the folder browser dialog object
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = $description
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory

    # Create a dummy form to act as the parent and ensure dialog appears on top
    $form = New-Object System.Windows.Forms.Form
    $form.TopMost = $true
    $form.WindowState = "Minimized"
    $form.ShowInTaskbar = $false

    # Show the dialog and get the selected folder if OK is pressed
    if($foldername.ShowDialog($form) -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    
    # Clean up the dummy form
    $form.Dispose()
    
    return $folder
}

# Prompt user for client name
$Client = Read-Host -Prompt 'Client Name'

# Prompt user to select the template directory
Write-Host '---------------------------------- Select Template Directory ----------------------------------'
$Source = Get-Folder -description "Select the template directory to copy from"

# Exit if user cancelled the source folder selection
if ([string]::IsNullOrEmpty($Source)) {
    Write-Host "Source folder selection was cancelled. Exiting script."
    exit
}

$Source = $Source + '\*' # Add wildcard to select all contents

# Prompt user to select the destination directory
Write-Host '-------------------------------- Select Destination Directory ---------------------------------'
$Destination = Get-Folder -description "Select the destination directory where the project will be created"

# Exit if user cancelled the destination folder selection
if ([string]::IsNullOrEmpty($Destination)) {
    Write-Host "Destination folder selection was cancelled. Exiting script."
    exit
}

# Set project metadata variables
$ProjectName = $Client + ' Customizations'


# Copy the template files to the destination (excluding CloneTemplateForProject.ps1)
Write-Host '---------------------------------- Performing Template Copy -----------------------------------'
$SourcePath = $Source.TrimEnd('\*')
Get-ChildItem -Path $SourcePath | Where-Object { $_.Name -ne "CloneTemplateForProject.ps1" } | Copy-Item -Destination $Destination -Recurse -Force

# Prepare folder names for renaming
$MainFolderPath = $Destination 

# Generate a new GUID for the project
$ProjectGUID = new-guid

# Update app.json with new values
Write-Host '------------------------------------- Updating App.JSON --------------------------------------'
$appJSONPath = $MainFolderPath + '\app.json'

$a = Get-Content $appJSONPath -raw | ConvertFrom-Json
$a.id=$ProjectGUID.Guid
$a.name = $ProjectName

# Function to format JSON with proper indentation (like VS Code)
function Format-Json {
    param([string]$Json, [int]$IndentSize = 2)
    
    $indent = 0
    $result = ""
    $inString = $false
    $escapeNext = $false
    
    for ($i = 0; $i -lt $Json.Length; $i++) {
        $char = $Json[$i]
        
        if ($escapeNext) {
            $result += $char
            $escapeNext = $false
            continue
        }
        
        if ($char -eq '\') {
            $result += $char
            $escapeNext = $true
            continue
        }
        
        if ($char -eq '"') {
            $inString = !$inString
            $result += $char
            continue
        }
        
        if ($inString) {
            $result += $char
            continue
        }
        
        switch ($char) {
            '{' {
                $result += $char + "`r`n"
                $indent += $IndentSize
                $result += " " * $indent
            }
            '}' {
                $result = $result.TrimEnd()
                $result += "`r`n"
                $indent -= $IndentSize
                $result += " " * $indent + $char
            }
            '[' {
                $result += $char + "`r`n"
                $indent += $IndentSize
                $result += " " * $indent
            }
            ']' {
                $result = $result.TrimEnd()
                $result += "`r`n"
                $indent -= $IndentSize
                $result += " " * $indent + $char
            }
            ',' {
                $result += $char + "`r`n"
                $result += " " * $indent
            }
            ':' {
                $result += $char + " "
            }
            default {
                if ($char -notin @(' ', "`t", "`r", "`n")) {
                    $result += $char
                }
            }
        }
    }
    
    return $result.Trim()
}

# Save the updated app.json
$compactJson = $a | ConvertTo-Json -depth 32 -Compress
$formattedJson = Format-Json -Json $compactJson
$formattedJson | Set-Content $appJSONPath -Encoding UTF8

Write-Host 'Clone completed successfully. Time to check in your code!'