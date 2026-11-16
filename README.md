# AZS Snow — снег и сугробы для Azeroth Survivors

![Lua](https://img.shields.io/badge/language-Lua-000080?style=flat-square) ![Interface](https://img.shields.io/badge/interface-11200-blue?style=flat-square) ![Azeroth Survivors](https://img.shields.io/badge/game-Azeroth%20Survivors-6b4f2a?style=flat-square)

**AZS Snow превращает игровой экран Azeroth Survivors в зимнюю сцену.** Аддон добавляет настраиваемый снегопад и сугробы, ветер и эффекты глубины. Когда клиент предоставляет координаты игрока, слой реагирует на движение и повороты.

[Установка](#установка) · [Быстрый старт](#быстрый-старт) · [Настройки](#настройки-по-умолчанию) · [Устройство](#как-устроен-аддон) · [Команды](COMMANDS.md) · [English](#english)

## Обзор

AZS Snow — Lua-аддон, манифест которого объявляет интерфейс 11200. Он создаёт прозрачный неинтерактивный слой поверх окна игры и не меняет игровой мир или боевую логику.

| Параметр | Значение |
|---|---|
| Игра | Azeroth Survivors |
| Язык и интерфейс | Lua · 11200 |
| Манифест и код | AZSSnow.toc · AZSSnow.lua |
| Сохранённые настройки | AZSSnowDB |
| Справочник команд | [COMMANDS.md](COMMANDS.md) |

## Возможности

- Настраиваемая плотность от 0 до 5 000 снежинок и горизонтальный ветер.
- 64 сегмента сугробов с настройкой высоты и переключателем роста.
- Частицы с разными размером, скоростью и прозрачностью создают эффект глубины.
- Смещение снега при движении и поворотах, если API координат игрока доступен.
- Выбор положения слоя: над интерфейсом или под HUD.
- Режим half сокращает обновления при количестве более 300 снежинок.
- Параметры сохраняются в AZSSnowDB; команда debug показывает состояние слоя.

## Установка

1. Скачайте ZIP репозитория и распакуйте его.
2. Переименуйте папку azeroth-survivors-snow-main в AZSSnow.
3. Скопируйте AZSSnow в каталог AddOns игры.
4. Включите AZS Snow в меню аддонов, если клиент показывает такой список.
5. Запустите игру и введите /snow.

В репозитории лежат два файла аддона — AZSSnow.toc и AZSSnow.lua. Остальные файлы описывают проект и его команды; манифест загружает Lua-файл.

## Быстрый старт

```text
/snow                 # показать настройки
/snow density 300     # задать плотность
/snow wind -40        # ветер влево
/snow drifts on       # включить сугробы
/snow top off         # рисовать под интерфейсом
/snow reset           # вернуть значения по умолчанию
```

Полный список команд, параметров и примеров: [COMMANDS.md](COMMANDS.md).

## Настройки по умолчанию

| Настройка | Значение | Назначение |
|---|---:|---|
| Снегопад | Включён | Можно выключить или переключить |
| Плотность | 80 | Диапазон 0–5 000 |
| Ветер | 10 | От −150 до 150; минус направлен влево |
| Сугробы | Включены | Нижняя кромка экрана |
| Рост сугробов | Включён | Требует API забега для динамического роста |
| Высота | 24 | Диапазон 4–80 |
| Поверх HUD | Выключено | По умолчанию слой под интерфейсом |
| Глубина | Включена | Эффекты движения и поворота |
| Сила поворота | 1 | Диапазон −3…3 |
| Обновление | full | half применяется при плотности выше 300 |

## Команды

| Примеры | Что меняют |
|---|---|
| /snow on, /snow off, /snow toggle | Управление снегопадом |
| /snow density N, /snow 1k, /snow 2k, /snow 4k | Плотность и профили |
| /snow wind N, /snow height N | Ветер и высоту сугробов |
| /snow drifts on/off, /snow grow on/off | Сугробы и их рост |
| /snow top on/off, /snow depth on/off | Слой относительно HUD и глубину |
| /snow turn N, /snow rate full/half | Поворот и режим обновления |
| /snow debug, /snow reset | Диагностика и сброс |

Синтаксис и допустимые значения подробно описаны в [справочнике команд](COMMANDS.md).

## Как устроен аддон

1. При загрузке и входе в мир настройки AZSSnowDB объединяются со значениями по умолчанию.
2. Прозрачный экранный слой содержит текстуры снежинок и сугробов и не перехватывает мышь.
3. Глубина частицы задаёт её размер, скорость, яркость и реакцию на ветер.
4. Сугробы формируются из 64 столбцов с плавным рельефом.
5. Координаты игрока опрашиваются примерно раз в 0,1 секунды и сглаживаются для эффекта параллакса.
6. При изменении размера окна поле частиц и сугробы подстраиваются под новый экран.

Рост сугробов использует только AZS_GetRunTime и AZS_GetRunLength, если игра их предоставляет. Движение читается через GetPlayerMapPosition("player"). Если эти функции недоступны, аддон сохраняет основную визуальную часть, но соответствующий эффект не работает.

## Совместимость и производительность

Манифест указывает Interface: 11200; фактическая совместимость зависит от версии клиента и доступности API. При высокой плотности попробуйте уменьшить число частиц или включить /snow rate half. Для проверки используйте /snow debug, для возврата стандартных параметров — /snow reset.

## Структура репозитория

```text
azeroth-survivors-snow/
├── AZSSnow.lua     # снег, сугробы, события и команды
├── AZSSnow.toc     # метаданные аддона
├── COMMANDS.md     # справочник команд
├── README.md
├── .gitattributes
└── .gitignore
```

## Лицензия

Лицензия не указана. Репозиторий не предоставляет отдельного разрешения на повторное использование или распространение кода.

---

# English

**AZS Snow adds configurable snowfall and snowdrifts to Azeroth Survivors.** This Lua screen overlay includes adjustable density, wind, drift height, depth effects, and HUD layering. It does not change the game world or combat logic.

## Features

- 0–5,000 snowflakes, configurable wind, and drift height.
- Sixty-four snowdrift columns along the bottom of the screen.
- Depth-based particle size, speed, brightness, and wind response.
- Movement and turning effects when player coordinates are available.
- Saved settings in AZSSnowDB, performance modes, and /snow debug.

## Install

Download and extract the repository ZIP, rename the folder azeroth-survivors-snow-main to AZSSnow, then place it in the game's AddOns directory. Enable AZS Snow if the client provides an add-on menu. The manifest declares interface 11200.

## Quick start

```text
/snow
/snow density 300
/snow wind -40
/snow drifts on
/snow top off
```

See [COMMANDS.md](COMMANDS.md) for the full command reference.

## Implementation and compatibility

The add-on draws a non-interactive overlay with depth-varied particles and 64 drift columns. It polls player coordinates for smoothed motion effects and rebuilds the field when the screen size changes. Optional run-progress functions are read-only. When an API is unavailable, the related effect is disabled while snowfall remains available.

## License

No license is declared.
