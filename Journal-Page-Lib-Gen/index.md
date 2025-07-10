---
layout: default
title: Physics Journals
---

# Mathematics Journals

**Base URL:** [https://libgen.li/series.php?id=](https://libgen.li/series.php?id=)

---
<ul>
  {% for journal in site.data.math %}
    <li>
      <a href="https://libgen.li/series.php?id={{ journal.id }}">{{ journal.title }} | {{ journal.id }}</a>
    </li>
  {% endfor %}
</ul>
