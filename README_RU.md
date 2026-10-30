# Vera — «Тихий свет» (v1.0)

Полностью офлайн-приложение для iPhone с библиотекой библейских стихов, поиском, категориями, избранным, темами оформления и виджетами WidgetKit трёх размеров.

## Важно про установку

GitHub Actions собирает **неподписанный** `Vera.app` и сохраняет его как `Vera-unsigned-app.zip`. Это не готовый к установке IPA. Для установки через ESign нужна корректная подпись.

Для Ad Hoc установки должны одновременно выполняться условия:

1. Сертификат и provisioning profile должны быть выданы одной Apple Developer Team.
2. Provisioning profile основного приложения должен разрешать App ID `com.kriscarter.vera` и содержать UDID iPhone.
3. Для расширения виджета нужен App ID `com.kriscarter.vera.widget`, соответствующий профиль, а также разрешение App Groups.
4. В обоих профилях должна быть разрешена App Group `group.com.kriscarter.vera`.
5. ESign должен переподписать и основное приложение, и вложенное расширение `VeraWidget.appex`.

Если ESign использует профиль без UDID или не подписывает вложенное расширение подходящим профилем, установка может зависать или завершаться ошибкой. Сам по себе зелёный GitHub Actions означает только успешную компиляцию.

## Сборка

Workflow `.github/workflows/ios-build.yml` автоматически:
- запускается при push в `main` или вручную;
- генерирует Xcode-проект через XcodeGen;
- собирает приложение и виджет на macOS / Xcode;
- упаковывает `Vera.app` в ZIP;
- публикует ZIP в Artifacts.

## Структура

- `VeraApp/` — SwiftUI-приложение.
- `VeraWidget/` — виджет WidgetKit.
- `project.yml` — конфигурация XcodeGen.
- `.github/workflows/ios-build.yml` — CI-сборка.

Bundle IDs:
- App: `com.kriscarter.vera`
- Widget: `com.kriscarter.vera.widget`
- App Group: `group.com.kriscarter.vera`

Минимальная версия iOS: 17.0. Версия приложения: 1.0 (build 1).
