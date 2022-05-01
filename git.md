## 删除本地有但在远程库已经不存在的分支
git remote prune origin 

## .ignore处理
删除本地缓存 再git push删除远程对应文件
git rm -r --cached build


### git强制覆盖本地命令
```
git fetch --all
git reset --hard origin/master
git pull
```