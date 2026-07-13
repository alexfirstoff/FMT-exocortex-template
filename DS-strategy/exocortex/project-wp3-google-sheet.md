---
name: project-wp3-google-sheet
description: Учёт сайтов WP-3 = Google-таблица (источник правды); как читать; Trello убран
metadata: 
  node_type: memory
  type: project
  originSessionId: 800d12c2-09b4-437a-9850-13225dcee97e
---

WP-3 «Запуск проб-портфеля»: учёт 19 сайтов ведётся в **Google-таблице** — единственный источник правды, ведёт пилот, агент только читает.

**Ссылка:** https://docs.google.com/spreadsheets/d/1wpk4fEw_6ZG-obgV8oX98DsKuYZ0e1y0ATZbsEglhno/edit

**Как читать (коннектор Google Drive НЕ нужен, файл открыт по ссылке):**
```bash
curl -sL "https://docs.google.com/spreadsheets/d/1wpk4fEw_6ZG-obgV8oX98DsKuYZ0e1y0ATZbsEglhno/export?format=csv"
```
Коннектор `Google Drive` MCP протух (token expired) и я не могу его переавторизовать сам — но чтение через CSV-экспорт работает. Запись в таблицу агент не делает.

**Структура:** 19 сайтов (канон), столбцы-работы: контент · домен · семантика · доработка · «готов к запуску» (=«+» когда контент+домен+доработка закрыты). Работать блоками по функции.

**Trello убран** (был короткий эксперимент 1 июля): секреты удалены из `~/.zshrc`, файл интеграции удалён. Токен `ATTA...` пилот вставлял в чат — рекомендована отзыв.

Навигация по таблице (структура, модель работы) → `mydevelop/seoexpert/projects/WP-3/трекер.md`. Контекст РП → `DS-strategy/inbox/WP-3.md`. Файлы seoexpert/WP-3 вне git.
