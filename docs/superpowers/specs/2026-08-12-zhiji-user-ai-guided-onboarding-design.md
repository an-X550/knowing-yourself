# Zhiji User AI-Guided Onboarding Design

## Problem

The distribution package contains the local review runtime and optional Feishu/TickTick distribution contracts, but capability presence is not the same as user usability. A new user must first understand what the project does, obtain one useful local result, and only then decide whether to configure external delivery. Existing environment acceptance also cannot prove that a different user's machine, tenant, account, or connector is ready.

## First-Principles Success Criteria

The user README must answer, in this order:

1. What value the project creates and what functions exist.
2. What the user can say to the AI to invoke each function.
3. How to obtain the first useful local result without external services.
4. How to delegate optional Feishu/TickTick setup to the AI.
5. Which official login, authorization, application, or client actions require the user.
6. Which identifiers the AI may store and which secrets must never enter chat or project files.
7. How the AI and user determine local, Feishu, and TickTick success independently.

## Design

### User README

Keep the product explanation, function map, and first local loop ahead of deployment. Add an “AI-assisted optional setup” section containing a copyable task prompt. The prompt instructs the AI to read the setup guide, automate safe work, pause for one human-only action at a time, resume on “继续”, never request secrets in chat, and report three independent readiness states.

Add short human-action cards for Feishu and TickTick. They explain official downloads, account-region choice, required client-side list/application preparation, and the division of responsibility between the user and AI. Add copyable daily-use prompts so setup is not the end of onboarding.

### Setup Guide

Turn the existing technical guide into an AI-executable contract without duplicating the README. Define execution order, pause/resume behavior, permitted identifiers, prohibited secrets, and success criteria. The AI may persist non-sensitive folder tokens and `project_id` in the ignored runtime config. App Secret, access/OAuth/MCP tokens, authorization responses, and similar credentials remain in official tools and pages only.

### Distribution Safety

Protect `复盘/.result-distribution-config.json` and `复盘/.result-distribution-state.json` in the user package `.gitignore`. Keep overlay and generated `zhiji-user` synchronized through the existing export script.

## Non-Goals

- No custom installer or deployment executable.
- No attempt to automate official login, consent, secret entry, or tenant-admin decisions.
- No new Feishu/TickTick runtime behavior.
- No promise that main-project acceptance proves a new user's external environment is ready.

## Verification

- Contract tests assert the README function map, AI setup prompt, human-only steps, safety boundary, daily prompts, and three-channel success report.
- Setup tests assert the AI execution contract and Git-ignore protection.
- Export integrity proves overlay and `zhiji-user` remain identical for managed files.
- Full PowerShell regression suite and version-governance checks pass.
