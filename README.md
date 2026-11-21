# C10H · 安装并驾驭 Hermes Agent

- 学员：宋俊毅（学号 2025108600351）
- 挑战 ID：`ch-20260717031609-rnur5a`
- 实施日期：2026-11-21
- 上游项目：NousResearch/hermes-agent，实测版本 `Hermes Agent v0.19.0 (2026.7.20)`

## 一句话

在这个仓库里能看到：**Agent 是怎么装的、接的是谁、人格是谁写的、技能解决哪个真实踩过的坑、记忆落在哪个文件、定时任务为什么「登记了但不会自己跑」**——以及哪几件事没做成。

## 交付物（官方 6 件）

| # | 官方要求 | 本仓库文件 | 状态 |
|---|---|---|---|
| 1 | 安装记录 `姓名_C10H_安装记录.md` | `宋俊毅_C10H_安装记录.md` | ✅ 含 11 节，含 Level 自评与遗留问题清单 |
| 2 | 使用演示 `姓名_C10H_demo.mp4` 或截图 | `demo_c10h.sh` + `demo_c10h_output.txt` + `demo_c10h_dialog.txt` + `宋俊毅_C10H_demo_1/2/3.png` | ⚠️ 见下方「证据形态」 |
| 3 | 配置说明 `姓名_C10H_配置说明.md` | `宋俊毅_C10H_配置说明.md` | ✅ 6 节：LLM 选择 / provider 接线 / SOUL.md / 自定义技能 / 记忆 / 环境变量 |
| 4 | 技能文件 `姓名_C10H_自定义技能/` | `宋俊毅_C10H_自定义技能/cogseed-submit-preflight/SKILL.md` | ✅ 2,316 B，agentskills.io 标准 frontmatter |
| 5 | ⚡ AI 日志 `姓名_C10H_AI日志.md` | `宋俊毅_C10H_AI日志.md` | ✅ 6 轮，每轮含报错原文 |
| 6 | 拿来说明 `姓名_C10H_拿来说明.md` | `宋俊毅_C10H_拿来说明.md` | ✅ 拿了什么 / 做了什么 / 架构理解 / 没做什么 |
| 附 | AAR | `宋俊毅_C10H_AAR.md` | ✅ §二 专记「四件差点被写成成功的事」 |

## 证据形态（重要，先看这条再看图）

- 三张 PNG 是**真实命令输出的渲染图，不是屏幕截图**，图内页脚已标注来源文件。
- **安装当时的屏幕没有截到**，事后补不回来；替代物是可复跑的 `demo_c10h.sh` 与两次带时间戳的真实执行记录。
- `hermes tools` 需要交互终端（`Error: 'hermes tools' requires an interactive terminal.`），所以「工具数量」这一问没有可信数字，记录里写的是「未取到」，没有猜数。

## 真实环境

| 项 | 值 |
|---|---|
| 系统 | macOS／arm64 |
| Python | 3.12.14（wheel 要求 `>=3.11,<3.14`） |
| 安装方式 | `uv tool install --python 3.12 hermes-agent`（PyPI wheel 10,144,439 B，纯 Python） |
| 可执行 | `/Users/songjunyi/.local/bin/hermes` |
| Provider | `openai-api` → `http://127.0.0.1:11434/v1`（本机 ollama） |
| 模型 | `qwen3.5:4b`（4.0 GB）——**零成本、数据不出本机** |
| 人格 | `~/.hermes/SOUL.md` 1,477 B（默认版备份 `SOUL.md.default.bak` 513 B） |
| 记忆 | `~/.hermes/memories/USER.md` 111 B + `USER.md.lock` 0 B |

## 复现步骤

```bash
# 1. 安装（官方脚本 curl | bash 在本机被网络重置，改走 PyPI）
uv tool install --python 3.12 hermes-agent

# 2. 接本机 ollama：provider 名必须写 openai-api，Hermes 没有名为 ollama 的 provider
cat > ~/.hermes/config.yaml <<'EOF'
model:
  provider: openai-api
  default: qwen3.5:4b
EOF

cat > ~/.hermes/.env <<'EOF'
# 本机 ollama（OpenAI 兼容端点），零成本接入
OPENAI_API_KEY=ollama-local
OPENAI_BASE_URL=http://127.0.0.1:11434/v1
EOF

# 3. 取证：跑一遍，看真实状态
bash demo_c10h.sh
```

## 没做成的一半

| 项 | 状态 |
|---|---|
| Level 2 消息平台接入（Telegram） | 未做，需要 bot token |
| Level 2 自动技能创建 | 未触发 |
| Level 3 连续 3 天记忆 | 只有 1 天，天数不能编 |
| Level 3 双模型对比 | 本机只有一个模型 |
| Level 4 四条路径 | 未开始 |
| cron 自动触发 | **任务登记成功，但网关未启动，不会自动跑** |

自评：**Level 1 完成 + Level 3 中 SOUL.md 定制与自定义技能两项，不声称 Level 3 达成。**
