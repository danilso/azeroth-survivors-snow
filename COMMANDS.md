# Команды AZS Snow

Все команды вводятся в игровом чате с префиксом `/snow`. Команда без аргументов показывает текущие параметры.

| Команда | Что делает |
|---|---|
| `/snow on` | Включить снег |
| `/snow off` | Выключить снег |
| `/snow toggle` | Переключить снег |
| `/snow density N` | Установить плотность, от `0` до `5000` |
| `/snow 1k`, `/snow 2k`, `/snow 4k` | Быстрые профили плотности; парсер также принимает `Nk`, ограничивая значение 5000 |
| `/snow wind N` | Ветер от `-150` до `150`; отрицательное значение сносит влево |
| `/snow height N` | Высота сугроба от `4` до `80` |
| `/snow drifts on\|off` | Показать или скрыть сугробы |
| `/snow grow on\|off` | Включить или выключить рост сугробов во время забега |
| `/snow top on\|off` | Снег поверх игрового интерфейса (`on`) или под ним (`off`) |
| `/snow depth on\|off` | Включить или выключить реакцию на движение и повороты |
| `/snow turn N` | Сила эффекта поворота от `-3` до `3`; отрицательное значение меняет направление, `0` отключает поворот |
| `/snow rate full` | Обновлять все снежинки каждый кадр (плавнее) |
| `/snow rate half` | При числе активных снежинок выше 300 обновлять половину за кадр (меньше нагрузки, менее плавно) |
| `/snow debug` | Показать диагностические сведения о поле, координатах и снежинках |
| `/snow reset` | Вернуть значения по умолчанию |

## Значения по умолчанию

- Снег: включён.
- Плотность: `80` снежинок.
- Ветер: `10`.
- Сугробы и их рост: включены.
- Высота сугроба: `24`.
- Снег под интерфейсом.
- Эффект глубины включён, сила поворота `1`.
- Режим обновления: `full`.

## Примеры

```text
/snow density 250
/snow wind -40
/snow height 32
/snow grow off
/snow depth off
/snow turn -1
/snow rate half
/snow reset
```

---

# AZS Snow commands

Enter commands in the in-game chat with the `/snow` prefix. Running `/snow` without arguments prints the current settings.

- `/snow on`, `/snow off`, `/snow toggle` — control snowfall.
- `/snow density N` — set density from `0` to `5000`; presets include `/snow 1k`, `/snow 2k`, and `/snow 4k`.
- `/snow wind N` — set wind from `-150` to `150`.
- `/snow height N` — set drift height from `4` to `80`.
- `/snow drifts on|off`, `/snow grow on|off` — control drifts and their growth.
- `/snow top on|off` — draw snow above or below the HUD.
- `/snow depth on|off`, `/snow turn N` — control movement/parallax and turn response (`-3` to `3`).
- `/snow rate full|half` — choose smoothness or update half of the flakes per frame when more than 300 are active.
- `/snow debug` — print diagnostic state.
- `/snow reset` — restore defaults.

See the Russian section above for defaults and examples.
