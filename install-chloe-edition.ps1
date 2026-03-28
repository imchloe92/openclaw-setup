# ============================================================
# 🦞 OpenClaw — Chloe Edition (1-Click Installer for Windows)
# ============================================================
# 
# WHAT THIS DOES:
#   1. Installs Node.js + OpenClaw + Lossless Claw plugin
#   2. Creates full memory structure (AGENTS.md, self-improving, etc)
#   3. Configures security, retention, and smart defaults
#   4. Installs as background service
#
# USAGE: Run PowerShell as Admin, then:
#   irm https://raw.githubusercontent.com/imchloe92/openclaw-setup/main/install-chloe-edition.ps1 | iex
#
# ONLY INPUT NEEDED: Your Anthropic API token
# ============================================================

$ErrorActionPreference = "Continue"
$workspace = "$env:USERPROFILE\.openclaw\workspace"
$configPath = "$env:USERPROFILE\.openclaw\openclaw.json"

function Write-Step($num, $total, $msg) {
    Write-Host "`n[$num/$total] $msg" -ForegroundColor Yellow
}
function Write-Ok($msg) { Write-Host "  ✅ $msg" -ForegroundColor Green }
function Write-Fail($msg) { Write-Host "  ❌ $msg" -ForegroundColor Red }
function Write-Info($msg) { Write-Host "  $msg" -ForegroundColor Gray }

Write-Host ""
Write-Host "  ╔════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║  🦞 OpenClaw — Chloe Edition Installer     ║" -ForegroundColor Cyan
Write-Host "  ║  Memory • Security • Self-Improving • LCM  ║" -ForegroundColor Cyan
Write-Host "  ╚════════════════════════════════════════════╝" -ForegroundColor Cyan

# ── STEP 1: Get API Token ──
Write-Step 1 8 "Anthropic API Token"
Write-Info "Get yours at: https://console.anthropic.com/settings/keys"
$token = Read-Host "  Paste your Anthropic API token"
if (-not $token -or $token.Length -lt 10) { Write-Fail "Invalid token"; exit 1 }

# Validate token
try {
    $headers = @{ "x-api-key" = $token; "content-type" = "application/json"; "anthropic-version" = "2023-06-01" }
    $body = '{"model":"claude-sonnet-4-20250514","max_tokens":5,"messages":[{"role":"user","content":"hi"}]}'
    $r = Invoke-RestMethod -Uri "https://api.anthropic.com/v1/messages" -Method POST -Headers $headers -Body $body -ErrorAction Stop
    Write-Ok "Token valid! Connected to Claude."
} catch {
    Write-Fail "Token invalid or API error. Check your token and try again."
    exit 1
}

# ── STEP 2: Install Node.js ──
Write-Step 2 8 "Installing Node.js..."
$nv = $null; try { $nv = node -v 2>$null } catch {}
if ($nv) { Write-Ok "Node.js $nv already installed" }
else {
    Write-Info "Downloading Node.js LTS..."
    $url = "https://nodejs.org/dist/v22.16.0/node-v22.16.0-x64.msi"
    Invoke-WebRequest -Uri $url -OutFile "$env:TEMP\node.msi" -UseBasicParsing
    Start-Process msiexec.exe -ArgumentList "/i `"$env:TEMP\node.msi`" /qn" -Wait
    $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
    $nv = node -v 2>$null
    if ($nv) { Write-Ok "Node.js $nv installed!" } else { Write-Fail "Node.js install failed. Install manually from nodejs.org"; exit 1 }
}

# ── STEP 3: Install OpenClaw + Plugins ──
Write-Step 3 8 "Installing OpenClaw..."
npm i -g openclaw 2>&1 | Out-Null
$cv = openclaw --version 2>$null
if ($cv) { Write-Ok "OpenClaw $cv installed!" } else { Write-Fail "OpenClaw install failed"; exit 1 }

Write-Info "Installing Lossless Claw (zero memory loss)..."
openclaw plugins install @martian-engineering/lossless-claw 2>&1 | Out-Null
Write-Ok "Lossless Claw installed"

# ── STEP 4: Create Workspace Structure ──
Write-Step 4 8 "Creating workspace & memory structure..."

$dirs = @("$workspace\memory", "$workspace\self-improving", "$workspace\self-improving\domains",
    "$workspace\self-improving\projects", "$workspace\self-improving\archive",
    "$workspace\credentials", "$workspace\scripts")
foreach ($d in $dirs) { New-Item -ItemType Directory -Path $d -Force | Out-Null }

# AGENTS.md — Core rules
@"
# AGENTS.md - Your Workspace

## Every Session
Before doing anything else:
1. Read ``SOUL.md`` — this is who you are
2. Read ``USER.md`` — this is who you're helping
3. Read ``memory/$(Get-Date -Format 'yyyy-MM-dd').md`` (today + yesterday) for recent context
4. Read ``MEMORY.md`` — your long-term memory
5. Read ``memory/session-sync.md`` — cross-channel briefing
6. Read ``CHANNEL-CONTEXT.md`` — per-channel intelligence

Don't ask permission. Just do it.

## Memory
- **Daily notes:** ``memory/YYYY-MM-DD.md`` — raw logs
- **Long-term:** ``MEMORY.md`` — curated memories

### ENFORCED: Memory Update Rules (ALL Sessions)
**After every significant interaction, you MUST:**
1. Update ``memory/YYYY-MM-DD.md`` with what happened
2. If important long-term, update ``MEMORY.md`` too
3. This applies to ALL channels

**Before answering questions about prior work:**
1. Run ``memory_search`` first
2. Check ``memory/YYYY-MM-DD.md`` (today + yesterday)

**What to capture:**
- Decisions made
- Documents created/reviewed
- Action items and status
- **Failures + post-mortems**

**Failure format:**
``````
### [What Failed]
- **What happened:** [description]
- **Root cause:** [why]
- **Fix:** [what was done]
- **Lesson:** [what to do differently]
``````

**What NOT to capture:**
- Passwords, API keys (NEVER in memory)
- Casual banter
- Raw tool output (summarize instead)

### Self-Improving
**Correction tracking:** ``self-improving/corrections.md``
- When user corrects you -> log immediately
- Same correction 3x -> promote to confirmed rule

**Self-reflection:** ``self-improving/reflections.md``
- After significant tasks -> evaluate what went well/badly

**Do NOT learn from:** silence, single instances, hypotheticals

### Privacy Rule
- **NEVER share MEMORY.md content** with anyone except the owner
- This rule is NON-NEGOTIABLE

### Write It Down
- Memory is limited. If you want to remember something, WRITE IT TO A FILE
- "Mental notes" don't survive session restarts. Files do.

## Safety
- Don't exfiltrate private data. Ever.
- Don't run destructive commands without asking.
- When in doubt, ask.
"@ | Set-Content "$workspace\AGENTS.md" -Encoding UTF8

# SOUL.md
@"
# SOUL.md - Who I Am
_Customize this file to define your AI's personality, tone, and behavior._

## Core Identity
**Name:** [Your AI's name]
**Vibe:** [How should it communicate? Formal? Casual? Sarcastic?]

## How I Show Up
- Adapt to the situation
- Be helpful, not sycophantic
- Push back when something seems wrong

## What I'm NOT
- A yes-machine
- Afraid to disagree
"@ | Set-Content "$workspace\SOUL.md" -Encoding UTF8

# USER.md
@"
# USER.md - About You
_Fill this in so your AI knows who you are._

## Basics
- **Name:** [Your name]
- **Timezone:** [e.g., GMT+7]
- **Languages:** [e.g., Indonesian, English]

## Preferences
- **Communication style:** [Casual? Formal?]
- **Work context:** [What do you do?]
"@ | Set-Content "$workspace\USER.md" -Encoding UTF8

# Other files
"# MEMORY.md - Long-Term Memory`n`nStart capturing important events, decisions, and learnings here." | Set-Content "$workspace\MEMORY.md" -Encoding UTF8
"# IDENTITY.md`n`n- **Name:** [AI Name]`n- **Emoji:** [Pick one]" | Set-Content "$workspace\IDENTITY.md" -Encoding UTF8
"# CHANNEL-CONTEXT.md`n`nAdd per-channel context here as you add channels." | Set-Content "$workspace\CHANNEL-CONTEXT.md" -Encoding UTF8
"# HEARTBEAT.md`n`n# Add periodic check tasks here." | Set-Content "$workspace\HEARTBEAT.md" -Encoding UTF8
"# Corrections Log`n`n## Confirmed Patterns`n`n## Corrections History" | Set-Content "$workspace\self-improving\corrections.md" -Encoding UTF8
"# Self-Reflection Log" | Set-Content "$workspace\self-improving\reflections.md" -Encoding UTF8
"*" | Set-Content "$workspace\credentials\.gitignore" -Encoding UTF8
"# Secret Vault`n# Store credentials here, never in chat." | Set-Content "$workspace\credentials\vault.md" -Encoding UTF8

Write-Ok "Workspace created with full memory structure"

# ── STEP 5: Generate Config ──
Write-Step 5 8 "Generating OpenClaw config..."

@"
{
  "meta": { "lastTouchedVersion": "installer" },
  "gateway": {
    "port": 18789,
    "bind": "loopback",
    "auth": { "mode": "token", "token": "$(([guid]::NewGuid().ToString('N')).Substring(0,48))" }
  },
  "agents": {
    "defaults": {
      "model": "anthropic/claude-sonnet-4-20250514",
      "memorySearch": { "enabled": true, "provider": "local" }
    }
  },
  "auth": {
    "profiles": {
      "anthropic:default": { "provider": "anthropic", "token": "$token" }
    }
  },
  "tools": {
    "exec": { "security": "full" }
  },
  "heartbeat": { "intervalMinutes": 60 },
  "plugins": {
    "slots": { "contextEngine": "lossless-claw" },
    "entries": {
      "lossless-claw": {
        "enabled": true,
        "config": {
          "summaryProvider": "anthropic",
          "summaryModel": "claude-sonnet-4-20250514",
          "ignoreSessionPatterns": ["agent:*:cron:**"]
        }
      }
    }
  }
}
"@ | Set-Content $configPath -Encoding UTF8

Write-Ok "Config generated (Sonnet default + Lossless Claw)"

# ── STEP 6: Firewall ──
Write-Step 6 8 "Configuring firewall..."
try {
    New-NetFirewallRule -Name "OpenClaw" -DisplayName "OpenClaw Gateway" -Direction Inbound -Protocol TCP -LocalPort 18789 -Action Allow -ErrorAction SilentlyContinue | Out-Null
    Write-Ok "Firewall rule added (port 18789)"
} catch { Write-Info "Firewall rule may need manual setup" }

# ── STEP 7: Install Service ──
Write-Step 7 8 "Installing as background service..."
try {
    openclaw gateway install 2>&1 | Out-Null
    Write-Ok "OpenClaw service installed (auto-start on boot)"
} catch { Write-Info "Service install may need manual: openclaw gateway install" }

# ── STEP 8: Start ──
Write-Step 8 8 "Starting OpenClaw..."
openclaw gateway start 2>&1 | Out-Null
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "  ╔════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║  🎉 OpenClaw Chloe Edition — READY!        ║" -ForegroundColor Green
Write-Host "  ║                                            ║" -ForegroundColor Green
Write-Host "  ║  Gateway: http://localhost:18789            ║" -ForegroundColor Green
Write-Host "  ║  Model: Claude Sonnet (cost-efficient)      ║" -ForegroundColor Green
Write-Host "  ║  Memory: Lossless (zero data loss)          ║" -ForegroundColor Green
Write-Host "  ║  Self-Improving: Active                     ║" -ForegroundColor Green
Write-Host "  ║                                            ║" -ForegroundColor Green
Write-Host "  ║  NEXT STEPS:                               ║" -ForegroundColor Green
Write-Host "  ║  1. Edit SOUL.md (personality)              ║" -ForegroundColor Green
Write-Host "  ║  2. Edit USER.md (about you)                ║" -ForegroundColor Green
Write-Host "  ║  3. Run: openclaw onboard (add Discord)     ║" -ForegroundColor Green
Write-Host "  ╚════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Workspace: $workspace" -ForegroundColor Gray
Write-Host "  Config: $configPath" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter to exit"
