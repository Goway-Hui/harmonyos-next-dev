# HarmonyOS NEXT 开发 Skill

> AI Agent Skill — 协助 HarmonyOS NEXT (API 20+) 应用开发

[![GitHub Repo](https://img.shields.io/badge/GitHub-Goway--Hui%2Fharmonyos--next--dev-blue)](https://github.com/Goway-Hui/harmonyos-next-dev)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![skills.sh](https://img.shields.io/badge/skills.sh-harmonyos--next--dev-8A2BE2)](https://skills.sh/Goway-Hui/harmonyos-next-dev)

## 概述

本 Skill 为 AI 编码助手提供了 HarmonyOS NEXT 应用开发的完整知识库，涵盖 **20 个参考模块**和 **11 个可直接运行的代码模板**：

| 领域 | 内容 |
|------|------|
| 📘 **ArkTS 语言** | 类型系统、装饰器、并发(TaskPool/Worker)、异步编程 |
| 🎨 **ArkUI 声明式 UI** | 组件库、布局、动画、状态管理 V1+V2、WaterFlow |
| 🏗 **应用框架** | UIAbility、UIExtensionAbility、Navigation(NavPathStack) |
| ⚙️ **系统能力** | 通知、权限、传感器、蓝牙、Wi-Fi、NFC |
| 🎵 **媒体与图形** | 音视频、相机、Canvas、XComponent |
| 🤖 **AI 能力** | MindSpore Lite、AI Kit(OCR/ASR/TTS/人脸/条码/翻译) |
| 📱 **元服务** | 原子化服务、万能卡片(FormKit)、快捷方式 |
| 🪟 **实况窗** | Live View、锁屏动态卡片、状态栏胶囊 |
| 🔄 **分布式能力** | 设备发现、分布式KVStore、RPC远程调用 |
| 🛡 **安全认证** | UserAuth(指纹/人脸)、HUKS 密钥管理 |
| 📱 **多设备适配** | 断点系统、响应式布局、折叠屏适配 |
| 🛠 **开发工具** | DevEco Studio、hvigor、hdc、ohpm、hilog |

## 安装

```bash
# 安装全部 Skill
npx skills add Goway-Hui/harmonyos-next-dev

# 安装单个 Skill
npx skills add Goway-Hui/harmonyos-next-dev --skill harmonyos-next-dev
```

## 使用

当用户提到以下关键词时，AI 助手自动触发此 Skill：

> 鸿蒙、HarmonyOS、ArkTS、ArkUI、NEXT、API 20、元服务、万能卡片、Stage模型、DevEco Studio、UIExtensionAbility、WaterFlow、HUKS、UserAuth 等

## 目录结构

```
harmonyos-next-dev/
├── README.md
├── AGENTS.md                    # AI 代理使用指南
├── CHANGELOG.md                 # 版本历史
├── LICENSE                      # MIT
├── .gitignore
└── harmonyos-next-dev/          # 📦 Skill 主目录
    ├── SKILL.md                 # 主定义文件（YAML frontmatter）
    ├── assets/                  # 11 个即用型代码模板
    │   ├── common-page-structure.ets
    │   ├── list-page-template.ets
    │   ├── state-management-v2-template.ets
    │   ├── login-form-template.ets
    │   ├── tab-page-template.ets
    │   ├── network-request-template.ets
    │   ├── modal-sheet-template.ets
    │   ├── waterflow-template.ets
    │   ├── database-crud-template.ets
    │   ├── form-page-template.ets
    │   └── custom-component-template.ets
    └── references/              # 20 个参考文档
        ├── arkts-language.md
        ├── arkui-components.md
        ├── application-framework.md
        ├── system-capabilities.md
        ├── media.md
        ├── graphics.md
        ├── app-services.md
        ├── ai.md
        ├── special-topics.md
        ├── meta-services.md
        ├── i18n-localization.md
        ├── security-authentication.md
        ├── background-tasks.md
        ├── tools.md
        ├── telephony.md
        ├── live-view.md
        ├── distributed-capabilities.md
        ├── data-sharing.md
        ├── drag-drop.md
        ├── accessibility.md
        └── multi-device-adaptation.md
```

## 发布说明

**v1.0.0** — 初始版本发布

- 覆盖 HarmonyOS NEXT (API 20+) 全栈开发知识
- 20 个参考文档 + 11 个代码模板
- 支持 ArkTS、ArkUI、应用框架、系统能力、媒体、图形、AI、元服务等 20+ 主题

## License

MIT
