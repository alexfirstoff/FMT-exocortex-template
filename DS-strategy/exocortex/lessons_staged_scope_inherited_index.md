---
name: lessons_staged_scope_inherited_index
description: git add поимённо НЕ очищает индекс — чужой pre-staged файл остаётся; всегда сверять diff --cached
metadata: 
  node_type: memory
  type: lesson
  horizon: warm
  domains: 
    - git
    - staging
    - agent-discipline
  status: active
  valid_from: 2026-06-29
  owner: user
  schema_version: 1
  originSessionId: 14de4423-64da-42bc-b72c-62d6b468de20
---

Поимённый `git add <файлы>` **добавляет** к тому, что уже стоит в индексе, а не заменяет staged-набор. Если в репо чужой файл был застейджен до сессии (например `D DayPlan` — удаление, оставшееся в индексе от другого агента), он попадёт в коммит даже при аккуратном поимённом стейджинге своих файлов.

**Why:** 29 июня при регистрации WP-2 застейджил поимённо два своих файла, но `git diff --cached --name-only` показал три — унаследованный `D DayPlan` из индекса. Чуть не закоммитил чужое удаление.

**How to apply:** после `git add <файлы>` ВСЕГДА `git diff --cached --name-only` и сверить со списком своих правок. Лишнее → `git restore --staged <file>` до коммита. Это и есть смысл правила «проверяй staged scope перед каждым коммитом» (CLAUDE.md Git Staging) — оно ловит не только `git add -A`, но и унаследованный индекс. Связано с правилом «NEVER git add -u/./-A».
