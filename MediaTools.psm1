# ==============================
# MediaTools PowerShell Module
# Portable Edition
# ==============================

# Resolve module root
$Script:ModuleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load config
$ConfigPath = Join-Path $Script:ModuleRoot "media.config.json"
if (!(Test-Path $ConfigPath)) {
    throw "media.config.json not found in module directory."
}

$Script:Config = Get-Content $ConfigPath | ConvertFrom-Json

# Resolve media root
$Script:MediaRoot = $Script:Config.MediaRoot
if (!(Test-Path $Script:MediaRoot)) {
    New-Item -ItemType Directory -Path $Script:MediaRoot | Out-Null
}

# Logging
function Write-MediaLog {
    param([string]$Message)

    if (-not $Script:Config.LoggingEnabled) { return }

    $LogPath = Join-Path $Script:ModuleRoot $Script:Config.LogFile
    $LogDir  = Split-Path $LogPath

    if (!(Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir | Out-Null
    }

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "[$Timestamp] $Message"
}

# ==============================
# Tool Wrappers
# ==============================

function ytd {
    param([Parameter(ValueFromRemainingArguments=$true)]$Args)

    Write-MediaLog "yt-dlp $Args"

    python3 -m yt_dlp `
        -f "bv*+ba/b" `
        --merge-output-format mp4 `
        --no-playlist `
        --embed-metadata `
        --embed-thumbnail `
        --download-archive (Join-Path $Script:MediaRoot $Script:Config.YouTube.ArchiveFile) `
        -P $Script:MediaRoot `
        -o $Script:Config.YouTube.OutputTemplate `
        @Args
}

function gdl {
    param([Parameter(ValueFromRemainingArguments=$true)]$Args)

    Write-MediaLog "gallery-dl $Args"

    python3 -m gallery_dl `
        --cookies-from-browser $Script:Config.Browser `
        --destination $Script:MediaRoot `
        -o $Script:Config.GalleryDL.OutputTemplate `
        @Args
}

function khinsider {
    param([Parameter(ValueFromRemainingArguments=$true)]$Args)

    $KhinsiderPath = Join-Path $Script:ModuleRoot "tools\khinsider\khinsider.py"

    Write-MediaLog "khinsider $Args"

    if (-not $Args) {
        Write-Host "Usage: media <khinsider-url-or-album-slug>"
        return
    }

    $input = $Args[0]

    # If full URL, extract album slug
    if ($input -match "/album/([^/?]+)") {
        $AlbumSlug = $Matches[1]
    }
    else {
        # Assume user passed slug directly
        $AlbumSlug = $input
    }

    # Convert slug to readable folder name
    $FolderName = ($AlbumSlug -replace '-', ' ').Trim()

    # Build tool-specific directory
    $ToolRoot = Join-Path $Script:MediaRoot "khinsider"
    $OutputPath = Join-Path $ToolRoot $FolderName

    # Create directory if it doesn't exist
    New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null

    # Execute download
    & python3 $KhinsiderPath $AlbumSlug $OutputPath
}

function bunkr {
    param([Parameter(ValueFromRemainingArguments=$true)]$Args)

    $BunkrPath = Join-Path $Script:ModuleRoot "tools\bunkr\downloader.py"

    Write-MediaLog "bunkr $Args"

    python3 $BunkrPath `
        --custom-path $Script:MediaRoot `
        @Args
}

function coomer {
    param([Parameter(ValueFromRemainingArguments=$true)]$Args)

    $CoomerPath = Join-Path $Script:ModuleRoot "tools\coomerdl\coomerdl.py"

    Write-MediaLog "coomerdl $Args"

    Push-Location $Script:MediaRoot
    python3 $CoomerPath @Args
    Pop-Location
}

function imhentai {
    param([Parameter(ValueFromRemainingArguments=$true)]$Args)

    $ImhentaiPath = Join-Path $Script:ModuleRoot "tools\imhentai\main.py"

    Write-MediaLog "imhentai $Args"

    python3 $ImhentaiPath `
        --output $Script:MediaRoot `
        @Args
}



# ==============================
# Unified Router
# ==============================

function media {
    param([Parameter(ValueFromRemainingArguments=$true)]$Args)

    if (-not $Args) {
        Write-Host "Usage: media <url> [options]"
        return
    }

    $url = $Args[0]

    switch -Regex ($url) {
        "khinsider\.com"         { khinsider @Args; break }
        "^battle-|^album-"       { khinsider @Args; break }
        "bunkr\."                { bunkr @Args; break }
        "coomer\."               { coomer @Args; break }
        "youtube\.com|youtu\.be" { ytd @Args; break }
        default                  { gdl @Args }
    }
}


function media-update {
    Write-Host "Updating gallery-dl..."
    python3 -m pip install -U gallery-dl

    Write-Host "Updating yt-dlp..."
    python3 -m pip install -U yt-dlp

    Write-Host "Done."
}

Export-ModuleMember -Function media, media-update, ytd, gdl, khinsider, bunkr, imhentai
