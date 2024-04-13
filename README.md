IQChannelsSwift iOS SDK
==================
SDK для айфона сделано как библиотека для Cocoapods.

Зависимости:
* SDWebImage
> Используется для эффективной загрузки изображений в SDK и оптимизации процесса отображения изображений для пользователей.

* TRVSEventSource
> Используется для работы с сервер-отправляемыми событиями (Server-Sent Events), обеспечивая реактивное обновление данных для ваших пользователей.

* MessageKit
> Библиотека предназначенная для создания интерфейса чата. Используется для реализации функциональности чата в SDK.

* InputBarAccessoryView
> Это зависимость MessageKit, компонент пользовательского интерфейса, который предоставляет удобную панель ввода для чатов и мессенджеров. 

* SnapKit
> Используется для написания констрейнтов (ограничений) в коде с помощью DSL (Domain-Specific Language).

* SwiftMessages
> Это библиотека для отображения красивых и анимированных сообщений в SDK. Используется для вывода уведомлений, сообщений об ошибках или других важных сообщений в SDK.

Структура:
* `IQChannels.podspec` - спецификация для Cocoapods.
* `IQChannelsSwift` - исходный код SDK.
* `Example` - пример работающего приложения.


Установка
---------
Добавить `IQChannelsSwift` в зависимости в `Podfile` проекта:
```
# Podfile
pod 'IQChannelsSwift', :git => 'https://github.com/iqstore/iqchannels-swift.git', :tag => '2.0.0'
```

Установить зависимости:
```
pod install
```

Разрешить в `info.plist` поддержку камеры и доступа к фоткам:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Описание использования фотоко</string>
    <key>NSCameraUsageDescription</key>
    <string>Описание использования камеры</string>
</dict>
</plist>
```


Инициализация
-------------
Приложение разделено на два основных класса: `IQChannels` и `IQChannelMessagesViewController`.
Первый представляет собой библиотеку, которая реализуюет бизнес-логику SDK. Второй - это вью-контроллер
для сообщений, который написан по образу и подобию iMessages.

Обычно SDK будет инициализированно в `AppDelegate` приложения:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Создаем объект конфигурации, заполняем адрес и название канала (чата).
    // Канал создается в панеле управления IQChannels.
    let config = IQChannelsConfig(address: "server", channel: "support")
    
    // Конфигурируем SDK.
    IQChannels.configure(config)
    return true
}
```


Логин
-----
Логин/логаут пользователя осуществляется по внешнему токену/сессии, специфичному для конкретного приложения.
Для логина требуется вызвать в любом месте приложения:

```swift
IQChannels.login("myLoginToken")
```

Для логаута:
```swift
IQChannels.logout()
```

После логина внутри SDK создается сессия пользователя и начинается бесконечный цикл, который подключается
к серверу и начинает слушать события о новых сообщения, при обрыве соединения или любой другой ошибке
сессия переподключается к серверу. При отсутствии сети, сессия ждет, когда последняя станет доступна.


Анонимные пользователи
----------------------
Чат может использоваться в анонимном режиме. Для этого после конфигурации нужно вызвать: 

```swift
IQChannels.loginAnonymous()
```

Для логаута:
```swift
IQChannels.logout()
```

Анонимный логин автоматически зарегистрирует нового анонимного пользователя, если нужно,
а потом его авторизует.


Интерфейс чата
--------------
Интерфес чата построен на основе MessagesViewController(MessageKit). Интерфейс чата корректно обрабатывает логины/логаут,
обнуляет сообщения.

Это обычный ViewController, который можно наследовать и использовать всеми стандартными способами
в приложении для айоса. Например:

```swift
func showMessages() {
    let vc = IQChannelMessagesViewController()
    let nc = UINavigationController(rootViewController: vc)
    if let viewController = UIApplication.shared.windows.first?.rootViewController {
        viewController.present(nc, animated: true, completion: nil)
    }
}
```


Отображение непрочитанных сообщений
-----------------------------------
Для отображения непрочитанных сообщений нужно добавить слушателя, в который будет присылаться текущее количество
новых непрочитанных сообщений. Слушателя можно добавлять в любой момент времени, в т.ч. и до конфигурации
и логина.

Пример с таббаром:
```swift
class IQTabbarController: UITabBarController, IQChannelsUnreadListener {
    
    var unreadSub: IQChannelsUnreadSubscription?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        unreadSub = IQChannels.unread(self)
    }
    
    // MARK: - IQChannelsUnreadListener
    func iq_unreadChanged(_ unread: Int) {
        if unread == 0 {
            self.messages?.tabBarItem.badgeValue = nil
        } else {
            self.messages?.tabBarItem.badgeValue = "\(unread)"
        }
    }
}
```


Отправка пуш-токенов
--------------------
Для поддержки пуш-уведомлений требуется при старте приложения запросить у пользователя возможность
отправлять ему уведомления, а потом передать токен в IQChannels. Токен можно передавать в любой момент, 
в т.ч. до конфигурации и логина.

Пример реализации `UIApplicationDelegate`:
```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerForNotifications(application)
        return true
    }

    func registerForNotifications(_ application: UIApplication) {
        let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(settings)
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        guard notificationSettings.types != [] else {
            return
        }
        application.registerForRemoteNotifications()
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        IQChannels.pushToken(deviceToken)
    }
}
```
