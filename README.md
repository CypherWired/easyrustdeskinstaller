[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/language-bash-green.svg)](https://www.gnu.org/software/bash/)

A simple automation script to install and manage **RustDesk Server** with ease.  

---

## 📋 Table of Contents

- [Features](#-features)
- [Installation](#-installation)
- [Usage](#-usage)
- [Menu](#-menu)
- [Credits](#-credits)
- [License](#-license)
- [Disclaimer](#%EF%B8%8F-disclaimer)
- [Support](#-support)

---

## ✨ Features

- ✅ **Fully automated** RustDesk Server installation
- ✅ **One-command client download** – automatically configured with your server
- ✅ **Service status checker** (Signal & Relay)
- ✅ **Updater integration** – keeps your server up to date
- ✅ **Firewall configuration** (UFW) for RustDesk ports
- ✅ **Clean and simple menu**

## 🚀 Installation

```bash
wget https://raw.githubusercontent.com/CypherWired/easyrustdeskinstaller/main/eri.sh
chmod +x eri.sh
sudo ./eri.sh
```

## 🔧 Usage

Run the script and follow the menu:
```bash
sudo ./eri.sh
```

## 📌 Menu

The menu comes with the following options:
- Install RustDesk Server and configure UFW to allow the ports used by RustDesk
- Update the service
- Create a Windows Portable Client configured to work with the server automatically
- Show state of the service

The idea behind the portable client is to host it on a web to offer IT Support to clients.

## 🤝 Credits

- [Techahold's Install and Update Script](https://github.com/techahold/rustdeskinstall)
- [RustDesk Official](https://rustdesk.com/)

## 📜 License

This project is licensed under the **MIT License** – see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2026 CypherWire

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

**Note:** The original scripts by dinger1986 are subject to their own licenses.

---

## ⚠️ Disclaimer

- The author is **not responsible** for any damage or data loss.
- If you encounter issues with the original installation scripts, please contact the original author.
- This is **not an official RustDesk project**.

---

## 🌟 Support

If you find this script useful, consider giving it a ⭐ on GitHub and check out other tools in my profile!

[![GitHub stars](https://img.shields.io/badge/⭐-Star%20on%20GitHub-yellow)](https://github.com/CypherWired/easyrustdeskinstaller)
