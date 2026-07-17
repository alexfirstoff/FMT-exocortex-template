# Инструкции для всех репозиториев

> Kimi → `AGENTS.md`, Hermes → Aisystant MCP `get_instructions`; доставка ядра в шаблон — `FMT-exocortex-template/scripts/template-sync.sh`. Slim-ядро: триггеры + правила hot; детали → `memory/`, `.claude/rules-lazy/`, `.claude/skills/`.

## 1. Архитектура репозиториев

**Base** (ZP, FPF, SPF, FMT-*) = принципы + форматы, первоисточник платформы · **Pack** = паспорт предметной области, первоисточник пользователя · **DS** (instrument/governance/surface) = код, планы, курсы — производное от Pack.

**Fallback Chain (где SoT):** DS → Pack → Base (SPF → FPF → ZP). **Pack = source-of-truth для доменного знания; DS меняется вслед за Pack.**
**Лестница принципов:** ZPF → FPF → SPF → TPF → LPF — полная таблица уровней → `memory/repo-type-rules.md`; словарь ailev ↔ IWE → `memory/fpf-reference.md`.

**Pack Creation Gate:** хочешь создать Pack → `/pack-new` (структура `SPF/pack-template/`, процесс `SPF/process/01-11`, FPF/SPF клонируются автоматически). Имя = существительное-домен (не тема, не инструмент).

## 2. ОРЗ-фрактал (Открытие → Работа → Закрытие)

> Пропуск Открытия = незапланированная работа. Пропуск Закрытия = незафиксированный результат.
> **Сессия:** `protocol-open.md § Сессия` → `protocol-work.md` → `/run-protocol close` · **День:** `/day-open` («открывай») → `/run-protocol day-close` · **Неделя:** `/run-protocol week-close` · **Месяц:** `/month-close` (первый Пн, до Strategy Session).

### Блокирующие правила

> **SoT (WP-272 Ф1):** `PACK-agent-rules/rules/AR.NNN.md` (реестр `.claude/rules-registry.yaml`); полные тексты выжимки → `.claude/rules-lazy/blocking-rules-full.md`. **Приоритет = нумерация:** структурное (1-5) перевешивает поведенческое (6-10).

1. **WP Gate:** ЛЮБОЕ задание → `memory/protocol-open.md` ДО начала работы. Новый РП → Ритуал согласования → явное «да»/«делаем»/«открывай»; без этого не регистрировать.
2. **Push:** «заливай»/«запуши»/«закрывай» → commit + push без вопросов, ДО отчёта Закрытия. Любой Close: `git status --short` по всем репо → незафиксированное commit + push ДО следующего шага.
3. **Close:** Триггер Закрытия → протокол Закрытия → выполнить.
4. **Pull-on-Touch:** `git pull --rebase` при первом обращении к репо за сессию (все `{{HOME_DIR}}/IWE/*`). Dirty → stash; конфликт → `memory/reference/agent-core.md`.
5. **Чеклист-верификация:** Quick/Day Close — sub-agent Haiku R23 сверяет с чеклистом. Исключения: ≤15 мин или без изменений файлов.
6. **Hooks/Scripts Bypass Gate (S-33):** без явного разрешения не менять `.claude/hooks|scripts/`, `.iwe-runtime/`, `FMT-exocortex-template/`, не обходить хуки; блок хука → bug-файл + пилоту + ждать. → `.claude/rules-lazy/hooks-bypass-gate.md`.
7. **Автономность:** не спрашивать подтверждения — выполни → отчитайся. Исключения: необратимо-разрушительное; WP Gate Ритуал; choice-question. → `memory/feedback_behaviour.md` П.1.
8. **Напоминания (S-44):** «напомни через X» → `send_telegram_message(schedule_at)` + ScheduleWakeup резерв; резерв сработал → сначала Telegram, потом чат.
9. **Финиш > отлог (S-46):** доп. задача → дефолт «делаю сейчас»; «сейчас или потом?» = анти-паттерн. Исключения и приоритет WP Gate → `memory/feedback_finish_now_no_defer.md`.

### Протокол Работы (полный → `memory/protocol-work.md`)

**Capture-to-Pack** — на каждом рубеже: есть ли знание для записи? Анонс: *«Capture: [что] → [куда]»*. Маршрутизация: правило → CLAUDE.md, доменное → Pack, реализационное → DS docs/, урок → memory/; при новом артефакте Routing Gate (DP.KR.001 §5) первым.
**Self-correction:** расхождение внутри scope текущего хода (файлы из agenda, `git diff HEAD`) → немедленно предложить фикс; за пределами scope — Drift Reporting (SYNC-CORE), не фиксить.

### Pre-action Gates

> Полные формулировки → `.claude/rules-lazy/blocking-rules-full.md`.

- Начало работы → какие сервисы (MAP.002) затронуты?
- Нетривиальное действие/РП → **State-Transition Gate (WP-457):** `{тип состояния, из→в}`, только `gate_ready: true` → Agent Core ниже.
- Пользовательский сценарий → **SC Gate:** какое обещание (08-service-clauses/) затронуто?
- Создание/размещение артефакта → **Routing Gate:** карта DP.KR.001 §5; «по аналогии с соседним» запрещено.
- Первое содержательное действие в репо → **Repo-Touch Gate:** прочитать `<repo>/CLAUDE.md`; блок «обязательно загружай» → загрузить ДО ответа.
- Архитектурное решение → **АрхГейт** `/archgate`.
- РП затрагивает PII → **Security Gate (B7.3):** §Б чеклист ArchGate ДО реализации; логирование PII = блокер.
- РП ≥3h → **Priority Gate:** к какому R{N} ведёт?
- Новый инструмент/агент/система → **IntegrationGate (БЛОКИРУЮЩЕЕ):** только (1) обещание → (2) сценарии → (3) роль → (4) реализация → `.claude/rules-lazy/integration-gate.md`.
- Замена legacy-компонента → **LegacyPortGate (БЛОКИРУЮЩЕЕ):** сначала 15-мин субагент «как это работает сейчас?» → `memory/feedback_behaviour.md` П.10.

## 3. Описания методов (PROCESSES.md)

≤15 мин — не нужен. Внутри системы — `<repo>/PROCESSES.md`. Новая система — сценарий + процессы + данные.

## 4. Memory (Слой 3)

Файлы/репо → `memory/navigation.md` · Pack-репо → `memory/repo-type-rules.md` · терминология → `memory/hard-distinctions.md` · FPF/SOTA/Роли → `memory/fpf-reference.md`, `memory/sota-reference.md`, `memory/roles.md` · документ/чеклист → `memory/checklists.md`.

Политика: ≤11 файлов; построчно проверяется только distinctions.md (≤150), остальное — суммарным M1/M2-бюджетом (WP-7 NR1.2); lazy-reference без лимита. Горизонты/frontmatter → `memory/memory-lifecycle-spec.md`; temporal metadata → `protocol-work.md §2`.
Рабочая директория: `{{HOME_DIR}}/IWE/`; `memory/` = симлинк на auto-memory.

## 5. АрхГейт — ОБЯЗАТЕЛЬНАЯ оценка

> **БЛОКИРУЮЩЕЕ.** Архитектурное решение → `/archgate`: принципы DP.ARCH.001 §7 → профиль ЭМОГССБ (✅/⚠️/❌) → conjunctive screening; чеклист современности (SOTA.002/001/011 + CGUS/PUA) — внутри `.claude/skills/archgate/SKILL.md`. Без агрегатного балла — `feedback_decision_gates.md`.

## 6. Форматирование → `.claude/rules/formatting.md` · Различения → `.claude/rules/distinctions.md`

## Контекстный бюджет IWE (WP-445)

Hot-каркас ≤20K токенов (M1), строгая цель ≤12K (M2). Изменил файл из `hot-files.list` (оба CLAUDE.md, rules/*.md) → перед коммитом `DS-strategy/scripts/verify-context-budget.sh`.

## 7. Обновление этого файла

> **3 слоя:** L1 (§1-§7) = платформа (`update.sh`). L2 (§8) = staging. L3 (§9) = авторское.
> Протоколы → `memory/protocol-*.md` · различения → `.claude/rules/distinctions.md` · форматирование → `.claude/rules/formatting.md` · стабильные знания → `memory/*.md` · свои правила → §8/§9.

<!-- PLATFORM-END -->

---

## Agent Core (SYNC-CORE → AGENTS.md)

> **WP-394 Ф4.2.** Единое ядро для всех агентов (Claude, Kimi, Hermes). `AGENTS.md` генерируется отсюда скриптом `scripts/sync-agent-instructions.sh` — **не редактировать `AGENTS.md` вручную**. Элаборация → `memory/reference/agent-core.md`.

<!-- SYNC-CORE-START -->

## WP Gate — CRITICAL

**ЛЮБОЕ задание → протокол Открытия → ДО начала работы.** При создании нового РП: объявить роль, работу, РП, класс верификации, метод, оценку, модель. Дождаться согласования пилота.

## State-Transition Gate — CRITICAL

**Перед любым нетривиальным действием или РП назвать целевой переход состояния пользователя** `{тип состояния, из→в}` (WP-457). Типы — только `DS-strategy/docs/state-axes-registry.yaml`, допустимы только `gate_ready: true`; ссылка на declared FSM-owner обязательна, свободный текст не принимается. Нет ссылки или тип не `gate_ready` → действие = inventory → СТОП/отложить. Модель осей → `archive/wp-contexts/WP-457/CONCEPT-user-states.md §5`; cross-axis → `agent-core.md`.

## Git Staging — CRITICAL

**NEVER `git add -u`, `git add .`, `git add -A`** — подхватывают изменения ДРУГИХ агентов (Kimi/Hermes работают параллельно) → неверная атрибуция. Стейджить только конкретные файлы; перед коммитом `git diff --cached --name-only`, лишнее — `git restore --staged`. Примеры → `memory/reference/agent-core.md`.

## Artifact Naming

**Do not invent artifact names.** Names for sections, documents, RPs, and deliverables must come from the plan/task you received. If the task is silent on a name — report "need clarification on name" instead of making one up.

## Drift Reporting

Discrepancy found (file ≠ plan, stale content): **report to pilot, do not silently fix.** Format: "Found drift: [what] in [file]. Should I fix it?" Fix only if explicitly instructed.

## Working Directory

`{{HOME_DIR}}/IWE/`

## Status Reporting — Agent Status Registry (РП-395)

**Primary (обязательно):** в начале задачи `agent_status_update(agent=<claude-code|kimi|hermes>, status=working, task=<кратко>, files=[...])`; по завершении — `status=idle`. Статусы: `idle|working|peer-session|blocked`; пилот видит всех через `agent_status_list`. Командный режим (`repo=`) и fail-safe скрипт → `memory/reference/agent-core.md`.

## Long Operation Protocol — 180 s Silence Threshold

**Не молчи больше 180 секунд.** Операция >180с → ДО запуска сообщить: что запускается, длительность, шаг X из Y, id фоновой задачи. >180с тишины → микро-отчёт «Всё ещё работаю. Текущий шаг: [X из Y]. Следующий: [Z].» Касается всего, где пилот видит пустое «Thinking» (bash, subagent, фоновые задачи, Close-протоколы).

## WP-REGISTRY Naming — CRITICAL

**Колонка «Название» в WP-REGISTRY содержит ТОЛЬКО имя артефакта ≤80 символов** — без дат, ссылок на сессии, метрик, SHA и прочих служебных данных.

**Куда писать остальное:** итог закрытия → `## Закрытие` в `archive/wp-contexts/`; фазы/прогресс → frontmatter `inbox/WP-NNN/WP-NNN.md` (всегда папка — WP-434), при смене статуса фаз обновлять frontmatter, НЕ имя реестра. Полный текст и примеры ✅/❌ → `memory/reference/agent-core.md`.

## WP Context Scope — Umbrella РП

Umbrella-РП с `agent_scope: open-only` (WP-5, WP-7) — читать **только** фазы `pending`/`in_progress`/`blocked`; архивные — не читать без явного запроса пользователя.

## Calendar Events — CRITICAL

**All agent-created reminders and calendar events must be scheduled BEFORE 09:00 AM** (позже — только с явного одобрения пилота). Создано после 09:00 по ошибке → удалить + пересоздать до 09:00 + сообщить пилоту (шаги → `memory/reference/agent-core.md`).

## Language

Respond in Russian unless the user writes in English.

## Response Style — Pilot-Facing

Правила понятного ответа пилоту (полный текст — `memory/feedback_response_clarity_for_pilot.md`) — в чате, синтезе отчётов и пост-отчётах после действий.

**Channel detector:** технический стиль — стенограммы peer-сессий, commit, PR; «на пальцах» — чат с пилотом (если тот сам не пишет `grep`/`git`/пути/SHA) и §1-§4 синтеза report.md.

**Eleven rules (A1-A11), short:** A1 путь файла не подлежащее (только в скобках после русского глагола); A2 английский термин только после русского описания в скобках; A3 первое упоминание колонки/функции — расшифровка одним словом; A4 pre-flight: примет ли пилот решение по этой фразе; A5 ЧТО до КАК; A6 одна стрелка-следствие на предложение; A7 «сделал → эффект», `<details>` — только при наличии нужных пилоту деталей или по его явному запросу; A7.1 журнал (SHA, коммиты, дефекты) — только в файл отчёта, не в чат; A8 журнал процесса по умолчанию не писать; A9 channel detector; A10 английские маркеры статуса (exit/PASS/SHA) → русские слова; A11 активный залог на ошибках и находках.

## Code Style — Engineering (DP.SC.172)

При написании/правке кода — инженерный стиль craft-уровня (L0 — `engineering-code-style-base.md`, PACK-digital-platform). База = запахи с «было/стало»; вкус = отсутствие запахов. Детектор: «есть ли у кода будущий читатель?» Да → обязательны.

**P-правила, short:** P0 перед коммитом — форматтер+линтер репо (механику закрывает инструмент); P1 тест без проверки наблюдаемого результата запрещён (`assert True` — запах); P2 третье повторение → функция, не `locals()[str]`; P3 мёртвую ветку/enum удалять, не «для совместимости»; P4 `except: pass` без логирования запрещён; P5 длинную функцию со смешанными обязанностями / булевы флаги-режимы — разбить. Граница: жёсткие запреты (`git add -A`, секреты) — в PACK-agent-rules (AR.*), не здесь. (Доставка/детекторы по агенту → `memory/reference/agent-core.md`.)

<!-- SYNC-CORE-END -->

---

## 8. Staging (обкатка → шаблон)

> Правила на обкатке (STAGING.md) → работают → переносятся в шаблон (L1). Новое поведение в §9 → ОДНОВРЕМЕННО строка в STAGING.md (`status: testing`). Промоция на Week Close (`validated`→`promoted`, `rejected` остаётся в §9 — не удалять) → скилл `/author-mode` и `.claude/rules-lazy/blocking-rules-full.md`.

**Активная запись:** S-45 Agent Inbox (WP-324) — `inbox/agent/` + `iwe-agent-dispatcher.py`, промотировано в FMT `extensions/agent-inbox/`. Status: testing.

---
## 9. Авторское (только мой IWE)

### Блокирующие (авторские)

- **Pull-before-Commit:** перенесён в §2 п.5 (платформенное правило для ВСЕХ репо).
- **Без Obsidian (DS-strategy):** Просмотр через VS Code.
- **S-33 (Hooks/Scripts Bypass Gate):** перенесён в §2 п.6 (платформенное правило). Авторское дополнение: путь `FMT-exocortex-template/` включён в §2 п.6.
- **Комментарии кода — только на английском (решение Андрея, ИТ-встреча 14 июня 2026).** Все inline-комментарии, docstring'и и README внутри кода писать на EN. Мотив: AI-инструменты (Cursor/Claude) лучше работают с EN-комментариями; код публикуется в мировой орг — кириллица в комментариях = барьер для не-русскоязычных читателей. Область применения: весь код в `{{WORKSPACE_DIR}}/**`, включая DS и Pack-скрипты. Исключение: user-facing строки в интерфейсах (UX-тексты, сообщения пользователю) — по языку интерфейса.

### Различения (авторские)

> Хранятся в `.claude/rules/distinctions.md` в зоне AUTHOR-ONLY — не затираются при `update.sh`.


### Именование

- `DS-strategy` (не `DS-strategy`) — личный governance-хаб
- `{{HOME_DIR}}/IWE/` — рабочая директория

### Read-only репо


### Extensions Gate (БЛОКИРУЮЩЕЕ)

**Для пользователей:** кастомизация протоколов/скиллов → ТОЛЬКО в `extensions/*.md`.
Прямое редактирование `.claude/skills/` или `memory/protocol-*.md` = ошибка.
**Архитектурное обоснование:** платформенные файлы (L1) и пользовательские расширения (L3) -- разные слои. Смешение слоёв = хрупкость при обновлении. Разделение: платформенное → `FMT-exocortex-template` → `update.sh`. Пользовательское → `extensions/` + `params.yaml`.

**Для автора шаблона (`params.yaml → author_mode: true`):** прямое редактирование L1 файлов РАЗРЕШЕНО.
- **Flow (единый для всего L1):** авторский IWE (source-of-truth) → доставка в FMT (с отрезанием личного) → GitHub → `update.sh` → пользователи. Авторский IWE = SoT для ВСЕГО: CLAUDE.md, скриптов, хуков, скиллов.
- **CLAUDE.md:** авторский IWE → `bash $IWE_TEMPLATE/scripts/template-sync.sh` → автоматически в FMT (плейсхолдеры + отрезание §9). Режимы: без флагов = sync, `--dry-run` = diff, `--check` = drift (exit 1).
- **Промоция артефактов в шаблон** — единая команда по типу:
  - Скрипт: `bash $IWE_SCRIPTS/script-promote.sh <личный-скрипт>.sh [--dry-run]` → FMT/scripts/
  - Хук: `bash $IWE_SCRIPTS/hook-promote.sh <личный-хук>.sh [--dry-run]` → FMT/.claude/hooks/
  - Скилл: `bash $IWE_SCRIPTS/skill-promote.sh <папка-скилла>/ [--dry-run]` → FMT/.claude/skills/
  - CLAUDE.md: `bash $IWE_SCRIPTS/template-sync.sh` (автозамена §9 + плейсхолдеры)
- **Все promote-скрипты:** применяют одинаковые подстановки (личные пути и repo-имя → env vars) → прогоняют `validate-fmt-scripts.sh` → копируют. Флаг `--dry-run` показывает результат без копирования.
- **Валидатор** запускается автоматически после каждого `template-sync.sh`. Вручную: `bash $IWE_SCRIPTS/validate-fmt-scripts.sh $IWE_SCRIPTS/`.


### README.md (FMT-exocortex-template)

> Изменение структуры — по согласованию с владельцем.

### WP Entry Filter (S-47, БЛОКИРУЮЩЕЕ, авторское)

> **Принято Strategy Session 1 июня 2026 (С.6 proposal-2026-06 v4).** Метод от R31 Менеджера оргразвития: оргхаос потока задач = тип системы «организация» → дисциплина «системный менеджмент» → правило входа.

Новый РП открывается **ТОЛЬКО при выполнении одного из двух условий**:

1. **Связь со стратегической целью R1-R6** месяца (см. Strategy.md §«Результаты месяца R1-R6»). Цель должна быть явной — не «полезно для платформы», а «двигает R{N} к Q результату».
2. **Явный заказчик извне:** Ильшат (Track A), волонтёр когорты, регулятор (юрист/налоговая), Андрей (Track B), партнёр.

**Иначе** — задача попадает в `DS-strategy/inbox/backlog-with-triggers.md` (а не в WP-REGISTRY) с условием возврата:
- **Триггер «N=10 повторений»** — если идея повторяется в captures/peer-сессиях/обсуждениях ≥10 раз → пересмотр на следующем Month Close.
- **Auto-перевод активного РП в backlog: 30 дней без коммита** в context-файл / связанные репо → automatic transition (детектор R31 Ф2.7 уже работает на сигнал «stuck >14 дней» → 30-day trigger автоматизировать в следующей сессии).

**Цель:** удержать WIP в норме 8-15 (вместо текущих 30+). 91 активный РП на 31 мая = inflated WIP в 6 раз, мёртвый капитал → throughput падает.

**Применение Claude:** при предложении нового РП в Strategy Session или сессии — **сначала** проверять filter:
- (Q1) К какой R{N} цели месяца этот РП ведёт? Конкретно одной фразой.
- (Q2) Если нет цели — есть ли явный внешний заказчик с именем?
- Если оба ответа отрицательные → не открывать РП. Записать в `backlog-with-triggers.md` с краткой формулировкой + дата + источник идеи.

**Исключения:**
- spin-off от закрытого РП (Ф-N → отдельный РП) — допустимо без явной R{N} цели, если родитель был привязан к R{N}.
- пилот явно называет задачу как РП («открой РП», «создай WP», «это новый РП для X») — это прямое поручение, не предложение агента. S-47 не применяется.

### Именование РП

**Название РП = существительное-артефакт**, а не глагол-действие.
- ✅ «Дизайн системы стратегирования», «Архитектура MCP», «Концепция подписок»
- ❌ «Разработать систему», «Настроить MCP», «Сделать концепцию»

**Название в WP-REGISTRY.md = ≤80 символов, только русский.** Допустимо вкрапление кодовых идентификаторов и Pack-ID, если они являются собственным именем артефакта (`projection-worker`, `DP.SC.125`, `cut-over`, `IWE`). Реестр — индекс, не карточка РП.

Запрещено в названии:
- статус, даты, commit hash, фазы, метрики («closed 27 апр», «Ф1 done», «PASS», «1.5h факт vs 3h»)
- список под-задач через `+`/`;` или parenthetical-нарратив
- английские пояснения (`spawn`, `closes drift`, `runtime activation`)
- ссылки на другие РП («child WP-268», «parent zonтик», «source: feedback_*»)

Контекст РП (фазы, handoff, ArchGate, бюджеты, решения) живёт в `DS-strategy/inbox/WP-NNN-*.md` для активных и `DS-strategy/archive/wp-contexts/` для закрытых. В реестре — только имя артефакта.

Эталоны: WP-254 «Миграция учебных объектов #6 aist-bot → #11 learning», WP-258 «Plugin API L2 для IWE (регистр MCP-расширений + контракт плагина)», WP-264 «Day Open enforcement — diagnostic logging + deterministic scaffold».

**Синхронизация REGISTRY→производные:** при переименовании РП → обновить одновременно REGISTRY.md + MEMORY.md + WeekPlan + DayPlan (если активен) + WP-context file.

### Память (Memory Lifecycle) — S-35

> Spec: `memory/memory-lifecycle-spec.md` (WP-217 Ф10.1, ArchGate 2026-04-30).

**Обязательный frontmatter** для всех новых файлов `memory/*.md`:

```yaml
---
name: "..."
description: "одна строка для MEMORY.md"
type: user | feedback | project | reference | lesson | protocol
horizon: hot | warm | cold | archive
domains: [тег1, тег2]
status: active | dormant | superseded | archived
valid_from: YYYY-MM-DD
owner: user | platform
schema_version: 1
---
```

**Правила горизонта:**
- `hot` — загружается каждую сессию. Суммарный лимит: ≤150 строк по всем HOT-файлам (без frontmatter).
- `warm` — по триггеру. Default для `project`, `reference`, `lesson`, `protocol`.
- HOT-лимит превышен → предложить понизить один из HOT-файлов в WARM перед добавлением нового.

**Архивация:** предлагает агент при Week/Month Close — не выполняет автономно. HOT→WARM: 14 дней без обращения. WARM→COLD: 30 дней. COLD→archive: 90 дней.

### Security Audit Cadence (WP-212, S-36)

> **Три уровня периодичности:**
> - **Per-ArchGate (каждое архитектурное решение):** §Б чеклист в ArchGate (B7.1 ✅) + STRIDE для нового сервиса → обновить B7.2 scope-таблицу.
> - **Week Close (2 мин):** проверить `security-posture.md §3` — `open_critical_count > 0`? Если да → добавить WP-212 в следующий WeekPlan.
> - **Daily (tsekh-1, 04:45 МСК):** systemd-timer `iwe-overnight-auditor` → VR.R.002 daily-headless по B7.4 A-D (~10-15 мин, $1.5). Critical flags → Day Open «Требует внимания».
> - **Month Close (VR.R.002 Аудитор monthly-deep, ~1h):** sub-agent VR.R.002 (catalog R24, context isolation, Sonnet) → разделы A-F чеклиста B7.4 → обновить `security-posture.md` → коммит `docs(WP-212): security audit YYYY-MM`.

**Файлы:**

### WeekPlan / WeekReport split (ОПТ-5, WP-297)

**WeekPlan** = намерения недели (planning, inbox triage, НЭП, приоритеты, контент-план). **Только интенты.** Нет прошлого.
**WeekReport** = факты недели (итоги дней, что сделано, коммиты). **Только история.** Нет планов.

**Правило:** при создании WeekPlan — предыдущие «Итоги дня» и «Итоги прошлой недели» → новый `WeekReport W{N} YYYY-MM-DD.md`. WeekPlan держит только `week_report: WeekReport W{N}...` в frontmatter как ссылку.
**Мотив:** WeekPlan смешивал факты и намерения → 545 строк → непригоден как planning-документ. Split → WeekPlan ≤200 строк.

### Режим «на пальцах» (S-37)

**Явные триггеры:** «объясни», «на пальцах», «что сделали», «расскажи понятно», «простыми словами» — любая просьба объяснить итоги или суть работы.

**Детектор канала (peer-session 2026-06-01-27, добавлено):**
- **Технический режим** в чате с пилотом — если в сообщении пилота сами встречаются: `grep`, `git`, имена файлов с путями, флаги команд, SHA, английские термины из кода.
- **Режим «на пальцах»** по умолчанию для всего остального: ответы на «что произошло», «почему не работает», «объясни», или задание без технических деталей в формулировке.
- **report.md** при синтезе peer-сессии: §1-§4 (Постановка, Позиции, Альтернативы, Решение) — режим «на пальцах»; прямые цитаты из ходов внутри §2 — плотный технический стиль (доказательство, не синтез).
- **Стенограммы ходов** (NN-writer / NN-peer) — плотный технический стиль, правила режима НЕ применяются.
- **Commit messages, PR descriptions** — плотный технический стиль.

**Правила ответа в режиме «на пальцах» (полная нумерация A1-A11 — в `feedback_response_clarity_for_pilot.md`, единый источник — `communication-style-base.md`):**
- Только русский язык. Английские термины и коды — только после русского описания в скобках. Исключение — термины, которые сам пилот употребляет (бот, чек-ин, deploy, smoke, merge, push, commit, MCP, Pack). Не «WP-330», а «марафон (РП330)». Не «G3 PASS», а «финальная проверка (G3) прошла успешно». **(A2 + A2-ext)**
- Путь к файлу — никогда не подлежащее. Только в скобках после русского глагола («бот пишет ноль в счётчик (`handlers/marathon.py:65`)»). **(A1)**
- Блок `<details>` — только при наличии деталей, нужных пилоту для решения/действия, или явно им запрошенных. SHA, коммиты, дефекты, scope — только в файл отчёта (report.md, handoff.md), никогда в чат. **(A7 + A7.1)**
- При первом упоминании имени колонки/функции/переменной — расшифровка одним словом. **(A3)**
- Никаких английских маркеров успеха/неудачи как факта: «exit 0», «PASS», «SHA: abc» → «получилось», «прошло проверку», «залил правкой». **(A10)**
- Никакого пассивного залога при ошибке или находке: «было обнаружено» → «я нашёл», «я ошибся». **(A11)**
- Объяснять через аналогии из физического мира или инженерии: что делает система, зачем, что было сломано, что починили. **(A5)**
- Допустимо: цифры, проценты, сравнения «было / стало», схемы словами.
- Формат: свободный текст или маркированный список.

**Пример нарушения:** «Исправлен `activity_domain` фильтр в `load_rcs_metrics` — заменён на `SELF_DEV_EVENT_TYPES`.»
**Правильно:** «Раньше система считала рабочие дни вместе с учебными — теперь считает только те дни, человек реально занимался саморазвитием.»

**Полные правила, 12 паттернов и примеры «было / стало»:** [feedback_response_clarity_for_pilot.md](memory/feedback_response_clarity_for_pilot.md).

### Календарный конвейер (WP-357)

> Single source-of-truth для датозависимых процессов IWE. Полная спецификация → `DS-strategy/docs/calendar-pipeline.md`.

**Каталог:** `DS-strategy/exocortex/process-catalog.yaml` (10 процессов: 6 A-класс + 4 B-класс).
**Ledger (generated):** `DS-strategy/current/date-ledger.yaml` (регенерируется при каждом Day Open).
**Watchdog:** in-band (Day Open hook) + out-of-band (launchd, каждый час). Telegram-дайджест при пропусках (cooldown 12h).
**Установка:** `bash DS-strategy/scripts/install-launchd.sh` (12 plist, требует ручного запуска пилота).
**Smoke-test:** `bash DS-strategy/scripts/calendar-pipeline-smoke.sh`.

Добавление нового процесса = добавить запись в process-catalog.yaml + плист в exocortex/launchd/ + entry в install-launchd.sh PLISTS. Не редактировать date-ledger.yaml вручную (derived).

---

*Последнее обновление: 2026-05-26*
