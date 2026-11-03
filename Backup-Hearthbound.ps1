# Backs up Hearthbound's saved data and writes it into Seed.lua so the addon
# can load it next time. Works around the Warcraft Forever beta bug where the
# game saves addon data on exit but never reads it back.
#
# Run it after closing the game (double-click "Backup Hearthbound.bat").

$ErrorActionPreference = "Stop"

$addonDir = $PSScriptRoot
$wtf = Join-Path $addonDir "..\..\..\WTF\Account"
$seedPath = Join-Path $addonDir "Seed.lua"
$backupRoot = Join-Path $addonDir "Backups"
$keepBackups = 15
$utf8 = New-Object System.Text.UTF8Encoding $false

function Pause-IfDoubleClicked {
    if ($env:HEARTHBOUND_NO_PAUSE -ne "1") { Read-Host "Press Enter to close" | Out-Null }
}

if (-not (Test-Path $wtf)) {
    Write-Host "Couldn't find the WTF folder at $wtf" -ForegroundColor Red
    Pause-IfDoubleClicked
    exit 1
}

if (Get-Process -Name "WowB", "Wow*" -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*_classic_beta_*" }) {
    Write-Host "The game is still running. Close it first - it saves addon data when it exits." -ForegroundColor Yellow
    Pause-IfDoubleClicked
    exit 1
}

# Account-wide file: WTF\Account\<account>\SavedVariables\Hearthbound.lua
$globalFiles = @(Get-ChildItem -Path (Join-Path $wtf "*\SavedVariables\Hearthbound.lua") -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending)
# Per character: WTF\Account\<account>\<realm>\<character>\SavedVariables\Hearthbound.lua
$charFiles = @(Get-ChildItem -Path (Join-Path $wtf "*\*\*\SavedVariables\Hearthbound.lua") -ErrorAction SilentlyContinue)

if ($globalFiles.Count -eq 0 -and $charFiles.Count -eq 0) {
    Write-Host "No Hearthbound saved data found yet. Play with the addon, exit the game, then run this again." -ForegroundColor Yellow
    Pause-IfDoubleClicked
    exit 0
}

# 1. Timestamped copy of the raw files, keeping the most recent few
$stamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupDir = Join-Path $backupRoot $stamp
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
if ($globalFiles.Count -gt 0) {
    Copy-Item $globalFiles[0].FullName (Join-Path $backupDir "account.lua")
}
foreach ($file in $charFiles) {
    $charFolder = $file.Directory.Parent.Name
    $realmFolder = $file.Directory.Parent.Parent.Name
    Copy-Item $file.FullName (Join-Path $backupDir ("{0}_{1}.lua" -f $realmFolder, $charFolder))
}
Get-ChildItem $backupRoot -Directory | Sort-Object Name -Descending | Select-Object -Skip $keepBackups |
    Remove-Item -Recurse -Force

# 2. Seed.lua: the same data renamed so the addon can load it as code
$seed = New-Object System.Text.StringBuilder
[void]$seed.AppendLine("-- Backup of Hearthbound's saved data, written by `"Backup Hearthbound.bat`" on $(Get-Date -Format 'yyyy-MM-dd HH:mm').")
[void]$seed.AppendLine("-- Loaded at startup; only used when the game didn't load the saved data itself.")
[void]$seed.AppendLine("HearthboundSeedChars = {}")

if ($globalFiles.Count -gt 0) {
    $text = [System.IO.File]::ReadAllText($globalFiles[0].FullName)
    $converted = [regex]::Replace($text, '(?m)^HearthboundDB\s*=', 'HearthboundSeedDB =', 1)
    if ($converted -ne $text) { [void]$seed.AppendLine($converted) }
}

$charCount = 0
foreach ($file in $charFiles) {
    $text = [System.IO.File]::ReadAllText($file.FullName)
    $match = [regex]::Match($text, '(?m)^HearthboundCharDB\s*=')
    if (-not $match.Success) { continue }
    $folder = $file.Directory.Parent.Name -replace '["\\]', ''
    $body = $text.Substring($match.Index + $match.Length)
    [void]$seed.AppendLine("HearthboundSeedChars[#HearthboundSeedChars + 1] = { folder = `"$folder`", data =")
    [void]$seed.AppendLine($body.TrimEnd())
    [void]$seed.AppendLine("}")
    $charCount++
}

[System.IO.File]::WriteAllText($seedPath, $seed.ToString(), $utf8)

# 3. Dungeon pictures you add to Images\Incoming become journal images
$imagesDir = Join-Path $addonDir "Images"
$photoTimes = @{}
$newPictures = @()

function Save-DungeonPicture([string]$source, [string]$dest) {
    # crop the middle of the picture to 2:1 and save it at 512x256 - plenty for the journal, and small
    Add-Type -AssemblyName System.Drawing
    $img = [System.Drawing.Image]::FromFile($source)
    try {
        $w, $h = $img.Width, $img.Height
        if ($w / $h -gt 2) { $cw, $ch = [int]($h * 2), $h } else { $cw, $ch = $w, [int]($w / 2) }
        $from = New-Object System.Drawing.Rectangle ([int](($w - $cw) / 2)), ([int](($h - $ch) / 2)), $cw, $ch
        $bmp = New-Object System.Drawing.Bitmap 512, 256
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.DrawImage($img, (New-Object System.Drawing.Rectangle 0, 0, 512, 256), $from, [System.Drawing.GraphicsUnit]::Pixel)
        $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
        $params = New-Object System.Drawing.Imaging.EncoderParameters 1
        $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), 82L
        $bmp.Save($dest, $codec, $params)
        $g.Dispose()
        $bmp.Dispose()
    } finally {
        $img.Dispose()
    }
}

# pictures you saved yourself into Images\Incoming, named after the dungeon
$incomingDir = Join-Path $imagesDir "Incoming"
$dungeonFiles = [ordered]@{
    rfc = "ragefire-chasm"; wc = "wailing-caverns"; dm = "deadmines"; sfk = "shadowfang-keep"; bfd = "blackfathom-deeps"
    stocks = "stockade"; gnomer = "gnomeregan"; rfk = "razorfen-kraul"; sm = "scarlet-monastery"; rfd = "razorfen-downs"
    ulda = "uldaman"; zf = "zulfarrak"; mara = "maraudon"; st = "sunken-temple"; brd = "blackrock-depths"
    lbrs = "lower-blackrock-spire"; ubrs = "upper-blackrock-spire"; diremaul = "dire-maul"; scholo = "scholomance"
    strat = "stratholme"; thanes = "hall-of-thanes"; lordaeron = "ruins-of-lordaeron"; excavation = "excavation-site"
    dalaran = "city-of-dalaran"; drowned = "drowned-city"; kroldok = "kroldok-stronghold"; alcaz = "alcaz-island-prison"
    blackmaw = "blackmaw-hold"; shapers = "shapers-terrace"
}
New-Item -ItemType Directory -Force -Path $incomingDir | Out-Null
$readme = Join-Path $incomingDir "READ ME - file names.txt"
if (-not (Test-Path $readme)) {
    $lines = @("Save a picture here named after its dungeon, then run Backup Hearthbound.bat with the game closed.",
               "It's cropped to a wide banner and appears on that dungeon's card and page after you log in.",
               "Formats: .jpg, .jpeg, .png, .bmp or .gif (not .webp). Use these names:", "")
    $lines += $dungeonFiles.Values | ForEach-Object { "  $_.jpg" }
    [System.IO.File]::WriteAllLines($readme, $lines)
}
foreach ($pic in Get-ChildItem $incomingDir -File | Where-Object { $_.Extension -in ".jpg", ".jpeg", ".png", ".bmp", ".gif" }) {
    # compare letters and digits only, without a leading "the", so "Zul'Farrak", "zul-farrak",
    # "ZulFarrak" and "The Deadmines" / "deadmines" all match
    $name = ($pic.BaseName.ToLower() -replace "[^a-z0-9]", "") -replace "^the", ""
    $key = ($dungeonFiles.Keys | Where-Object { (($dungeonFiles[$_] -replace "-", "") -replace "^the", "") -eq $name -or $_ -eq $name } | Select-Object -First 1)
    if (-not $key) { Write-Host "Don't know which dungeon '$($pic.Name)' is for - see the READ ME for names." -ForegroundColor Yellow; continue }
    try {
        Save-DungeonPicture $pic.FullName (Join-Path $imagesDir "$key.jpg")
        Remove-Item $pic.FullName
        $newPictures += $key
    } catch {
        Write-Host "Couldn't read '$($pic.Name)' as an image." -ForegroundColor Yellow
    }
}

# every picture in Images, so the addon knows which exist
$photoLua = New-Object System.Text.StringBuilder
[void]$photoLua.AppendLine("local ADDON_NAME, ns = ...")
[void]$photoLua.AppendLine("")
[void]$photoLua.AppendLine("-- Your dungeon pictures, written by `"Backup Hearthbound.bat`" from pictures")
[void]$photoLua.AppendLine("-- added to Images\Incoming. Updated $(Get-Date -Format 'yyyy-MM-dd HH:mm').")
[void]$photoLua.AppendLine("ns.PHOTOS = {")
if (Test-Path $imagesDir) {
    foreach ($img in Get-ChildItem $imagesDir -Filter *.jpg | Where-Object { $_.BaseName -match '^\w+$' }) {
        [void]$photoLua.AppendLine("    $($img.BaseName) = `"Interface\\AddOns\\Hearthbound\\Images\\$($img.BaseName).jpg`",")
    }
}
[void]$photoLua.AppendLine("}")
[void]$photoLua.AppendLine("ns.PHOTO_TIMES = {")
$oldPhotoData = Join-Path $addonDir "PhotoData.lua"
if (Test-Path $oldPhotoData) {
    # keep the times of pictures made in earlier runs
    foreach ($m in [regex]::Matches([System.IO.File]::ReadAllText($oldPhotoData), '(?m)^\s+(\w+) = (\d+),')) {
        if (-not $photoTimes.ContainsKey($m.Groups[1].Value)) { $photoTimes[$m.Groups[1].Value] = [int64]$m.Groups[2].Value }
    }
}
foreach ($key in $photoTimes.Keys) { [void]$photoLua.AppendLine("    $key = $($photoTimes[$key]),") }
[void]$photoLua.AppendLine("}")
[System.IO.File]::WriteAllText($oldPhotoData, $photoLua.ToString(), $utf8)
if ($newPictures.Count -gt 0) {
    Write-Host ("New dungeon pictures: {0}" -f ($newPictures -join ", ")) -ForegroundColor Green
}

Write-Host ("Backed up account settings and {0} character(s)." -f $charCount) -ForegroundColor Green
Write-Host "Copies saved in: $backupDir"
Write-Host "Your data will be restored the next time you log in."
Pause-IfDoubleClicked
