param (
    [string]$Domain,
    [string]$DnsServer,
    [string]$CsvFile
)

function Show-Usage {
    Write-Host "Usage: .\script.ps1 -Domain <domain> -DnsServer <dns_server> -CsvFile <csv_file>"
    Write-Host ""
    Write-Host "Arguments:"
    Write-Host "  -Domain       The domain name for which the DNS records are being updated."
    Write-Host "  -DnsServer    The DNS server where the updates will be sent."
    Write-Host "  -CsvFile      The path to the CSV file containing the hostname and IP address pairs."
    Write-Host ""
    Write-Host "CSV File Format:"
    Write-Host "  The CSV file should contain lines in the following format:"
    Write-Host "  hostname,ip_address"
    Write-Host ""
    Write-Host "Example CSV File:"
    Write-Host "  serverA123,192.168.10.2"
    Write-Host "  serverB456,192.168.10.3"
    Write-Host ""
    Write-Host "Example Usage:"
    Write-Host "  .\script.ps1 -Domain web.com -DnsServer dns10001 -CsvFile host.csv"
    exit 1
}

if ($PsCmdlet.MyInvocation.BoundParameters.Count -ne 3) {
    Show-Usage
}

function Process-Record {
    param (
        [string]$Host,
        [string]$IP
    )

    # Generate the dnscmd command
    $dnscmdCommand = "dnscmd $DnsServer /RecordAdd $Domain $Host /createPTR A $IP"

    # Execute the dnscmd command
    Write-Host "Executing: $dnscmdCommand"
    Start-Process -FilePath "dnscmd" -ArgumentList "/RecordAdd $Domain $Host /createPTR A $IP" -NoNewWindow -Wait
}

# Read the CSV file and process each line
Import-Csv -Path $CsvFile -Header Host,IP | ForEach-Object {
    Process-Record -Host $_.Host -IP $_.IP
}
