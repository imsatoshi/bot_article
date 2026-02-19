---
name: freqtrade-forcebuy
description: "Execute force buy orders on Freqtrade bot via REST API. Supports manual entry for specific trading pairs with configurable leverage and stake amount. Use when user wants to manually buy a cryptocurrency through their running Freqtrade bot, especially for short-term trades or when the strategy hasn't triggered an entry yet."
---

# Freqtrade Force Buy

Execute manual buy orders on a running Freqtrade trading bot via its REST API.

## When to Use This Skill

Use this skill when:
- User wants to manually enter a position on a specific trading pair
- The automated strategy hasn't triggered an entry yet, but user wants to buy
- User spots a short-term opportunity and wants quick execution
- User says "帮我买入 XXX" or "在 freqtrade 买 XXX"

## Prerequisites

The Freqtrade bot must be:
- Running with API server enabled
- Configured with `force_entry_enable: true`
- Accessible via SSH or local network

## Quick Start

### Basic Force Buy

```bash
python {baseDir}/scripts/forcebuy.py --pair ZEC/USDT:USDT
```

### With Custom Parameters

```bash
python {baseDir}/scripts/forcebuy.py \
  --pair ZEC/USDT:USDT \
  --stake-amount 100 \
  --leverage 3
```

## Usage Examples

### Example 1: Quick Buy

User wants to buy ZEC quickly:
```
User: "帮我买入 ZEC"
AI: 执行 forcebuy --pair ZEC/USDT:USDT
```

### Example 2: Specified Amount

User wants to buy with specific USDT amount:
```
User: "买入 ZEC，用 100 USDT"
AI: 执行 forcebuy --pair ZEC/USDT:USDT --stake-amount 100
```

### Example 3: With Leverage

User wants leveraged position:
```
User: "开多 ZEC，3倍杠杆"
AI: 执行 forcebuy --pair ZEC/USDT:USDT --leverage 3
```

## Configuration

Edit `{baseDir}/config/settings.yaml`:

```yaml
freqtrade:
  host: "your_server_ip"
  port: 22
  username: "your_username"
  password: "YOUR_PASSWORD_HERE"  # 不要上传到 Git！
  api_port: 8989
  api_username: "admin"
  api_password: "YOUR_API_PASSWORD_HERE"  # 不要上传到 Git！
```

⚠️ **安全提示**: 不要将包含真实密码的配置文件上传到 GitHub！

## API Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `pair` | Trading pair (e.g., ZEC/USDT:USDT) | Required |
| `stake_amount` | Amount in stake currency | null (use strategy default) |
| `leverage` | Leverage for futures | null (use strategy default) |
| `price` | Entry price (null for market) | null |

## Output

The script returns JSON with trade details:
- `trade_id`: Trade identifier
- `pair`: Trading pair
- `open_rate`: Entry price
- `stake_amount`: Margin used
- `leverage`: Leverage applied
- `stop_loss_abs`: Stop loss price

## Error Handling

Common errors:
- `Unauthorized`: Check API credentials
- `Pair not in whitelist`: Add pair to config
- `Insufficient funds`: Check available balance
- `Force entry disabled`: Enable in config

## References

- Freqtrade API docs: https://www.freqtrade.io/en/stable/rest-api/
- Force buy endpoint: POST /api/v1/forcebuy
