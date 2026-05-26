# AI Agent 使用指南

## 关于此仓库

此仓库包含针对 HarmonyOS NEXT 开发场景的 Agent Skill 定义。

## Skill 匹配规则

AI 助手应根据用户输入中的关键词自动激活对应 Skill：

| 关键词 | 触发 Skill |
|--------|-----------|
| 鸿蒙 / HarmonyOS / NEXT / API 20 | harmonyos-next-dev |
| ArkTS / ArkUI / 声明式 UI | harmonyos-next-dev |
| 元服务 / 万能卡片 / 原子化服务 | harmonyos-next-dev |
| Stage模型 / UIAbility / ExtensionAbility | harmonyos-next-dev |
| DevEco Studio / hvigor / hdc / ohpm | harmonyos-next-dev |
| HUKS / UserAuth / 生物识别 | harmonyos-next-dev |
| WaterFlow / Navigation / 状态管理 | harmonyos-next-dev |
| 架构 / 分层 / MVVM / Repository / 重构 / 可扩展性 | harmonyos-apply-architecture-best-practices |
| 项目结构 / 代码规范 / 依赖注入 / DI | harmonyos-apply-architecture-best-practices |
| 布局问题 / 溢出 / 显示不全 / 组件截断 / 布局报错 | harmonyos-fix-layout-issues |
| 单元测试 / 组件测试 / 测试用例 / hypium / 验证逻辑 | harmonyos-add-widget-test |
| 集成测试 / 端到端测试 / E2E / 自动化测试流程 | harmonyos-add-integration-test |

## 使用方式

Skill 安装后，Agent 会在检测到上述关键词时自动加载 `/references/` 目录下的详细参考文档作为上下文。用户无需手动触发。
