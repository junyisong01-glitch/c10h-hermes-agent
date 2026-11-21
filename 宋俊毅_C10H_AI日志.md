# 宋俊毅_C10H_AI日志

- 姓名：宋俊毅　学号：2025108600351
- 挑战：C10H 安装并驾驭 Hermes Agent
- 日期：2026-11-21
- 分工：我出题、我判卷、我按确认键；AI 动手写命令、读源码、生成文档
- 说明：本日志只记真实发生过的回合。凡是 AI 说「已成功」但我没验证的，都不写进来；凡是 AI 说错的，都留着原文。

---

## 第 1 轮｜先问「能不能装」

**我的提问**：本机是 macOS，非技术背景，想在本地装 Hermes Agent 并真的跑起来，不要只写文档。先告诉我安装路径有哪几条，各自的风险。

**AI 给的**：三条路径——① `git clone` 源码安装；② `pip install hermes-agent`；③ `uv tool install --python 3.12 hermes-agent`（走 PyPI wheel）。并说明 ① 需要编译依赖、网络最重，③ 是纯 Python wheel，无编译步骤。

**我做的判断**：先试 ③。理由是它隔离环境、可整体删除、不污染系统 Python。

**结果**：装上，`hermes --version` → `Hermes Agent v0.19.0 (2026.7.20)`，Python 3.12.14。

**这一轮 AI 做对的地方**：先给路径对比再给建议，没有直接甩一条命令。

---

## 第 2 轮｜网络失败，AI 第一次「猜原因」

**现象**：路径 ① 的 `git clone` 失败，exit 1，三次重试都失败，stderr 没抓到；同时 `curl` 访问 `raw.githubusercontent.com` 返回：

```
curl: (35) Recv failure: Connection reset by peer
```

另外发现 macOS 没有 GNU `timeout`：

```
timeout: command not found
```

**AI 第一反应**：说「可能是网络代理问题，建议开代理再试」。

**我判卷**：这是猜测，不是结论。`Connection reset by peer` 只能说明连接被重置，不能推出「需要代理」。而且它没有给出「怎么验证这个猜测」的下一步。

**修正后的做法**：不去修路径 ①，因为 ③ 已经成功。把这条失败原样记进安装记录的排错一节，写成「现象 + 原始报错 + 未解决」，不写成「已解决」。

**这一轮的教训**：AI 遇到网络报错时倾向于给一个听起来合理的原因。这类原因如果指不到证据，只能当待验证假设，不能当结论写进交付物。

---

## 第 3 轮｜模型接不上的真因

**我的提问**：装好了，但 `hermes -z --provider ollama -m qwen3.5:4b "你好"` 报错，帮我查清楚为什么。

**原始报错（原样）**：

```
hermes -z: agent failed: No LLM provider configured. Run 'hermes model' to select a provider, or run 'hermes setup' for first-time configuration.
```

**AI 第一次给出的诊断（错的）**：报错说了「No LLM provider configured」，那就跑 `hermes setup` 走一遍向导配上。

**我为什么不信**：我明明在命令行里指定了 `--provider ollama`。如果真的是「没配」，指定了应该生效；既然不生效，说明问题在「`ollama` 这个词在 Hermes 里指的不是我本机的东西」。

**要求 AI 去读源码**，结果：

- `agent/models_dev.py`：内置 provider 列表里只有 `ollama-cloud`，**没有指向本机 11434 端口的 ollama**。
- `hermes_cli/runtime_provider.py` 约 861 行附近是 `custom:` 端点解析：`providers:` / `custom_providers:` 条目可用 `api`、`url` 或 `base_url`；**裸写 `custom` 会回落到 OpenRouter 默认 URL**。

**结论**：Hermes 语境里的「ollama」是云端形态。本机 ollama 提供 OpenAI 兼容端点，走 `openai-api` + `OPENAI_BASE_URL=http://127.0.0.1:11434/v1` 才对。

**这一轮的价值**：报错文本在骗人。「No LLM provider configured」的真因不是「没配置」，是「名字对不上」。如果照着报错去跑向导，会在里面绕很久，最后还是不通。

**我记下来的一条规则**：报错说的原因，是程序以为的原因；真因要去源码里找「这个名字被解析成什么」。

---

## 第 4 轮｜人格改了，但怎么证明改了

**我的提问**：出厂 `SOUL.md` 是英文通用助手人格，不适合交作业。我要改成「先给结论」「报错原样引用」「不替我编内容」。改完怎么向评委证明它真生效，而不是我写了一堆文字放着？

**AI 给的办法**：别只看文件，去问它两个问题——一个问身份（看人格是否写进去），一个问它最不擅长的（看行为准则是否进了系统提示）。

**实际执行**：

```
$ hermes -z "你是谁？"
我是小赫，宋俊毅（2025108600351）的专属助理。

$ hermes -z "你最不擅长什么？"
我最不擅长的是：编造你没验证过的信息。
```

第二句是关键：`SOUL.md` 里我写的是「不替我编内容」，它把这条转成了「我最不擅长编造」，说明这段文字确实作为行为约束进了上下文，不只是被我存了一份。

**这一轮 AI 做得好的地方**：没有停在「改完了」，主动给了「怎么证明」的方法。

---

## 第 5 轮｜记忆到底存哪（AI 猜错了两次）

**AI 第一次的说法**：内置记忆在 `~/.hermes/MEMORY.md` 和 `~/.hermes/USER.md`。

**验证**：两个文件都不存在。

```
ls: /Users/songjunyi/.hermes/MEMORY.md: No such file or directory
ls: /Users/songjunyi/.hermes/USER.md: No such file or directory
```

**AI 第二次的说法**：那试 `hermes memory add "..."`。

**验证**：`hermes memory` 根本没有 `add`：

```
argument memory_command: invalid choice: 'add' (choose from setup, status, off, reset)
```

**真实情况**（查出来的）：内置记忆在 `/Users/songjunyi/.hermes/memories/USER.md`（111 字节），`hermes memory status` 显示 `Built-in: always active` / `Provider: (none — built-in only)`——没装外部插件，用内置。

**这一轮我的处理**：AI 连错两次，但每次我都用一条能立刻打出结果的前提去验它（文件在不在、子命令存不存在），所以每次只花一条命令就归位。**这是我在这轮学到最实用的一条：判断 AI 的说法，找一个 5 秒内能证伪的动作，而不是再问它一次「你确定吗」。**

---

## 第 6 轮｜演示脚本里，AI 改了我的原始输出

**我的提问**：写一个脚本，一条命令跑完，把「配置链路 / 技能被认到 / 记忆落盘 / cron 状态」四块证据一次打出来。不要让我一条条贴。

**AI 第一版给我的脚本里，有两处不是原始输出：**

1. 排错部分的输出里出现了两次 `FIRECRAWL_GATEWAY_URL`（重复行）。真实的 `hermes doctor` 不会重复打印同一项——这是 AI 在拼输出时重复了。
2. 脚本注释里写「doctor 报了 25 项标记」，而真实输出是 `Found 3 issue(s)`。

**我是怎么发现的**：让 AI 把脚本跑一遍，把输出存成 `demo_c10h_output.txt`，然后我自己数——`Found 3 issue(s)` 和我看到的「25 项」对不上。

**处理**：不留这两处。脚本改成**只回显命令的真实输出，不写任何自己的话**，凡是需要解释的地方一律留空由我在文档里说。

**这一轮的意义**：这是 AI 最危险的一种错——它没有编造一个不存在的世界，它编造了「我的命令输出了什么」。演示脚本一旦掺了这个，整个 demo 的证明力就是零，因为它证明的是 AI 的转述，不是我机器上的真实状态。

---

## 第 7 轮｜`hermes tools` 打不开

**现象**：

```
Error: 'hermes tools' requires an interactive terminal.
It cannot be run through a pipe or non-interactive subprocess.
```

**AI 的反应**：这次没有猜原因，直接说「这是命令的设计限制，必须真终端」，并改成用 `hermes -z`（单次问答模式）来做验证。

**我的判断**：接受。这句报错本身写得很清楚，不需要再查源码。

**记下来的一条**：不是每条报错都要往下挖。报错已经把限制说清、且这条限制不影响目标时，绕开就行。判断标准是「挖下去能不能改变结论」，不能就别挖。

---

## 第 8 轮｜cron：把「配置成功」和「能自动跑」分开

**我的提问**：建一个每天早上的提醒任务，证明 Hermes 能被排程。

**AI 建完后的说法（第一版）**：「定时任务已创建成功，每天 9 点提醒。」

**我要求它把 `hermes cron list` 的原始输出贴给我**，于是看到了两行它没提的东西：

```
⚠  Gateway is not running — jobs won't fire automatically.
   Start it with: hermes gateway install
```

再查执行历史：

```
$ hermes cron runs 04646455c72f
No cron execution attempts recorded.
```

**我的判卷**：「已创建成功」这句话只对一半。任务确实建成了（`[active]`、有 `Next run: 2026-11-22T09:00:00+08:00`），但网关没起，不会自动触发，而且从未触发过。

**改法**：交付物里写「配置成功 ≠ 自动化生效」，把 `[active]` 和 `No cron execution attempts recorded` 两行并排放。要不要跑 `hermes gateway install` 起常驻服务，我留作未决项——那会改系统状态（装常驻进程），不擅自做。

**这一轮的价值**：AI 汇报时天然倾向于报「完成」的那一半。挑出「没完成的那一半」的方法不是追问，是**要求贴原始输出**。原始输出里，坏消息和好消息一样显眼。

---

## 第 9 轮｜自定义技能：怎么证明不是自娱自乐

**我的提问**：我要加一个自己的技能，怎么证明 Hermes 真的认到它了，而不是我建了个文件放着？

**AI 给的验证**：

```
$ hermes skills list
cogseed-submit-preflight | local | local | enabled
0 hub-installed, 0 builtin, 1 local — 1 enabled, 0 disabled
```

**为什么这三列是关键**：`local` 说明来源是我自己的目录（不是内置清单里本来就有）；`enabled` 说明它进上下文；底部那行 `1 local — 1 enabled` 说明计数也对得上，不是单独一个文件被误列。

**我选的技能**：`cogseed-submit-preflight`——提交前逐条核对交付物名称、必填字段（尤其平台硬校验的「项目简介」）。选它的理由是这个坑我踩过三次，同一个坑踩三次说明缺的是流程不是记性。

---

## 第 10 轮｜一次 Bash 工具报错（AI 自己踩的）

AI 想批量检查几个文件，写了带变量的路径：

```
cat "$p"
```

工具报：

```
E_BASH_DYNAMIC_PATH_UNSUPPORTED: bash cat target "$p" uses an unresolved variable...
```

**处理**：改成写死完整路径，逐个 `ls -l`。

**这一轮说明了什么**：这不是 Hermes 的问题，是我这边执行环境的约束。记进来的原因是它影响了排查节奏——AI 连续两次试着「聪明地循环」，宁可换成笨办法（一条条写死）更快。**在环境约束不明的地方，笨办法比聪明办法可靠。**

---

## 这 10 轮下来的分工判断

**我做不了的**：读源码定位 `runtime_provider.py` 里 `custom:` 的回落逻辑、写 demo 脚本、判断哪个安装路径最省事。这些是 AI 的活，它做得比我快 100 倍。

**AI 做不了的**：
1. 判断它的说法成不成立。它说「记忆在 MEMORY.md」，是我去 `ls` 才发现没有。
2. 决定「这个坑值不值得挖」。第 7 轮的 `hermes tools` 该绕开，第 3 轮的 provider 必须挖到底——这个取舍它做不了。
3. 忍住不美化。「配置成功」「已创建成功」这类话，它每次都会多说半句。
4. 承认一半。cron 那条它第一版只说好的那一半。

**所以这轮真正的做法是固定的三步**：AI 给说法 → 我找一个 5 秒能证伪的动作去验 → 验完再决定写进交付物的是哪一半。第 5 轮的两次猜错、第 6 轮的假输出、第 8 轮只说一半，全部是靠这个动作抓到的。

