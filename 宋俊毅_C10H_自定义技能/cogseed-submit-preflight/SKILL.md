---
name: cogseed-submit-preflight
description: 在 CogSeed/EduSeed 平台提交挑战作业前跑一遍预检。核项目简介、公开仓库、交付物逐条、提交身份学号、task_id 轮询、报错原文六项。当用户说"提交/交作业/重交/为什么被打回"时使用。
category: workflow
---

# CogSeed 提交前预检

## 什么时候用
用户准备提交、重交某一关，或者问"为什么被拒收"的时候。

## 为什么需要它（真实踩坑，三次同一原因）
同一个坑踩了三次，每次都挂着学号、都要重提：
- C4-D：缺「项目简介」被平台拒收
- C7：同因拒收，补一句简介后重交成功（sub-20261120172828-18cec719）
- C3（2026-11-21）：同因拒收，任务 task-20261121064259-17a71000 直接 failed，报错原文「缺少必填项：项目简介」

## 六项必查（顺序不要换）
1. **项目简介必写**：一句事实性说明——谁、什么时候、做了什么、仓里有什么。不写评价、不写形容词。本地预检不查这项，服务端会拒。
2. **仓库必须公开**：isPublic: true，且仓库真的是 public，否则导师打不开。
3. **交付物逐条对得上**：按关卡 requiredDeliverables 的原字符串核，带星号的是硬性项，少一个就是「缺少交付物」。
4. **身份用学号**：提交身份必须是本人学号，不要用用户名。
5. **提交后看 task_id，不看列表**：submit-project 拿 task_id → get-task 轮询到 completed 并出现 submissionId 才算成功。仪表盘和提交列表有延迟，只统计已 checked 的记录，别拿它的数字反推"提交失败了"。
6. **失败要读报错原文**：把 error 字符串一字不改抄进日志，改写成"格式不对"就永远查不出真因。

## 命令层坑（同一天踩的，一并记）
- 调脚本用 runtime，不带 .js；写 runtime.js 报 skill script not found。
- get-task 的参数是 taskId（驼峰），写 task_id 报 INPUT_MISSING。
- 查自己的提交用 list-my-submissions，写 get-my-submissions 报 UNKNOWN_COMMAND。

## 引文规则
引别人说的话，括号注释、口语词、错别字、强调词全部照留。节引后省掉两个字的后果是评委拿引号和截图对不上。宁可整句不引，也不许节引后省略。
