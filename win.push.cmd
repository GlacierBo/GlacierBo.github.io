@echo off


:: 获取当前脚本的路径
cd /d %~dp0

:: 自动提交
git init 
git add . 
git commit -m "auto push :%date:~0,10%,%time:~0,8%" 
git push origin master
@echo push finish ...


:: 定时关闭 windows 窗口
SET daoTime=5
:dao
set /a daoTime=daoTime-1
ping -n 2 -w 500 127.1>nul
cls
echo will exit: %daoTime% s
if %daoTime%==0 (exit) else (goto dao)