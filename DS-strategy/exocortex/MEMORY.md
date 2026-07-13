# Оперативная память

> **Инструкции:** `{{WORKSPACE_DIR}}/CLAUDE.md` | **Настройте под свою экосистему**

## БЛОКИРУЮЩИЕ (проверяй ВСЕГДА)

1. **WP Gate:** Задание → проверь РП в таблице ниже → нет = СТОП (CLAUDE.md § 2)
2. **Close:** push ≠ закрытие → capture-to-pack + подтверждение + backup (CLAUDE.md § 2)
3. **ArchGate ≥8:** Предлагать ТОЛЬКО решения с оценкой ≥8 по ArchGate (ЭМОГСС). Слабые решения (≤7) — НЕ предлагать.

## ВАЖНЫЕ (проверяй на рубежах)

3. **Capture:** На рубеже → «Capture: X → Y» (CLAUDE.md § 2)
4. **Отчёты:** ВСЕ репо в {{WORKSPACE_DIR}}/
5. **Процессы:** Нельзя реализовывать без PROCESSES.md (CLAUDE.md § 3)

---

## РП текущей недели (W27: 29 июня – 5 июля)

> Порядок: in_progress → pending → done. Приоритеты месяца: `current/monthly-priorities.md` (discovery 29 июня).
> ТОС июля: отсутствие живой обратной связи → правило недели «всё, что не ведёт к запуску пробы, не берём».

| # | РП | Бюджет | Статус | Дедлайн |
|---|-----|--------|--------|---------|
| ~~WP-1~~ | ~~Конвейер запуска сайтов — карта и точки гипотез~~ | — | ✅ закрыт 29 июня (§4f портфель ставок) | — |
| **WP-3** | **Запуск проб-портфеля** (план по 5 схемам §4f) | 3-4h | 🔄 открыт 30 июня (Ф1 план+ресурсы) | до отпуска |
| WP-2 | PACK-SEO — паспорт предметной области | — | pending — бэклог, активация on-demand (вне фокуса июля) | — |

---

## Навигация (Слой 3)

| Тема | Файл |
|------|------|
| Различения (жёсткие + авторские warm) | `memory/hard-distinctions.md`, `memory/distinctions-warm.md` |
| Роли (детали R27–R31) | `memory/roles-detail.md` |
| FPF (навигация, принципы) | `memory/fpf-reference.md` |
| Правила по типам репо | `memory/repo-type-rules.md` |
| Чеклисты | `memory/checklists.md` |
| **SOTA-практики** | `memory/sota-reference.md` |
| Обслуживание CLAUDE.md | `memory/claude-md-maintenance.md` |
| WP-3: учёт сайтов в Google-таблице (как читать) | `memory/project-wp3-google-sheet.md` |
| Урок WP Gate | `memory/wp-gate-lesson.md` |
| Урок: git add не очищает индекс — сверять staged scope | `memory/lessons_staged_scope_inherited_index.md` |
| Урок: декомпозиция по станциям-с-выходом, не по фазам; оценка после плейбука | `memory/lessons_decompose_by_station_not_phase.md` |
| Не подавать известное за «прорыв» | `memory/feedback_no_false_breakthroughs.md` |
| **Без угодливости, держать фрейм/метод (HOT)** | `memory/feedback_no_sycophancy_hold_frame.md` |
| **Системно-специфичное** | **→ repo/CLAUDE.md** |
| Стратег | `DS-strategist/README.md` |
