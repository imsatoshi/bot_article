---
layout: page
title: Tech
permalink: /tech/
---

# 🛠️ Tech

---

{% for post in site.categories.tech %}
## [{{ post.title }}]({{ post.url | relative_url }})

{{ post.excerpt | strip_html | truncatewords: 30 }}

[阅读全文 →]({{ post.url | relative_url }})

---
{% endfor %}

*没有更多文章了*