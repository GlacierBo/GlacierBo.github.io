@echo off

:: 获取当前脚本的路径
cd /d %~dp0


git pull

@echo finish,

SET daoTime=5
:dao
set /a daoTime=daoTime-1
ping -n 2 -w 500 127.1>nul
cls
echo push finish, quit in: %daoTime% s
if %daoTime%==0 (exit) else (goto dao)


