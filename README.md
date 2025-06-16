# IQChannelsSwift
## Список библиотек, используемых в проекте и их назначение

1. **TRVSEventSource**: Для обработки серверных событий (Server-Sent Events).
2. **SDWebImageSwiftUI**: Для загрузки и кэширования изображений в SwiftUI.
2. **SQLite.swift**: Для сохранения сообщений в локальную базу.
    

## Руководство по установке

IQChannelsSwift доступен через [CocoaPods](https://cocoapods.org). Чтобы установить его, добавьте следующую строку в ваш Podfile:

```ruby
pod 'IQChannelsSwift', :git => 'https://github.com/iqstore/iqchannels-swift.git', :tag => '2.2.0'
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

Инициализация c определенным чатом
-------------

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let configurationManager: IQLibraryConfigurationProtocol = IQLibraryConfiguration()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let config = IQChannelsConfig(address: "https://example.com",
                                      channels: ["channel1", "channel2"],
                                      chatToOpen: ("channel1", IQChatType.manager)) // Чат который требуется открыть
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
Для отображения непрочитанных сообщений нужно добавить слушателя, в который будет присылаться количество
непрочитанных сообщений `в текущем чате`. Слушателя нужно добавлять после конфигурации и логина.

Пример реализации:
```swift
class ViewController: UIViewController, UITextFieldDelegate, IQChannelsUnreadListenerProtocol {
    var id: String {
        UUID().uuidString
    }
    
    let configuration: IQLibraryConfigurationProtocol = IQLibraryConfiguration()
    
    func iqChannelsUnreadDidChange(_ unread: Int) {
        self.unreadLabel.text = "Непрочитанных сообщений: \(unread)"
    }
    
    private lazy var unreadLabel: UILabel = {
        let label = UILabel()
        label.text = "Непрочитанных сообщений: nil"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setServer(server: "https://example.ru")   // Конфигурация
        configuration.login(.anonymous)           // Логин
        configuration.addUnread(listener: self)   // Добавление слушателя
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
## Пример использования перехватчика событий

Чтобы обработать событие при нажатии кнопки "Назад" и при необходимости отменить его, нужно реализовать методы протокола IQChannelsEventListenerProtocol.

``` swift
class AppDelegate: UIResponder, UIApplicationDelegate, IQChannelsEventListenerProtocol {
    
    let configurationManager: IQLibraryConfigurationProtocol = IQLibraryConfiguration()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let config = IQChannelsConfig(address: "https://example.com", channels: ["channel1"])
        configurationManager.configure(config)
        configuration.addEvent(listener: self)

        return true
    }

    func iqChannelsShouldCloseModule() -> Bool {
        // Вызывается при попытке закрыть модуль, вернуть `false`, чтобы предотвратить закрытие
        return true
    }

    func iqChannelsShouldCloseChat() -> Bool {
        // Вызывается при попытке закрыть чат, вернуть `false`, чтобы предотвратить закрытие
        return true
    }
}
```

## Пример использования стилизации

Для переключения темы следует использовать метод IQChannelsConfig.setTheme

<details>
  <summary>Пример переключения темы</summary>
  
```swift
let config = IQChannelsConfig(address: "https://example.com", channels: ["channel1"], styleJson: json)
config.setTheme(.dark)
configurationManager.configure(config)
```
</details>

<details>
  <summary>Поддерживаемые темы (IQTheme)</summary>
  
```swift
public enum IQTheme {
    /** Принудительно темная */ case dark
    /** Принудительно светлая */ case light
    /** Автоматически меняется вместе с темой устройства */ case system
}
```
</details>

Для того чтобы поменять стили элементов внутри SDK, нужно передать поддерживаемый JSON файл. Его можно передать как при инициализации, так и после нее, channelManager при этом не переопределяется

<details>
  <summary>Пример подгрузки темы из Json</summary>
  
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
</details>

--------------------

<details>
  <summary>Пример JSON для передачи в SDK</summary>

```json
{
  "signup": {                 //Авторизация: (только Android)
    "background": {           //Фон
      "light": "#FFFFFF",     //Цвет для светлой темы
      "dark": "#FFFFE0"       //Цвет для темной темы
    },
    "title": {                //Заголовок
      "color": {              //Цвета для светлой и темной темы
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,        //Размер текста
      "text_align": "center", //Выравнивание текста
      "text_style": {
        "bold": true,         //Жирность
        "italic": false       //Курсив
      }
    },
    "subtitle": {             //Подзаголовок
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "input_background": {     //Фон области ввода имени
      "color": {
        "light": "#FFFFFF",
        "dark": "#000000"
      },
      "border": {             //Обводка
        "size": 0,            //Толщина
        "color": {            //Цвета для светлой и темной темы
          "light": "#000000",
          "dark": "#000000"
        },
        "border-radius": 0    //Скругление
      }
    },
    "input_text": {           //Текст в поле ввода
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "left",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "check_box_text": {       //Текст возле чекбокса
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "left",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "button": {               //Кнопка входа
      "background_enabled": { //Активная кнопка
        "color": {
          "light": "#000000",
          "dark": "#000000"
        },
        "border": {
          "size": 0,
          "color": {
            "light": "#000000",
            "dark": "#000000"
          },
          "border-radius": 0
        }
      },
      "background_disabled": { //Неактивная кнопка
        "color": {
          "light": "#555555",
          "dark": "#555555"
        },
        "border": {
          "size": 0,
          "color": {
            "light": "#000000",
            "dark": "#000000"
          },
          "border-radius": 0
        }
      },
      "text_enabled": {       //Текст на активной кнопке
        "color": {
          "light": "#FFFFFF",
          "dark": "#FFFFFF"
        },
        "text_size": 10,
        "text_align": "center",
        "text_style": {
          "bold": false,
          "italic": false
        }
      },
      "text_disabled": {      //Текст на неактивной кнопке
        "color": {
          "light": "#FFFFFF",
          "dark": "#FFFFFF"
        },
        "text_size": 10,
        "text_align": "center",
        "text_style": {
          "bold": false,
          "italic": false
        }
      }
    },
    "error_text": {           //Текст ошибки
      "color": {
        "light": "#c70037",
        "dark": "#c70037"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    }
  },
  "chat": {                   //Общий чат:
    "background": {           //Фон чата
      "light": "#FFFFFF",
      "dark": "#FFFFE0"
    },
    "date_text": {            //Текст относительной даты чата (по середине)
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "chat_history": {         //Верхний индикатор загрузки предыдущих сообщений
      "light": "#008080",
      "dark": "#008080"
    },
    "chat_loader": {          //индикатор загрузки сообщений (основной лоадер)
      "light": "#008080",
      "dark": "#008080"
    },
    "icon_operator": "https://gas-kvas.com/grafic/uploads/posts/2024-01/gas-kvas-com-p-logotip-cheloveka-na-prozrachnom-fone-4.png", //Иконка оператора
    "system_text": {          //Системные сообщения
      "color": {
        "light": "#888888",
        "dark": "#888888"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "status_label": {         //Текст статуса в шапке чата
      "color": {
        "light": "#888888",
        "dark": "#888888"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "title_label": {          //Заголовок в шапке чата
      "color": {
        "light": "#888888",
        "dark": "#888888"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    }
  },
  "messages": {               //Сообщение отправка текста (стили применяются ко всем производным сообщениям):
    "background_operator": {  //Фон контейнера (оператор)
      "color": {
        "light": "#FFFFE0",
        "dark": "#808080"
      },
      "border": {
        "size": 0,
        "color": {
          "light": "#000000",
          "dark": "#000000"
        },
        "border-radius": 0
      }
    },
    "background_client": {    //Фон контейнера (клиент)
       "color": {
        "light": "#242729",
        "dark": "#808080"
      },
      "border": {
        "size": 0,
        "color": {
          "light": "#000000",
          "dark": "#000000"
        },
        "border-radius": 0
      }
    },
    "text_operator": {        //Текст сообщения (оператор)
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "text_client": {          //Текст сообщения (клиент)
      "color": {
        "light": "#ffffff",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "reply_text_client": {    //Основной текст ответа со стороны клиента
      "color": {
        "light": "#ffffff",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "reply_sender_text_client": {   //Текст сообщения, на которое ответил клиент
      "color": {
        "light": "#ffffff",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "reply_text_operator": {        //Основной текст ответа со стороны оператора
      "color": {
        "light": "#ffffff",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "reply_sender_text_operator": { //Текст сообщения, на которое ответил оператор
      "color": {
        "light": "#ffffff",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "text_time_operator": {         //Текст времени доставки (Оператор)
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "text_time_client": {           //Текст времени доставки (Клиент)
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "text_up": {                    //Текст над контейнером (Имя оператора/бота)
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "text_file_state_rejected_operator": { // Текст файла от оператора при статусе rejected
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "text_file_state_on_checking_operator": { // Текст файла от оператора при статусе on_checking
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "text_file_state_sent_for_checking_operator": { // Текст файла от оператора при статусе sent_for_checking
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "text_file_state_check_error_operator": { // Текст файла от оператора при статусе check_error
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "text_file_state_rejected_client": { // Текст файла от клиента при статусе rejected
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "text_file_state_on_checking_client": { // Текст файла от клиента при статусе on_checking
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "text_file_state_sent_for_checking_client": { // Текст файла от клиента при статусе sent_for_checking
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "text_file_state_check_error_client": { // Текст файла от клиента при статусе check_error
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    }
  },
  "answer": {                 //Ответ на сообщения:
    "text_sender": {          //Текст сообщения над полем ввода
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "text_message": {         //Текст сообщения в отвеченном сообщении
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "background_text_up_message": {       //Фон текста сообщения над полем ввода
      "light": "#FFFACD",
      "dark": "#808080"
    },
    "icon_cancel": "https://w7.pngwing.com/pngs/21/486/png-transparent-undo-common-toolbar-icon.png",     //Кнопка закрыть/отменить – вид кнопки(изменяется с помощью файла с иконкой)
    "left_line": {                        //Прямая вертикальная линия рядом с сообщением, на которое отвечаем - цвет
      "light": "#FF0000",
      "dark": "#FF0000"
    }
  },
  "messages_file": {                      //Сообщение отправка файла:
    "text_filename_client": {             //Цвет названия файла со стороны клиента
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "text_filename_operator": {           //Цвет названия файла со стороны оператора
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "icon_file_client": "https://1000logos.net/wp-content/uploads/2023/01/Google-Docs-logo.png",      //Иконка файла со стороны клиента
    "icon_file_operator": "https://1000logos.net/wp-content/uploads/2023/01/Google-Docs-logo.png",    //Иконка файла со стороны оператора
    "text_file_size_client": {             //Цвет размера файла со стороны клиента
      "color": {
        "light": "#ffffff",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "text_file_size_operator": {            //Цвет размера названия файла со стороны оператора
      "color": {
        "light": "#ffffff",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    }
  },
  "rating": {                             //Сообщение оценки качества:
    "background_container": {             //Фон контейнера - по умолчанию как у сообщения
      "color": {
        "light": "#FFFACD",
        "dark": "#808080"
      },
      "border": {
        "size": 0,
        "color": {
          "light": "#000000",
          "dark": "#000000"
        },
        "border-radius": 0
      }
    },
    "rating_title": {                     //Заголовок вопроса
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "full_star": "https://img2.freepng.ru/20180621/itr/kisspng-business-5-star-probot-artistry-hotel-farah-5b2bdea0157717.8623271415296016960879.jpg",    //Закрашенная звезда – вид иконки(изменяется с помощью файла с иконкой)
    "empty_star": "https://www.downloadclipart.net/large/rating-star-background-png.png", //Незакрашенная звезда – вид иконки(изменяется с помощью файла с иконкой)
    "sent_rating": {                      //Кнопка отправки оценки
      "background_enabled": {             //Активная кнопка
        "color": {
          "light": "#008080",
          "dark": "#008080"
        },
        "border": {
          "size": 0,
          "color": {
            "light": "#000000",
            "dark": "#000000"
          },
          "border-radius": 0
        }
      },
      "background_disabled": {            //Неактивная кнопка
        "color": {
          "light": "#B7B7CA",
          "dark": "#B7B7CA"
        },
        "border": {
          "size": 0,
          "color": {
            "light": "#000000",
            "dark": "#000000"
          },
          "border-radius": 0
        }
      },
      "text_enabled": {                   //Текст на активной кнопке
        "color": {
          "light": "#ffffff",
          "dark": "#FFFFFF"
        },
        "text_size": 10,
        "text_align": "center",
        "text_style": {
          "bold": false,
          "italic": false
        }
      },
      "text_disabled": {                  //Текст на неактивной кнопке
        "color": {
          "light": "#ffffff",
          "dark": "#FFFFFF"
        },
        "text_size": 10,
        "text_align": "center",
        "text_style": {
          "bold": false,
          "italic": false
        }
      }
    },
    "answer_button": {                    //Кнопки выбора в вопросе
      "background_enabled": {             //Активная кнопка
        "color": {
          "light": "#008080",
          "dark": "#008080"
        },
        "border": {
          "size": 0,
          "color": {
            "light": "#000000",
            "dark": "#000000"
          },
          "border-radius": 0
        }
      },
      "background_disabled": {            //Неактивная кнопка
        "color": {
          "light": "#B7B7CA",
          "dark": "#B7B7CA"
        },
        "border": {
          "size": 0,
          "color": {
            "light": "#000000",
            "dark": "#000000"
          },
          "border-radius": 0
        }
      },
      "text_enabled": {                   //Текст на активной кнопке
        "color": {
          "light": "#ffffff",
          "dark": "#FFFFFF"
        },
        "text_size": 10,
        "text_align": "center",
        "text_style": {
          "bold": false,
          "italic": false
        }
      },
      "text_disabled": {                  //Текст на неактивной кнопке
        "color": {
          "light": "#ffffff",
          "dark": "#FFFFFF"
        },
        "text_size": 10,
        "text_align": "center",
        "text_style": {
          "bold": false,
          "italic": false
        }
      }
    },
    "scale_button": {                     //Кнопки в вопросе типа "Scale"
      "background_enabled": {             //Активная кнопка
        "color": {
          "light": "#008080",
          "dark": "#008080"
        },
        "border": {
          "size": 0,
          "color": {
            "light": "#000000",
            "dark": "#000000"
          },
          "border-radius": 0
        }
      },
      "background_disabled": {            //Неактивная кнопка
        "color": {
          "light": "#B7B7CA",
          "dark": "#B7B7CA"
        },
        "border": {
          "size": 0,
          "color": {
            "light": "#000000",
            "dark": "#000000"
          },
          "border-radius": 0
        }
      },
      "text_enabled": {                   //Текст на активной кнопке
        "color": {
          "light": "#ffffff",
          "dark": "#FFFFFF"
        },
        "text_size": 10,
        "text_style": {
          "bold": false,
          "italic": false
        }
      },
      "text_disabled": {                  //Текст на неактивной кнопке
        "color": {
          "light": "#ffffff",
          "dark": "#FFFFFF"
        },
        "text_size": 10,
        "text_style": {
          "bold": false,
          "italic": false
        }
      }
    },
    "scale_min_text": {                   //Текст низкой оценки
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "left",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "scale_max_text": {                   //Текст высокой оценки
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "right",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "input_background": {                 //Фон поля ввода в вопросе типа "Input"
      "color": {
        "light": "#ffffff",
        "dark": "#FFFFFF"
      },
      "border": {
        "size": 0,
        "color": {
          "light": "#000000",
          "dark": "#000000"
        },
        "border-radius": 0
      }
    },
    "input_text": {                       //Текст поля ввода в вопросе типа "Input"
      "color": {
        "light": "#000000",
        "dark": "#000000"
      },
      "text_size": 10
    },
    "feedback_thanks_text": {             //Текст благодарности за прохождение опроса
      "color": {
        "light": "#000000",
        "dark": "#000000"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    }
  },
  "tools_to_message": {                   //Панель инструментов (для отправки сообщений):
    "background": {                       //Фон панели
      "light": "#ffffff",
      "dark": "#696969"
    },
    "icon_sent": "https://e7.pngegg.com/pngimages/414/329/png-clipart-computer-icons-share-icon-edit-angle-triangle.png", //Иконка-кнопка для отправки – вид кнопки(изменяется с помощью файла с иконкой)
    "background_icon": {                  //Фон иконки для отправки
      "light": "#DEB887",
      "dark": "#696969"
    },
    "background_input": {                 //Фон области ввода текста
      "color": {
        "light": "#DEB887",
        "dark": "#696969"
      },
      "border": {
        "size": 0,
        "color": {
          "light": "#000000",
          "dark": "#000000"
        },
        "border-radius": 0
      }
    },
    "text_input": {                       //Текст в поле ввода
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10
    },
    "icon_clip": "https://cdn-icons-png.flaticon.com/512/84/84281.png",  //Иконка-кнопка 'скрепка' - вид кнопки(изменяется с помощью файла с иконкой)
    "cursor_color": {                     //Цвет курсора
      "light": "#525252",
      "dark": "#525252"
    }
  },
  "error": {                              //Страница ошибки:
    "title_error": {                      //Заголовок
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "text_error": {                       //Основной текст
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "icon_error": "https://w7.pngwing.com/pngs/285/84/png-transparent-computer-icons-error-super-8-film-angle-triangle-computer-icons.png"          //Иконка ошибки - вид иконки(изменяется с помощью файла с иконкой)
  },
  "single-choice": {                    //Single-choice сообщение:
    "background_button": {              //Фон кнопки Single-choice
      "light": "#FFFF00",
      "dark": "#00FFFF"
    },
    "border_button": {                  //Граница кнопки Single-choice
      "size": 3,
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "border-radius": 10
    },
    "text_button": {                    //Текст кнопки Single-choice
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    },
    "background_IVR": {                 //Фон IVR кнопки Single-choice (isDropDown)
      "light": "#00000000",
      "dark": "#00000000"
    },
    "border_IVR": {                     //Граница IVR кнопки Single-choice (isDropDown)
      "size": 1,
      "color": {
        "light": "#74b928",
        "dark": "#74b928"
      },
      "border-radius": 10
    },
    "text_IVR": {                       //Текст IVR кнопки Single-choice (isDropDown)
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10,
      "text_align": "center",
      "text_style": {
        "bold": false,
        "italic": false
      }
    }
  },
  "theme": "light"                      //Выбранная тема (светлая/темная)
}
```
</details>
