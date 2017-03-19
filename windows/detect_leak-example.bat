@echo off

set iter_count=%1
set iter_timeout_sec=%2

set OANOCACHE=1
gflags /i memory_leak.exe +ust
REM gflags /i memory_leak.exe /tracedb 32

echo clean previous analisis
del /q memory_leak_init*.log
del /q memory_leak_work*.log
del /q memory_leak_compare*.log

echo Start program
start ..\Debug\memory_leak.exe

call :find_pid

echo Create initial snapshot
umdh -p:%pid% -f:memory_leak_init.log

echo Start creating memory snapshots
for /l %%m in (1,1,%iter_count%) do (
	
	timeout /T %iter_timeout_sec% /Nobreak
	
	echo Create working snapshot
	umdh -p:%pid% -f:memory_leak_work%%m.log
		
	echo Analyze snaphots %%m
	umdh -d memory_leak_init.log memory_leak_work%%m.log > memory_leak_compare%%m.log
)

gflags /i memory_leak.exe -ust

exit /b 0

:find_pid
for /f "tokens=2 delims= " %%i in ( 'tasklist ^| findstr memory_leak' ) DO ( 
	echo %%i	
	set pid=%%i )
exit /b 0

:wait_pid
:loop
tasklist | findstr %pid% >nul 2>&1
if errorlevel 1 (
  goto :end_wait
) else (
  echo memory_leak is still running
  timeout /T 5 /Nobreak
  goto :loop
)

:end_wait
timeout /T 1 /Nobreak
exit /b 0