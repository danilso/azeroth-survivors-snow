# AZS Snow — снег и сугробы для Azeroth Survivors

AZS Snow добавляет в игровой интерфейс настраиваемый снегопад и сугробы в нижней части экрана. Аддон написан на Lua; его `.toc` объявляет `Interface: 11200`.

Это визуальный экранный слой: код не меняет игровой мир или боёвку. При доступных координатах игрока снег реагирует на движение и повороты. Рост сугробов использует read-only функции `AZS_GetRunTime` и `AZS_GetRunLength`; без них сугробы остаются статичными.

## Возможности

- Плотность от 0 до 5 000 снежинок, ветер и высота сугробов.
- Переключатели снегопада, сугробов и роста во время забега.
- Снег можно рисовать поверх игрового интерфейса или под ним.
- Параллакс по глубине: снежинки различаются размером, скоростью и яркостью; движение и повороты добавляют мягкое смещение.
- Упрощённый режим обновления при плотности выше 300 снежинок.
- Сохранение параметров через `AZSSnowDB`.
- Диагностика состояния интерфейса и слежения за движением.

## Установка

1. Скачайте ZIP репозитория и распакуйте его.
2. Переименуйте извлечённую папку `azeroth-survivors-snow-main` в `AZSSnow`.
3. Поместите папку `AZSSnow` в каталог `AddOns` игры.
4. Включите **AZS Snow** в меню аддонов, если клиент показывает такой список.
5. В игре введите `/snow`, чтобы увидеть текущие настройки.

## Быстрый старт

```text
/snow
/snow density 300
/snow wind -40
/snow drifts on
/snow top off
```

Полный справочник команд и диапазоны параметров находятся в [COMMANDS.md](COMMANDS.md).

## Структура

```text
azeroth-survivors-snow/
├── AZSSnow.lua
├── AZSSnow.toc
├── COMMANDS.md
├── README.md
├── .gitattributes
└── .gitignore
```

## Лицензия

Лицензия не указана; отдельное разрешение на повторное использование или распространение не предоставляется.

---

# AZS Snow — snow and drifts for Azeroth Survivors

AZS Snow adds configurable snowfall and snowdrifts along the bottom of the screen. It is a Lua add-on whose `.toc` declares `Interface: 11200`.

The add-on is a visual overlay and does not modify the game world or combat. When player map coordinates are available, snowfall reacts to movement and turning. Drift growth reads the optional, read-only `AZS_GetRunTime` and `AZS_GetRunLength` functions; without them, drifts remain static.

## Features

- Snow density from 0 to 5,000 flakes, plus wind and drift-height controls.
- Toggles for snowfall, drifts, drift growth, depth effects, and rendering above or below the HUD.
- Parallax styling with flakes of different sizes, speeds, and brightness.
- A lighter update mode when more than 300 flakes are active.
- Saved settings via `AZSSnowDB` and a diagnostic command.

## Install

Download and extract the repository ZIP, rename the extracted `azeroth-survivors-snow-main` folder to `AZSSnow`, then place it in the game's `AddOns` directory. Enable **AZS Snow** in the add-on menu if available. Use `/snow` in chat; see [COMMANDS.md](COMMANDS.md) for the command reference.

## License

No license is declared.
