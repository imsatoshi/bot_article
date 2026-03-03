---
layout: post
title: "Claude Cowork 17 Best Practices"
date: 2026-03-04
categories: ai
tags: [Claude, Cowork, AI, Agent]
permalink: /ai/claude-cowork-best-practices/
---

# Claude Cowork 17 Best Practices

> Original: Nav Toor on X (via @michaelxbt)  
> Compiled: 2026-03-04

## Introduction

The author started using Claude Cowork on January 12, the day it launched. In seven weeks, running 400+ Cowork sessions and testing every plugin, connector, and slash command. The key insight: **what makes Cowork go from "kind of cool" to "replaced half my software stack" has nothing to do with prompting skill—it's about setup, structure, and 17 specific practices**.

## Foundation Layer: 5 Game-Changing Practices

### 1. Create _MANIFEST.md Files

**Problem**: When pointing Cowork at a folder, Claude reads everything—every file, subfolder, outdated draft. A developer documented 462-file consulting folder producing contradictory output from replaced pricing models.

**Solution**: Place `_MANIFEST.md` in each working folder (underscore keeps it at top).

**Three Tiers**:
- **Tier 1 (Canonical)**: Source-of-truth documents—brand guidelines, project briefs, current strategy
- **Tier 2 (Domain)**: Subfolders mapped to topics—`/pricing → pricing models`, `/research → competitor analysis`
- **Tier 3 (Archival)**: Old drafts, superseded versions—ignored unless explicitly requested

**Impact**: 5 minutes to fill out, saves hours of confused output.

### 2. Write Global Instructions

**Path**: Settings → Cowork → Edit next to Global Instructions

**Example**:
```
I'm [name], a [role]. Before any task, look for _MANIFEST.md and read Tier 1 files first. 
Always ask clarifying questions before executing. Show a brief plan before taking action. 
Default output: .docx. Never use filler language. Quality bar: client-ready without editing.
If confidence is low, say so.
```

**Impact**: Even rushed prompts produce calibrated output.

### 3. Build Claude Context Folder

Create "Claude Context" folder (or "00_Context" to sort first) with three files:

**about-me.md**: Professional identity—not your resume. What you do, who you serve, priorities, best work examples.

**brand-voice.md**: Communication style—tone descriptors, words to use/avoid, formatting preferences, writing samples.

**working-style.md**: How Claude should behave—collaboration rules, output defaults, quality standards, things to avoid.

**Key insight**: These files compound. Refine weekly. Most "Claude problems" are context problems, not prompt problems.

### 4. Use Folder Instructions

Global Instructions = universal behavior. Folder Instructions = project context. Your prompt = specific task.

Three layers, each more specific. This transforms "generic AI" into "sounds like someone on my team for 6 months."

### 5. Actively Manage Context

Claude's context window is massive (1M+ tokens on Opus 4.6), but bigger ≠ better. More irrelevant files = more noise = worse output.

**In Global Instructions**:
```
When starting any task, look for _MANIFEST.md first. Load Tier 1 files. 
Only load Tier 2 when task explicitly touches that domain. 
Never load Tier 3 unless specifically asked.
```

**For subagents**: Give each only minimum context needed for its subtask.

## Task Layer: 6 Output-Quality Practices

### 6. Define What "Done" Looks Like

**Mindset shift**: Cowork isn't a chatbot, it's a coworker. Tell them what "done" looks like, not step-by-step instructions.

| Bad Prompt | Good Prompt |
|------------|-------------|
| "Help me with my files" | "Organize files by client name. Use YYYY-MM-DD-descriptive-name format. Create summary log. Don't delete anything. If file fits multiple clients, use /needs-review" |

Every task prompt should answer:
1. What does "done" look like?
2. What are the constraints?
3. What should Claude do when uncertain?

### 7. Require a Plan Step

**In Global Instructions**:
```
Show a brief plan before taking action on any task. Wait for approval before executing.
```

**Impact**: Prevents 90% of Cowork disasters. Cost: 30 seconds per task. Benefit: Never undo 20-minute mistakes.

### 8. Build Uncertainty Handling

**Example**:
```
If date isn't clear, mark as VERIFY. If file could go in multiple folders, use /needs-review. 
If confidence < 80%, flag instead of guessing.
```

Transforms Cowork from "sometimes produces errors" to "tells you exactly where it needs judgment."

### 9. Batch Related Tasks

**Don't**: 5 separate sessions for 5 related tasks  
**Do**: 1 session: "Process receipts, update budget, generate report, draft email, save to /monthly-reports/february"

Claude plans all tasks, shares context across them, produces connected deliverables. Faster, cheaper, higher quality.

### 10. Trigger Subagents

**How**: Include "Spin up subagents to..." or "Work on these in parallel using subagents"

**Example**:
```
I'm evaluating four vendors. Spin up subagents to research each one's pricing, support reputation, 
and integration options. Give me a comparison table.
```

**Use for**: Competitive analysis, multi-source research, batch file processing, evaluating options from different angles.

**Caveat**: Best on Opus 4.6, consumes more tokens. Use for complex tasks where time savings justify cost.

### 11. Use /schedule

Type `/schedule` in any Cowork task to set up automatic runs—daily, weekly, monthly, or on-demand.

**Examples**:
- Monday briefing: "Check Slack channels and calendar, summarize week ahead, flag prep needs"
- Friday status: "Pull completed tasks from Asana, summarize shipped work, draft status update"
- Daily tracking: "Research competitors for news, save summary only if something new"

**Limitation**: Only runs when computer is awake and Claude Desktop is open.

## System Layer: 6 Scalable Workflow Practices

### 12. Externalize Everything to Files

Cowork has no memory between sessions. Solution: externalize to files.
- Preferences → context files
- Project plans → markdown documents  
- SOPs → skill files
- Decisions → log files

**Power user example**: 1,500+ lines across 5 specialized subagent instructions for weekly review system. Built once, runs weekly, produces complete review without new input.

### 13. Connectors + Schedule = Autonomous System

Connect Gmail, Slack, Google Drive, Notion, Asana (50+ integrations). Schedule tasks pulling live data:

```
Every Monday: Pull unread Slack messages from #-feedback, categorize by theme, create summary in Google Drive.
Every morning: Check Gmail for invoices, extract amounts/dates, update expenses spreadsheet.
```

**Path**: Settings → Connectors → Browse connectors. Start with Slack and Gmail.

### 14. Layer Plugins

Each plugin = bundle of skills, slash commands, subagent configs for specific domains (Sales, Legal, Finance, etc.).

**Key insight**: Plugins are composable. Install multiple, use capabilities from all in one task.

**Example**:
```
Analyze Q1 pipeline data (use Data Analysis), identify three weakest deals, 
and draft personalized follow-up emails (use Sales).
```

**Author's stack**: Productivity (always), Data Analysis (always), Sales (outreach weeks), Marketing (content weeks).

### 15. Create Custom Skills

Skills are markdown files teaching Claude repeatable tasks.

**Structure**:
```markdown
# [Skill Name]

## Purpose: What this skill does
## Inputs: What Claude needs
## Process: Step-by-step instructions
## Output: What finished deliverable looks like
## Constraints: Rules and guardrails
```

**Example**: "Weekly Article Drafting" skill
- Purpose: Draft 2,000-word article from topic/outline
- Inputs: topic, outline, audience, evidence
- Process: research → draft sections → match brand-voice.md → generate VISUAL SUGGESTIONS
- Output: .docx in /articles/drafts
- Constraints: no AI semantic language, no filler, min 8 evidence points

### 16. Build Custom Plugins with Plugin Management

Install Plugin Management plugin, then: "Help me create a plugin for [your workflow]."

Claude guides you through defining skills, slash commands, configuration—conversationally. No code, no GitHub, no markdown syntax to learn.

**Enterprise**: Private plugin marketplace launched February. Build once, deploy to hundreds.

### 17. Safety Best Practices

Cowork has real filesystem access. Power demands respect.

| Practice | Why |
|----------|-----|
| Backup before experimenting | "Most of the time" isn't good enough for client contracts |
| Keep sensitive files separate | Financial docs, passwords in folders Cowork never touches |
| Add "Don't delete anything" | Prevent deletion requests entirely |
| Monitor first few runs | Read plans, check outputs, earn trust |
| Be aware of prompt injection | Don't point at untrusted sources without review |
| Track usage | Batch work, use "revise section 2 only", pre-load context via files |

## Core Insight: From Prompt Engineering to System Engineering

Every practice follows the same principle: **Invest in setup. Reduce prompting.**

- **ChatGPT era**: Rewarded prompt engineering
- **Cowork era**: Rewards system engineering

The prompt is the least important part. **Context, structure, skills, and constraints**—that's where quality comes from.

> "It feels less like a conversation and more like leaving tasks for a capable coworker."

## Action Plan

**Today (30 min)**:
- Create three context files
- Set Global Instructions
- Ahead of 95% of users

**This week**:
- Add _MANIFEST.md to most-used project folder
- Install 2-3 role-matching plugins
- Set up one scheduled task

**This month**:
- Build first custom skill for most-repeated workflow
- Experiment with subagents on complex research
- Refine context files based on output quality

## Conclusion

The difference between Cowork as toy vs. system: **17 practices and ~2 hours of setup**.

The gap between those who know these practices and those who don't is already massive. In six months, it'll be a canyon.

---

*MIT licensed, thanks to Nav Toor for sharing.*
