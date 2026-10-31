# 用 GitHub 生成 IPA（不需要 Mac）

整个流程大约 10 分钟。最后得到的是**未签名 IPA**，需要再用 Sideloadly 用你的 Apple ID 签名，才能装进 iPhone。

## 1. 新建 GitHub 仓库

1. 登录 GitHub，点右上角 **+ → New repository**。
2. 名称随意，例如 `gotham-pocket`。
3. 选择 **Private** 或 **Public** 都可以。
4. **不要**勾选 “Add a README file” 或 “Add .gitignore”，保持空仓库。
5. 点 **Create repository**。

## 2. 上传文件

1. 解压 `GothamPocket-github.zip`。
2. 打开解压后的文件夹，按 `Ctrl+A` 全选里面的**内容**：
   - `.github`
   - `GothamPocket`
   - `Support`
   - `scripts`
   - `preview`
   - `screenshots`
   - `project.yml`
   - `README.md`
   - `.gitignore`
3. 在新仓库页面点击 **uploading an existing file**。
4. 把刚才选中的文件和文件夹整体拖进上传区域。
5. 等文件列表加载完，点 **Commit changes**。

> `.github` 是带点的文件夹。如果网页上传时漏掉了它，可以在仓库里手动创建：
> **Add file → Create new file**，文件名填 `.github/workflows/build-ipa.yml`，
> 然后用记事本打开解压目录里的 `.github/workflows/build-ipa.yml`，全选复制粘贴进去。

检查仓库根目录应该直接看到 `project.yml`，而不是先看到一个 `GothamPocket` 文件夹。

## 3. 运行构建

1. 打开仓库顶部的 **Actions**。
2. 如果提示启用工作流，点 **I understand my workflows, go ahead and enable them**。
3. 左侧选择 **Build unsigned IPA**。
4. 右侧点 **Run workflow → Run workflow**。
5. 等待约 5–10 分钟，状态变成绿色勾。
6. 点进这次运行，页面底部 **Artifacts** 下载 `GothamPocket-unsigned-ipa`。
7. 解压下载的 artifact，得到 `GothamPocket-1.0-unsigned.ipa`。

## 4. 安装到 iPhone

前置条件：Windows 电脑、iPhone 数据线、你的 Apple ID。

1. 先安装 **iTunes**（微软商店版）或 **Apple Devices**，确保电脑能识别 iPhone。
2. 下载并安装 [Sideloadly](https://sideloadly.io/)。
3. iPhone 连接电脑，解锁并点“信任此电脑”。
4. 打开 Sideloadly，把 `.ipa` 拖进去。
5. 在 `Apple ID` 处填写你的 Apple ID。
6. 点 **Start**，输入 Apple ID 密码。若开了双重认证，按提示使用专用密码。
7. 安装完成后，在 iPhone 上打开：
   **设置 → 通用 → VPN 与设备管理 → 开发者 App**，信任你的 Apple ID。
8. 回到桌面，打开“哥谭口袋”。

## 常见问题

### 安装时提示 Bundle ID 冲突

在 Sideloadly 里勾选/展开高级选项，把 Bundle ID 改成唯一的，例如：

```text
com.yourname.gothampocket
```

然后重新 Start。

### 免费 Apple ID 能用多久

7 天。到期后 App 打不开，重新用 Sideloadly 安装一次即可，存档通常会被覆盖，请以实际提示为准。

### Actions 构建失败

把失败的 job 日志里第一段红色报错发给我。常见原因是：
- `project.yml` 没有在仓库根目录；
- `.github/workflows/build-ipa.yml` 没有上传；
- XcodeGen 安装失败（重新运行一次通常就好）。

### 这个 IPA 能直接发给别人吗

不能。它是未签名的，必须用每个人自己的 Apple ID 重新签名；并且免费账号安装的 App 只有 7 天有效期。
