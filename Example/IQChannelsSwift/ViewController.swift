//
//  ViewController.swift
//  IQChannelsSwift
//
//  Created by Daulet Tokmukhanbet on 05/05/2024.
//  Copyright (c) 2024 Daulet Tokmukhanbet. All rights reserved.
//

import UIKit
import IQChannelsSwift

class ViewController: UIViewController, UITextFieldDelegate {
    
    private lazy var serverField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.placeholder = "server"
        return field
    }()
    
    private lazy var emailField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.text = "101"
        return field
    }()
    
    private lazy var channelsField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.text = "support finance"
        return field
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.setTitle("Войти", for: .normal)
        button.addTarget(self, action: #selector(loginDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var anonButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.setTitle("Анонимный чат", for: .normal)
        button.addTarget(self, action: #selector(anonymousDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            serverField, emailField, channelsField, loginButton, anonButton
        ])
        view.spacing = 16
        view.distribution = .fillEqually
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let configuration: IQLibraryConfigurationProtocol = IQLibraryConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        emailField.delegate = self
        setServer(server: "https://sandbox.iqstore.ru/")
    }

    func setServer(server: String?) {
        let server = (server?.isEmpty ?? true) ? "https://sandbox.iqstore.ru/" : (server ?? "")
        let channels = channelsField.text?.components(separatedBy: .whitespaces) ?? []
        let config = IQChannelsConfig(address: server,
                                      channels: channels,
                                      styleJson: style.data(using: .utf8))
        let headers = ["User-Agent": "MyAgent"]
        configuration.configure(config)
        configuration.setCustomHeaders(headers)
        serverField.text = server
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField === emailField else { return true }
        
        loginWithEmail(textField.text)
        return true
    }
    
    func loginWithEmail(_ email: String?) {
        configuration.login(.credentials(email ?? ""))
        showMessages()
    }
    
    func showMessages(){
        if let navigationController = configuration.getViewController() {
            present(navigationController, animated: true)
        }
    }
    
    @objc func loginDidTap() {
        setServer(server: serverField.text)
        loginWithEmail(emailField.text)
    }
    
    @objc func anonymousDidTap() {
        configuration.login(.anonymous)
        showMessages()
    }
    
}

let style = """
{
  "chat": {
    "background": {
      "light": "#FFFFE0",
      "dark": "#FFFFFF"
    },
    "date_text": {
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10
    },
    "chat_history": "#008080",
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
      "light": "#FFFFE0",
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
        "light": "#000000",
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
    "text_up_message": {
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
    "text_answer": {
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10
    },
    "icon_cancel": "https://w7.pngwing.com/pngs/21/486/png-transparent-undo-common-toolbar-icon.png",
    "right_line": {
      "color": {
        "light": "#FF0000",
        "dark": "#FF0000"
      }
    }
  },
  "messages_file": {
    "background_operator": {
      "light": "#FFFACD",
      "dark": "#808080"
    },
    "background_client": {
      "light": "#FFFACD",
      "dark": "#808080"
    },
    "text": {
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10
    },
    "icon_file": "https://1000logos.net/wp-content/uploads/2023/01/Google-Docs-logo.png",
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
  "messages_image": {
    "background_operator": {
      "light": "#FFFACD",
      "dark": "#808080"
    },
    "background_client": {
      "light": "#FFFACD",
      "dark": "#808080"
    },
    "text": {
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10
    },
    "icon_load": {
      "color": {
        "light": "#008080",
        "dark": "#008080"
      }
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
  "rating": {
    "background_container": {
      "light": "#FFFACD",
      "dark": "#808080"
    },
    "text": {
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10
    },
    "text_rating": {
      "color": {
        "light": "#000000",
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
    "full_star": "https://img2.freepng.ru/20180621/itr/kisspng-business-5-star-probot-artistry-hotel-farah-5b2bdea0157717.8623271415296016960879.jpg",
    "empty_star": "https://www.downloadclipart.net/large/rating-star-background-png.png",
    "sent_rating": {
      "color": {
        "light": "#008080",
        "dark": "#008080"
      },
      "borders": 3,
      "borders_color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "border-radius": 8
    }
  },
  "tiping": {
    "background": {
      "light": "#00008B",
      "dark": "#F0FFF0"
    },
    "text": {
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "text_size": 10
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
    "border_chat": {
      "size": 3,
      "color": {
        "light": "#000000",
        "dark": "#FFFFFF"
      },
      "border-radius": 8
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
  "theme": "light",
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
  }
}
"""
