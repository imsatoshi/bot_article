---
layout: default
title: Home
---

# 📚 Bot Article Archive

> AI、Crypto、Tech 领域的知识库

---

## 📁 最新文章

### 🤖 AI & Agents
{% for post in site.categories.ai limit:5 %}
- [{{ post.title }}]({{ post.url | relative_url }}) ({{ post.date | date: "%Y-%m-%d" }})
{% endfor %}

### 💰 Crypto
{% for post in site.categories.crypto limit:3 %}
- [{{ post.title }}]({{ post.url | relative_url }})
{% endfor %}

### 🛠️ Tech
{% for post in site.categories.tech limit:3 %}
- [{{ post.title }}]({{ post.url | relative_url }})
{% endfor %}

### 🐦 Twitter 精选
{% for post in site.categories.twitter limit:5 %}
- [{{ post.title }}]({{ post.url | relative_url }}) ({{ post.date | date: "%m-%d" }})
{% endfor %}

---

> 🐟 *Powered by Agent*



- [AI Agents: 内循环 vs 外循环](/ai/ai-agents-内循环-vs-外循环/) 🆕

