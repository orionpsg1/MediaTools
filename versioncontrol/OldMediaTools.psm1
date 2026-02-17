# ==============================
# MediaTools PowerShell Module
# ==============================

# ---- Tool Paths ----
$Script:KhinsiderPath = "C:\Users\Vance\khinsider-master\khinsider.py"
$Script:BunkrPath     = "C:\Users\Vance\BunkrDownloader\downloader.py"

# ---- Global Download Directory ----
$Script:MediaRoot = "M:\Downloads"

# Ensure root exists
if (!(Test-Path $Script:MediaRoot)) {
    New-Item -ItemType Directory -Path $Script:MediaRoot | Out-Null
}

# ==============================
# Tool Wrappers
# ==============================

function khinsider {
    param([Parameter(ValueFromRemainingArguments=$true)]$Args)

    # Organize by album automatically (handled by script)
    python3 $Script:KhinsiderPath `
        --format mp3 `
        --directory $Script:MediaRoot `
        @Args
}

function bunkr {
    param([Parameter(ValueFromRemainingArguments=$true)]$Args)

    # Assume downloader supports output directory
    python3 $Script:BunkrPath `
        --output $Script:MediaRoot `
        @Args
}

function ytd {
    param([Parameter(ValueFromRemainingArguments=$true)]$Args)

    python3 -m yt_dlp `
        -f "bv*+ba/b" `
        --merge-output-format mp4 `
        --no-playlist `
        --embed-metadata `
        --embed-thumbnail `
        --download-archive "$Script:MediaRoot\yt-archive.txt" `
        -P $Script:MediaRoot `
        -o "%(uploader)s/%(upload_date)s - %(title)s.%(ext)s" `
        @Args
}

function gdl {
    param([Parameter(ValueFromRemainingArguments=$true)]$Args)

    python3 -m gallery_dl `
        --cookies-from-browser firefox `
        --destination $Script:MediaRoot `
        -o "{category}/{username}/{filename}.{extension}" `
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
        "khinsider\.com"             { khinsider @Args; break }
        "bunkr\."                    { bunkr @Args; break }
        "youtube\.com|youtu\.be"     { ytd @Args; break }
        default                      { gdl @Args }
    }
}

# ==============================
# Update All Tools
# ==============================

function media-update {
    Write-Host "Updating gallery-dl..."
    python3 -m pip install -U gallery-dl

    Write-Host "Updating yt-dlp..."
    python3 -m pip install -U yt-dlp

    Write-Host "Done."
}

Export-ModuleMember -Function khinsider, bunkr, ytd, gdl, media, media-update
