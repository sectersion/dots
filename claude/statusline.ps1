$ErrorActionPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch {}

# All glyphs are built from code points so this file stays pure ASCII (PS 5.1 reads BOM-less files as ANSI).
$ESC   = [char]27
$RST   = "$ESC[0m"
$SEP   = " $ESC[38;2;88;91;112m$([char]0x2502)$RST "
$ICON_MODEL  = [string][char]0x25C6   # diamond
$ICON_BRANCH = [string][char]0x2387   # branch
$ICON_CACHE  = [string][char]0x26A1   # lightning
$ICON_DIR    = [string][char]0x25B8   # small triangle
$ICON_PR     = [string][char]0x21C4   # arrows
$BAR_ON  = [string][char]0x25B0
$BAR_OFF = [string][char]0x25B1

function C([int]$r, [int]$g, [int]$b) { "$ESC[38;2;$r;$g;${b}m" }
function Num($v) { if ($null -eq $v -or "$v" -eq '') { return $null }; try { return [double]$v } catch { return $null } }
function UsageColor($p) { if ($p -gt 80) { C 255 85 85 } elseif ($p -ge 50) { C 250 204 21 } else { C 80 250 123 } }
function Bar($p) {
  $n = [int][math]::Round($p / 20); if ($n -lt 0) { $n = 0 }; if ($n -gt 5) { $n = 5 }
  ($BAR_ON * $n) + ($BAR_OFF * (5 - $n))
}

$segs = New-Object System.Collections.ArrayList
$cwd = $null; $branch = $null

try {
  $raw = [Console]::In.ReadToEnd()
  $j = $null
  if ($raw) { $j = $raw | ConvertFrom-Json }

  if ($j) {
    # Model
    if ($j.model.display_name) {
      [void]$segs.Add("$(C 189 147 249)$ICON_MODEL $($j.model.display_name)$RST")
    }

    # Context window
    $ctx = Num $j.context_window.used_percentage
    if ($null -ne $ctx) {
      $col = UsageColor $ctx
      [void]$segs.Add("$col$(Bar $ctx) $([math]::Round($ctx))%$RST")
    }

    # Prompt cache
    if ($j.prompt_cache -and $j.prompt_cache.caching_observed -eq $true) {
      if ($j.prompt_cache.warm -eq $true) {
        [void]$segs.Add("$(C 94 234 212)$ICON_CACHE warm$RST")
      } else {
        [void]$segs.Add("$(C 96 165 250)$ICON_CACHE cold$RST")
      }
    }

    # cwd
    if ($j.workspace.current_dir) { $cwd = $j.workspace.current_dir } elseif ($j.cwd) { $cwd = $j.cwd }
  }

  # Branch
  if ($cwd -and (Test-Path -LiteralPath $cwd)) {
    $branch = (& git -C $cwd --no-optional-locks branch --show-current 2>$null | Select-Object -First 1)
  }

  # PR: prefer input field, else cached gh lookup
  $prNum = $null; $prState = $null
  if ($j -and $j.pr -and $j.pr.number) {
    $prNum = $j.pr.number
    $prState = $j.pr.review_state
  } elseif ($branch -and $cwd -and (Get-Command gh -ErrorAction SilentlyContinue)) {
    $key = [BitConverter]::ToString([Security.Cryptography.MD5]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes("$cwd|$branch"))).Replace('-', '')
    $cache = Join-Path $env:TEMP "claude-sl-pr-$key.json"
    $data = $null
    if ((Test-Path -LiteralPath $cache) -and (((Get-Date) - (Get-Item -LiteralPath $cache).LastWriteTime).TotalSeconds -lt 60)) {
      $data = Get-Content -LiteralPath $cache -Raw
    } else {
      Push-Location -LiteralPath $cwd
      $data = (& gh pr view --json number,state 2>$null) -join ''
      Pop-Location
      if (-not $data) { $data = '{}' }
      Set-Content -LiteralPath $cache -Value $data -Encoding ASCII
    }
    try {
      $pr = $data | ConvertFrom-Json
      if ($pr.number) { $prNum = $pr.number; $prState = $pr.state }
    } catch {}
  }
  if ($prNum) {
    $stCol = switch -Regex ("$prState") {
      'approved|MERGED' { C 80 250 123 }
      'changes_requested|CLOSED' { C 255 85 85 }
      'draft|DRAFT' { C 148 163 184 }
      default { C 250 204 21 }
    }
    $txt = "$ICON_PR #$prNum"
    if ($prState) { $txt += " ($("$prState".ToLower()))" }
    [void]$segs.Add("$stCol$txt$RST")
  }

  if ($branch) { [void]$segs.Add("$(C 251 146 60)$ICON_BRANCH $branch$RST") }

  if ($cwd) {
    $base = Split-Path -Leaf ($cwd.TrimEnd('\', '/'))
    if (-not $base) { $base = $cwd }
    [void]$segs.Add("$(C 56 189 248)$ICON_DIR $base$RST")
  }

  # Rate limits
  if ($j -and $j.rate_limits) {
    $parts = @()
    $f = Num $j.rate_limits.five_hour.used_percentage
    if ($null -ne $f) { $parts += "$(UsageColor $f)5h $([math]::Round($f))%$RST" }
    $s = Num $j.rate_limits.seven_day.used_percentage
    if ($null -ne $s) { $parts += "$(UsageColor $s)7d $([math]::Round($s))%$RST" }
    if ($parts.Count -gt 0) { [void]$segs.Add(($parts -join ' ')) }
  }
} catch {
  if ($segs.Count -eq 0) { [void]$segs.Add("$(C 148 163 184)statusline$RST") }
}

[Console]::Out.Write(($segs -join $SEP))
