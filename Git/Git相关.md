
## M1安装更新命令
sudo arch -x86_64 gem install ffi
arch -x86_64 pod install
arch -x86_64 pod repo update 快速更新
arch -x86_64 pod update Moya


## 删除本地有但在远程库已经不存在的分支
git remote prune origin 

## .ignore处理
删除本地缓存 再git push删除远程对应文件
git rm -r --cached build