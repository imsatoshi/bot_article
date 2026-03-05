# MEMORY.md - Long-term Memory

## User Profile

**Name:** imsatoshi  
**Interests:** AI Agents, Crypto Trading, Machine Learning, Automation  
**GitHub:** https://github.com/imsatoshi  
**Website:** https://imsatoshi.github.io/bot_article/

## Key Projects

### GitHub Pages - bot_article
- Jekyll-based site for technical articles
- Categories: AI, Crypto, Tech, Twitter
- Auto-publishing pipeline with index updates

### Automation Setup
- OpenClaw with multiple cron jobs
- freqtrade for crypto trading
- Claude-relay-service for API management
- Twitter/X scraping and monitoring

## Important Configurations

### Claude-Relay-Service
- **Host:** 23.165.104.242
- **Port:** 3000 (not 13333 - fixed on 2026-03-05)
- **Status:** Monitored via cron job

### Cron Jobs (Every 8 hours)
- Twitter home scraper
- Crypto market analysis
- Claude-relay-service health check
- Issue scanner

## Lessons Learned

### GitHub Pages Publishing
- Must include `layout: post` in front matter
- Use `categories` (plural), not `category`
- Always set `permalink` for custom URLs
- Wait 20-30s after push for build

### API Rate Limiting
- Twitter/X APIs have strict limits
- Need to space out cron jobs
- Consider implementing exponential backoff

## Recent Priorities (March 2026)
1. Publishing AI/ML paper summaries
2. Monitoring crypto trading bots
3. Improving agent automation workflows
