@rem 登陆深信服SSL VPN后会通过添加明细路由的方式，把所有网卡的流量都引到vpn上，包括其他vpn，vmware等流量，本脚本可以删除这些路由。
@rem 本脚本可自动发现本地网卡地址，不再需要手工指定本地网段

@echo off
setlocal enabledelayedexpansion

set SXF_PREFIX=2.0.2.

echo.


call:check_ip_prefix %SXF_PREFIX%
if %check_ip_prefix_ret%=="" (echo SXF 网络不存在 && pause && goto:eof)
call:find_ipaddress
for /f "tokens=1,2,3,4,5,6 delims=:" %%i in ('!ips!') do (
	set ip=%%j
	set ip1=!ip: =!
	rem 取IP前3位
	call:find_char_in_str !ip1! . 3
	rem echo !find_char_in_str_ret_idx! 
	set ip2=!find_char_in_str_ret_str!.
	if !SXF_PREFIX! NEQ !ip2! (
		call:delete_vpn_route !find_char_in_str_ret_str!
		)
	rem !cmd!
	)
pause
goto:eof



rem 找第3个.位置 call:find_char_in_str 192.168.2.1 . 3
:find_char_in_str
set find_char_in_str_ret_idx=-1
set str=%1
set str1=
set char=%2
set idx=1
set repeat_cur=0
set repeat=%3
if "%repeat%" == "" (set repeat=1)
:loop2
if "!str!" NEQ "" (
	if "!str:~0,1!" EQU "%char%" (
		set /a repeat_cur+=1
		if !repeat_cur! EQU %repeat% (
			set find_char_in_str_ret_idx=!idx!
			set find_char_in_str_ret_str=!str1!
			rem echo !str1!
			goto:eof
		)
	)
	set /a idx+=1
	set str1=!str1!!str:~0,1!
	set str=!str:~1!
	goto loop2
)
goto:eof


:find_ipaddress
echo -- 查找本地网卡地址 --
set ips=ipconfig ^| findstr /R /B /C:" *IPv4 地址"
goto:eof


rem 删除vpn相关路由
:delete_vpn_route
set network_local=%1
echo -- 开始删除 %1 相关的vpn强制路由 --
for %%p in (%network_local%) do (
	set patten="^[ ]*%%p"
	echo 查找 %%p 路由，模式!patten!
	set cmd1=route print ^| findstr /R /B /C:!patten! ^| findstr /v "在链路上"
	rem echo !cmd1!
	for /f "tokens=1,2,3" %%i in ('!cmd1!') do (
		set cmd=route delete %%i mask %%j %%k
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
