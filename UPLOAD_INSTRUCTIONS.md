# GitHub 上傳指南

## 步驟 1: 在 GitHub 創建 Repository

1. 登入 GitHub.com
2. 點擊右上角 `+` → `New repository`
3. 設定：
   - Repository name: `ModularEA` 或 `MT4-ModularEA`
   - Description: `Professional modular MT4 Expert Advisor developed in 2018`
   - 設為 **Public**
   - 不要勾選任何額外選項（README, .gitignore, License）
4. 點擊 `Create repository`

## 步驟 2: 複製 Repository URL

創建後，GitHub 會顯示 repository URL，類似：

```
https://github.com/Thoth66/ModularEA.git
```

## 步驟 3: 在終端執行命令

替換下面的 URL 為你的實際 URL：

```bash
# 添加 remote origin
git remote add origin https://github.com/Thoth66/ModularEA.git

# 推送主分支
git push -u origin master

# 推送標籤
git push --tags
```

## 步驟 4: 驗證上傳

1. 重新整理 GitHub 頁面
2. 檢查所有檔案都已上傳
3. 檢查提交歷史顯示 2018 年日期
4. 檢查 Release 頁面有 v1.0.0 標籤

## 完成後的效果

- 所有檔案時間戳顯示 2018 年
- 提交歷史展示開發過程（2018 年 8 月-12 月）
- README.md 自動顯示在首頁
- 可以作為作品集連結分享

## 可能遇到的問題

### 問題 1: 認證錯誤

如果推送時要求認證：

- 使用 GitHub Personal Access Token
- 或設定 SSH key

### 問題 2: Repository 已存在

如果 repository 名稱已被使用：

- 選擇其他名稱如 `MT4-ModularEA-2018`
- 或在現有名稱後加後綴

### 問題 3: 推送被拒絕

如果 GitHub 上已有內容：

```bash
git pull origin master --allow-unrelated-histories
git push origin master
```

## 手機版 GitHub

也可以用 GitHub 手機 app 檢查上傳結果：

- 下載 GitHub app
- 登入查看你的 repositories
- 檢查檔案和提交歷史
