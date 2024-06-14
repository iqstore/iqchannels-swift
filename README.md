# IQChannelsSwift
## Список библиотек, используемых в проекте и их назначение

1. **SDWebImageSwiftUI**: Для загрузки и кэширования изображений в SwiftUI.

## Руководство по установке

IQChannelsSwift доступен через [CocoaPods](https://cocoapods.org). Чтобы установить его, добавьте следующую строку в ваш Podfile:

```ruby
pod 'IQChannelsSwift', :git => 'https://github.com/iqstore/iqchannels-swift.git’, :tag => '2.0.0-rc1'
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
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Описание использования галереи</string>
    <key>NSCameraUsageDescription</key>
    <string>Описание использования камеры</string>
</dict>
</plist>
```

## Примеры использования SDK


Инициализация c несколькими каналами
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

Инициализация c одним каналом
-------------

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let configurationManager: IQLibraryConfigurationProtocol = IQLibraryConfiguration()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let config = IQChannelsConfig(address: "https://example.com", channels: ["channel1"])
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

## Пример использования стилизации

Для того чтобы поменять стили элементов внутри SDK, нужно передать поддерживаемый JSON файл при инициализации как в примере ниже:
```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let configurationManager: IQLibraryConfigurationProtocol = IQLibraryConfiguration()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let json: Data = // JSON файл в формате Data 
        let config = IQChannelsConfig(address: "https://example.com", channels: ["channel1"], styleJson: json)
        configurationManager.configure(config)
        
        return true
    }
}
```

Пример JSON для передачи в SDK
--------------------

```json
{
    "chat": {
        "background": {
            "light": "#FFFFFF",
            "dark": "#FFFFE0"
        },
        "date_text": {
            "color": {
                "light": "#000000",
                "dark": "#FFFFFF"
            },
            "text_size": 13
        },
        "chat_history": {
            "light": "#008080",
            "dark": "#008080"
        },
        "icon_operator": "https://gas-kvas.com/grafic/uploads/posts/2024-01/gas-kvas-com-p-logotip-cheloveka-na-prozrachnom-fone-4.png",
        "system_text": {
            "color": {
                "light": "#000000",
                "dark": "#FFFFFF"
            },
            "text_size": 10
        }
    },
    "messages": {
        "background_operator": {
            "light": "#FFFFE0",
            "dark": "#808080"
        },
        "background_client": {
            "light": "#242729",
            "dark": "#808080"
        },
        "text_operator": {
            "color": {
                "light": "#000000",
                "dark": "#FFFFFF"
            },
            "text_size": 10
        },
        "text_client": {
            "color": {
                "light": "#ffffff",
                "dark": "#FFFFFF"
            },
            "text_size": 10
        },
        "reply_text_client": {
            "color": {
                "light": "#ffffff",
                "dark": "#FFFFFF"
            },
            "text_size": 10
        },
        "reply_sender_text_client": {
            "color": {
                "light": "#ffffff",
                "dark": "#FFFFFF"
            },
            "text_size": 10
        },
        "reply_text_operator": {
            "color": {
                "light": "#ffffff",
                "dark": "#FFFFFF"
            },
            "text_size": 10
        },
        "reply_sender_text_operator": {
            "color": {
                "light": "#ffffff",
                "dark": "#FFFFFF"
            },
            "text_size": 10
        },
        "text_time": {
            "color": {
                "light": "#000000",
                "dark": "#FFFFFF"
            },
            "text_size": 10
        },
        "text_up": {
            "color": {
                "light": "#000000",
                "dark": "#FFFFFF"
            },
            "text_size": 10
        }
    },
    "answer": {
        "text_sender": {
            "color": {
                "light": "#000000",
                "dark": "#FFFFFF"
            },
            "text_size": 10
        },
        "text_message": {
            "color": {
                "light": "#000000",
                "dark": "#FFFFFF"
            },
            "text_size": 10
        },
        "background_text_up_message": {
            "light": "#FFFACD",
            "dark": "#808080"
        },
        "icon_cancel": "https://w7.pngwing.com/pngs/21/486/png-transparent-undo-common-toolbar-icon.png",
        "left_line": {
            "light": "#FF0000",
            "dark": "#FF0000"
        }
    },
    "messages_file": {
        "text_filename_client": {
            "color": {
                "light": "#000000",
                "dark": "#FFFFFF"
            },
            "text_size": 10
        },
        "text_filename_operator": {
            "color": {
                "light": "#000000",
                "dark": "#FFFFFF"
            },
            "text_size": 10
        },
        "icon_file_client": "https://1000logos.net/wp-content/uploads/2023/01/Google-Docs-logo.png",
        "icon_file_operator": "https://1000logos.net/wp-content/uploads/2023/01/Google-Docs-logo.png",
        "text_file_size_client": {
            "color": {
                "light": "#ffffff",
                "dark": "#FFFFFF"
            },
            "text_size": 10
        },
        "text_file_size_operator": {
            "color": {
                "light": "#ffffff",
                "dark": "#FFFFFF"
            },
            "text_size": 10
        }
    },
    "rating": {
        "background_container": {
            "light": "#FFFACD",
            "dark": "#808080"
        },
        "full_star": "https://img2.freepng.ru/20180621/itr/kisspng-business-5-star-probot-artistry-hotel-farah-5b2bdea0157717.8623271415296016960879.jpg",
        "empty_star": "https://www.downloadclipart.net/large/rating-star-background-png.png",
        "sent_rating": {
            "color_enabled": {
                "light": "#008080",
                "dark": "#008080"
            },
            "color_disabled": {
                "light": "#B7B7CA",
                "dark": "#B7B7CA"
            },
            "text_enabled": {
                "color": {
                    "light": "#FFFFFF",
                    "dark": "#FFFFFF"
                },
                "text_size": 10
            },
            "text_disabled": {
                "color": {
                    "light": "#FFFFFF",
                    "dark": "#FFFFFF"
                },
                "text_size": 10
            }
        }
    },
    "tools_to_message": {
        "icon_sent": "https://e7.pngegg.com/pngimages/414/329/png-clipart-computer-icons-share-icon-edit-angle-triangle.png",
        "background_icon": {
            "light": "#DEB887",
            "dark": "#696969"
        },
        "background_chat": {
            "light": "#DEB887",
            "dark": "#696969"
        },
        "text_chat": {
            "color": {
                "light": "#000000",
                "dark": "#FFFFFF"
            },
            "text_size": 10
        },
        "icon_clip": "https://cdn-icons-png.flaticon.com/512/84/84281.png"
    },
    "error": {
        "title_error": {
            "color": {
                "light": "#000000",
                "dark": "#FFFFFF"
            },
            "text_size": 16
        },
        "text_error": {
            "color": {
                "light": "#000000",
                "dark": "#FFFFFF"
            },
            "text_size": 10
        },
        "icon_error": "https://w7.pngwing.com/pngs/285/84/png-transparent-computer-icons-error-super-8-film-angle-triangle-computer-icons.png"
    },
    "single-choice": {
        "background_button": {
            "light": "#FFFF00",
            "dark": "#00FFFF"
        },
        "border_button": {
            "size": 3,
            "color": {
                "light": "#000000",
                "dark": "#FFFFFF"
            },
            "border-radius": 10
        },
        "text_button": {
            "color": {
                "light": "#000000",
                "dark": "#FFFFFF"
            },
            "text_size": 10
        },
        "background_IVR": {
            "light": "#FFFF00",
            "dark": "#00FFFF"
        },
        "border_IVR": {
            "size": 3,
            "color": {
                "light": "#000000",
                "dark": "#FFFFFF"
            },
            "border-radius": 10
        },
        "text_IVR": {
            "color": {
                "light": "#000000",
                "dark": "#FFFFFF"
            },
            "text_size": 10
        }
    },
    "theme": "light"
}
```

