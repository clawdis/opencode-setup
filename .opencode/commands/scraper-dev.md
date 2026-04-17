---
description: Specialized Workflow for developing, fixing, and testing JavLuv scrapers
---

# Scraper Development Workflow

## ⚡ Quick Reference
```
1. Browse site → 2. Code scraper → 3. Build → 4. Test → 5. Verify logs → 6. Update status
```

## 📚 Required Reading
- `.opencode/skills/javluv-scraper-development/SKILL.md`
- `.opencode/skills/javluv-dynamic-scraping/SKILL.md` (for JS-heavy sites)
- `.opencode/memory/semantic_memory.md` (scraper status matrix)

## 🔧 Workflow Steps

### Step 1: Pre-Analysis (MANDATORY)
```powershell
# Browse target website first
Browser Subagent navigate → URL
Browser Subagent → Check DOM structure
```
Document: Element selectors, Date formats, URL patterns

### Step 2: Implementation
1. Create `Movie{SiteName}.cs` in `src/WebScraper/`
2. Inherit from `ModuleBase`
3. Implement `Scrape()` and `ParseDocument(IHtmlDocument)`
4. Add CLI support in `StandaloneScraper/Program.cs`

### Step 3: Build
// turbo
```powershell
.\Build_StandaloneScraper_Release.bat
```

### Step 4: Test
```powershell
.\src\StandaloneScraper\bin\x64\Release\StandaloneScraper.exe --{scraper} {id}
```

### Step 5: Verify Logs
```powershell
Select-String -Path "$env:LOCALAPPDATA\JavLuv\JavLuv.log" -Pattern "\[{Scraper}\]" | Select-Object -Last 20
```

**Success Criteria:**
- `Found title: {title}` ✅
- `Parse complete. Actors: X, Genres: Y, Runtime: Z, Premiered: YYYY-MM-DD` ✅

### Step 6: Update Status
- Update `PROJECT_STATUS.md` History Log
- Update `.opencode/memory/semantic_memory.md` (scraper matrix)

## ⚠️ Common Issues

| Issue | Solution |
|-------|----------|
| `about:blank` in ParseDocument | WebView2 failed - check URL |
| Missing Premiered | Check website DOM for date location |
| DateTime conversion error | `Premiered` is STRING, not DateTime |
| Crash on test | Check threading (use Dispatcher) |