# Справочник команд AZS Snow

<p align="center"><img src="https://img.shields.io/badge/справочник-команд-38bdf8?style=for-the-badge" alt="Справочник команд" /> <img src="https://img.shields.io/badge/команда-в_чате-2563eb?style=for-the-badge" alt="Команды игрового чата" /></p>

Все команды вводятся в игровом чате. Основной формат — /snow команда значение. Команда /snow без аргументов показывает текущие настройки.

> Если параметр выходит за допустимый диапазон, аддон ограничивает его ближайшим допустимым значением.

## Снегопад

| Команда | Действие |
|---|---|
| /snow on | Включить снегопад. |
| /snow off | Выключить снегопад. |
| /snow toggle | Переключить текущее состояние снегопада. |
| /snow density N | Задать плотность от 0 до 5000 снежинок. |
| /snow 1k, /snow 2k, /snow 4k | Быстро выбрать профиль плотности. Также поддерживается формат Nk; итоговое значение не превышает 5000. |
| /snow wind N | Задать ветер от −150 до 150. Отрицательное значение направляет снег влево. |

## Сугробы и расположение слоя

| Команда | Действие |
|---|---|
| /snow drifts on или off | Показать или скрыть сугробы. |
| /snow grow on или off | Включить или отключить изменение сугробов во время забега. Эффект зависит от API игры. |
| /snow height N | Задать высоту сугробов от 4 до 80. |
| /snow top on или off | Вывести снег поверх HUD либо под игровым интерфейсом. |

## Глубина и производительность

| Команда | Действие |
|---|---|
| /snow depth on или off | Включить или отключить эффекты движения и поворота. |
| /snow turn N | Настроить силу поворота от −3 до 3. Отрицательное значение меняет направление, 0 отключает этот эффект. |
| /snow rate full | Обновлять все снежинки каждый кадр для более плавного движения. |
| /snow rate half | Если активных снежинок больше 300, обновлять половину за кадр. Это снижает нагрузку, но делает движение менее плавным. |

## Диагностика и сброс

| Команда | Действие |
|---|---|
| /snow debug | Показать диагностические данные о снежинках, слое и доступных координатах. |
| /snow reset | Вернуть стандартные настройки. |

## Значения по умолчанию

| Параметр | Начальное значение |
|---|---|
| Снегопад | Включён |
| Плотность | 80 снежинок |
| Ветер | 10 |
| Сугробы и их рост | Включены |
| Высота сугробов | 24 |
| Слой относительно HUD | Под интерфейсом |
| Эффект глубины | Включён |
| Сила поворота | 1 |
| Режим обновления | full |

## Примеры

    /snow density 250
    /snow wind -40
    /snow height 32
    /snow grow off
    /snow depth off
    /snow turn -1
    /snow rate half
    /snow reset

Чтобы увидеть текущие значения, введите /snow. Для возврата к исходной конфигурации используйте /snow reset.

---

# AZS Snow command reference

Enter commands in the in-game chat. The general format is /snow command value. Running /snow without arguments displays the current settings.

## Snowfall

| Command | Action |
|---|---|
| /snow on, /snow off, /snow toggle | Enable, disable, or toggle snowfall. |
| /snow density N | Set density from 0 to 5000 flakes. |
| /snow 1k, /snow 2k, /snow 4k | Choose a density preset. The Nk format is also supported and is capped at 5000. |
| /snow wind N | Set wind from −150 to 150; negative values move snow left. |

## Drifts and layering

| Command | Action |
|---|---|
| /snow drifts on or off | Show or hide snowdrifts. |
| /snow grow on or off | Toggle run-based drift growth when the game API is available. |
| /snow height N | Set drift height from 4 to 80. |
| /snow top on or off | Draw snow above the HUD or below the interface. |

## Depth and performance

| Command | Action |
|---|---|
| /snow depth on or off | Toggle movement and turning effects. |
| /snow turn N | Set turning response from −3 to 3; 0 disables it. |
| /snow rate full | Update all flakes every frame for smoother motion. |
| /snow rate half | Above 300 active flakes, update half per frame to reduce workload. |

## Diagnostics and defaults

Use /snow debug to inspect the effect state. Use /snow reset to restore defaults. Default density is 80, wind is 10, drift height is 24, and the snowfall layer appears below the HUD.
