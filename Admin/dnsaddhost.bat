@echo off
setlocal enabledelayedexpansion

:: Function to display usage
:usage
echo Usage: script.bat ^<domain^> ^<dns_server^> ^<csv_file^>
echo.
echo Arguments:
echo   ^<domain^>       The domain name for which the DNS records are being updated.
echo   ^<dns_server^>   The DNS server where the updates will be sent.
echo   ^<csv_file^>     The path to the CSV file containing the hostname and IP address pairs.
echo.
echo CSV File Format:
echo   The CSV file should contain lines in the following format:
echo   hostname,ip_address
echo.
echo Example CSV File:
echo   serverA123,192.168.10.2
echo   serverB456,192.168.10.3
echo.
echo Example Usage:
echo   script.bat web.com dns10001 host.csv
exit /b 1

:: Check for the correct number of arguments
if "%~3"=="" (
    call :usage
)

:: Variables
set "Domain=%~1"
set "DnsServer=%~2"
set "CsvFile=%~3"

:: Check if the CSV file exists
if not exist "%CsvFile%" (
    echo Error: CSV file "%CsvFile%" does not exist.
    exit /b 1
)

:: Process each record in the CSV file
for /f "tokens=1,2 delims=," %%A in ('type "%CsvFile%"') do (
    set "Host=%%A"
    set "IP=%%B"

    :: Trim leading and trailing spaces
    set "Host=!Host: =!"
    set "IP=!IP: =!"

    :: Generate and execute the dnscmd command
    set "dnscmdCommand=C:\Windows\System32\dnscmd.exe %DnsServer% /RecordAdd %Domain% !Host! /createPTR A !IP!"
    echo Executing: !dnscmdCommand!
    !dnscmdCommand! >> result.log 2>&1
)

endlocal
