> #### Before create pull request
> - You must specify one of the versions in the field **NEXT_VERSION_TYPE**
> - Also you need to indicate descriptions of changes between fields **NEXT_VERSION_DESCRIPTION_BEGIN** and **NEXT_VERSION_DESCRIPTION_END**
### NEXT_VERSION_TYPE=MAJOR|MINOR|PATCH
### NEXT_VERSION_DESCRIPTION_BEGIN
### NEXT_VERSION_DESCRIPTION_END

## [1.7.3] (06-10-2021)

* set BUILD_LIBRARY_FOR_DISTRIBUTION verbose YES

## [1.7.2] (06-10-2021)

* Updated for swift library evolution

## [1.7.1] (30-08-2021)

* Зависимости в тестовом таргете переведены на xcframework; возвращена архитектура arm64 для симулятора

## [1.7.0] (30-08-2021)

* Добавлен Promise
* Подняты версии систем до: iOS 9.0; macOS 10.10; watchOS 3.0

## [1.6.7] (17-07-2021)

* Удалены лишние артефакты сборки

## [1.6.6] (16-07-2021)

* Заменено значение spec.source.git в подспеке для внутреннего распространения

## [1.6.5] (16-07-2021)

* Изменена подпись iOS framework target для сборки xcframework

## [1.6.4] (15-07-2021)

* Переименована схема iOS версии для корректной сборки xcframework

## [1.6.3] (14-07-2021)

* Выкладка xcframework на github в секцию релизов

## [1.6.2] (14-07-2021)

* Обновлена версия fastlane

## [1.6.1] (24-06-2021)

* Внесены правки для корректной выкладки исходного кода на github

## [1.6.0] (21-06-2021)

* Добавлена выкладка xcframework в nexus и выкладка исходного кода на github 