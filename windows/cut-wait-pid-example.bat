@echo off

set OANOCACHE=1
gflags /i memory_leak.exe +ust
REM gflags /i memory_leak.exe /tracedb 32

del /q memory_leak_init.log
del /q memory_leak_work.log
del /q memory_leak_compare.log

echo Start program for initial log
start ..\Debug\memory_leak.exe

call :find_pid
umdh -pn:memory_leak.exe -f:memory_leak_init.log

call :wait_pid

echo Start program to exemine memory leaks log
start ..\Debug\memory_leak.exe

call :find_pid
umdh -pn:memory_leak.exe -f:memory_leak_work.log

call :wait_pid

echo Compare to state
umdh -d memory_leak_init.log memory_leak_work.log > memory_leak_compare.log

REM gflags /i memory_leak.exe -ust

type memory_leak_compare.log

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