# Тихий свет — iOS starter

Нативный SwiftUI-проект с WidgetKit: главный экран, темы, избранное и виджеты Small / Medium / Large.

## Важно
Сборка iOS-приложения и подпись IPA требуют macOS + Xcode. На Arch можно редактировать проект, хранить его в Git и запускать сборку на удалённом Mac (например, GitHub Actions с macOS runner). Этот архив — исходный проект, не готовый IPA.

## 1. Настроить идентификаторы
Сейчас используются:
- App: `com.kriscarter.vera`
- Widget: `com.kriscarter.vera.widget`
- App Group: `group.com.kriscarter.vera`

Замени их на свои уникальные идентификаторы в `project.yml`, `VeraApp/Vera.entitlements` и `VeraWidget/VeraWidget.entitlements`. Один и тот же App Group должен быть включён для приложения и расширения в Apple Developer.

## 2. Сборка на Mac
Установить Xcode и XcodeGen, затем в папке проекта:

```bash
brew install xcodegen
xcodegen generate
open Vera.xcodeproj
```

В Xcode выбери Team для обоих targets (Vera и VeraWidget), проверь Signing & Capabilities и включи одинаковый App Group для обоих targets. Затем выбери Any iOS Device и Product → Archive.

Для установки на устройство потребуется корректная подпись и provisioning profile, включающий App Group и Widget Extension.

## 3. Работа с Arch
На Arch можно редактировать Swift-файлы любым редактором и отправлять проект в GitHub. Удалённая сборка выполняется на macOS runner. Для подписанного IPA нужно настроить сертификат Apple Distribution и provisioning profiles в защищённых GitHub Secrets; не загружай приватный ключ в публичный репозиторий.

## 4. Что уже реализовано
- Тёмный интерфейс с золотистым акцентом.
- Четыре вкладки: Главная, Темы, Избранное, Настройки.
- Выбор категорий и передача настроек виджету через App Group.
- WidgetKit: Small, Medium и Large.
- Локальная подборка из 24 библейских отрывков.
- Выбор одной из четырёх цветовых тем виджета: Графит, Полночь, Бордо, Лес.
- Timeline с несколькими записями; реальная частота обновления контролируется iOS.

## 5. Следующие этапы
1. Подключить App Group и signing в Apple Developer.
2. Собрать и проверить на iPhone.
3. Добавить импорт большой проверенной библиотеки текстов и молитв.
4. Добавить редактор оформления, фоновые изображения, шаринг-карточки и историю.
5. Настроить CI-сборку подписанного IPA под твой сертификат.
