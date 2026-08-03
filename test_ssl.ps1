try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $req = [Net.HttpWebRequest]::Create('https://115.238.94.194')
    $req.Timeout = 5000
    $resp = $req.GetResponse()
    Write-Host 'TLS1.2: OK'
    $resp.Close()
} catch {
    Write-Host 'TLS1.2 失败:' $_.Exception.Message
}

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls
    $req = [Net.HttpWebRequest]::Create('https://115.238.94.194')
    $req.Timeout = 5000
    $resp = $req.GetResponse()
    Write-Host 'TLS1.0: OK'
    $resp.Close()
} catch {
    Write-Host 'TLS1.0 失败:' $_.Exception.Message
}
