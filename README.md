# IQChannelsSwift
## Список библиотек, используемых в проекте и их назначение

1. **TRVSEventSource**: Для обработки серверных событий (Server-Sent Events).
2. **SDWebImageSwiftUI**: Для загрузки и кэширования изображений в SwiftUI.

## Руководство по установке

IQChannelsSwift доступен через [CocoaPods](https://cocoapods.org). Чтобы установить его, добавьте следующую строку в ваш Podfile:

```ruby
pod 'IQChannelsSwift', :git => 'https://github.com/iqstore/iqchannels-swift.git', :tag => '2.0.0'
```

Затем выполните команду:

```bash
pod install
```

Разрешить в `info.plist` поддержку камеры и доступа к фоткам:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Описание использования галереи</string>
    <key>NSCameraUsageDescription</key>
    <string>Описание использования камеры</string>
</dict>
</plist>
```

## Примеры использования SDK


Инициализация
-------------

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let configurationManager: IQLibraryConfigurationProtocol = IQLibraryConfiguration()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let config = IQChannelsConfig(address: "https://example.com", channels: ["channel1", "channel2"])
        configurationManager.configure(config)
        
        return true
    }
}
```

Логин
-----
Логин/логаут пользователя осуществляется по внешнему токену/сессии, специфичному для конкретного приложения.
Для логина требуется вызвать в любом месте приложения:

```swift
configurationManager.login(.credentials("myLoginToken"))
```

Для логаута:
```swift
configurationManager.logout()
```

После логина внутри SDK создается сессия пользователя и начинается бесконечный цикл, который подключается
к серверу и начинает слушать события о новых сообщения, при обрыве соединения или любой другой ошибке
сессия переподключается к серверу. При отсутствии сети, сессия ждет, когда последняя станет доступна.


Анонимные пользователи
----------------------
Чат может использоваться в анонимном режиме. Для этого после конфигурации нужно вызвать: 

```swift
configurationManager.login(.anonymous)
```

Для логаута:
```swift
configurationManager.logout()
```

Анонимный логин автоматически зарегистрирует нового анонимного пользователя, если нужно,
а потом его авторизует.

Отображение чата
--------------

Метод getViewController предназначен для получения основного навигационного контроллера (UINavigationController) библиотеки IQChannelsSwift. Этот контроллер используется как корневой контроллер для отображения пользовательского интерфейса библиотеки.

```swift
func showMessages() {
    if let navigationController = configuration.getViewController() {
        present(navigationController, animated: true)
    }
}
```

Отображение непрочитанных сообщений
-----------------------------------
Для отображения непрочитанных сообщений нужно добавить слушателя, в который будет присылаться текущее количество
новых непрочитанных сообщений `в текущем чате`. Слушателя можно добавлять в любой момент времени, в т.ч. и до конфигурации
и логина.

Пример с таббаром:
```swift
class IQTabbarController: UITabBarController, IQChannelsUnreadListenerProtocol {
    
    var id: String {
        UUID().uuidString
    }
    
    let configuration: IQLibraryConfigurationProtocol = IQLibraryConfiguration()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configuration.addUnread(listener: self)
    }
    
    // MARK: - IQChannelsUnreadListenerProtocol
    func iqChannelsUnreadDidChange(_ unread: Int) {
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
отправлять ему уведомления, а потом передать токен в библиотеку. Токен можно передавать в любой момент, 
в т.ч. до конфигурации и логина.

Пример реализации `UIApplicationDelegate`:
```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let configuration: IQLibraryConfigurationProtocol = IQLibraryConfiguration()

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
        configuration.pushToken(deviceToken)
    }
}
```

