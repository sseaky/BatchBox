@rem 通过n2n访问远程网络

@echo off
setlocal enabledelayedexpansion

set n2n_local_ip=
set n2n_prefix=100.72.9.
set n2n_gateway=100.72.9.22
set network_remote=192.168.0.0/16

echo.

call :check_ip_prefix %n2n_prefix%
if %check_ip_prefix_ret%=="" (echo n2n 网络不存在 && goto:eof)
call:add_n2_route
rem call:delete_n2_route
pause
goto:eof


:add_n2_route
echo -- 开始添加n2n路由 --
for %%n in (%network_remote%) do (
	set netmask=255.255.255.0
	for /f "tokens=1,2 delims=/" %%i in ('echo %%n') do (
		call :convert_netmask %%j
		set cmd=route add %%i mask !netmask! %n2n_gateway%
		echo !cmd!
		!cmd!
	)
)
echo.
echo.
goto:eof


:delete_n2_route
echo -- 开始删除n2n路由 --
for %%n in (%network_remote%) do (
	set netmask=255.255.255.0
	for /f "tokens=1,2 delims=/" %%i in ('echo %%n') do (
		call :convert_netmask %%j
		set cmd=route delete %%i mask !netmask! %n2n_gateway%
		echo !cmd!
		!cmd!
	)
)
echo.
echo.
goto:eof


:check_ip_prefix
echo -- 检查是否存在网卡 %1  --
set check_ip_prefix_ret=""
for /f "tokens=1,2,3 delims=:" %%i in ('ipconfig ^| findstr %1') do (
	echo %%j
	set check_ip_prefix_ret=%%j
)
if !check_ip_prefix_ret!=="" (echo %1 网卡不存在) else (echo 存在地址 !check_ip_prefix_ret!)
echo.
echo.
goto:eof


:convert_netmask
set netmask=255.255.255.0
if "%1"=="8" (set netmask=255.0.0.0)
if "%1"=="21" (set netmask=255.255.248.0)
if "%1"=="22" (set netmask=255.255.252.0)
if "%1"=="23" (set netmask=255.255.254.0)
if "%1"=="24" (set netmask=255.255.255.0)
goto:eof

:show_command
	echo %*
	%*
goto:eof
