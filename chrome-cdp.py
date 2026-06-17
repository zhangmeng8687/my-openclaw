#!/usr/bin/env python3
"""Chrome CDP - Simple approach: reload, fill, submit"""
import subprocess
import json
import sys
import time

PAGE_ID = "3AEB029A7FAFDA16DBD529B59D6AD695"

def run_ps(script):
    result = subprocess.run(
        ["/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe", "-Command", script],
        capture_output=True, timeout=60
    )
    out = result.stdout.decode('utf-8', errors='replace').strip()
    return out

def cdp(js):
    """Simple CDP eval"""
    # Escape for PowerShell here-string
    ps = f'''
$uri = "ws://127.0.0.1:9222/devtools/page/{PAGE_ID}"
$ws = [System.Net.WebSockets.ClientWebSocket]::New()
$ct = [System.Threading.CancellationToken]::None
$ws.ConnectAsync([Uri]$uri, $ct).Wait() | Out-Null

$j = @"
{js}
"@

$payload = "{{`"id`":1,`"method`":`"Runtime.evaluate`",`"params`":{{`"expression`":`"$($j -replace '`"','\\`"')`",`"returnByValue`":true}}}}"
$msg = [System.Text.Encoding]::UTF8.GetBytes($payload)
$ws.SendAsync([ArraySegment[byte]]$msg, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $ct).Wait() | Out-Null

Start-Sleep -Milliseconds 2000

$buf = New-Object byte[] 65536
$r = ""
do {{
    $rec = $ws.ReceiveAsync([ArraySegment[byte]]$buf, $ct).Result
    $r += [System.Text.Encoding]::UTF8.GetString($buf, 0, $rec.Count)
}} while (-not $rec.EndOfMessage)

$ws.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "", $ct).Wait() | Out-Null
Write-Output $r
'''
    return run_ps(ps)

def cdp_nav(url):
    ps = f'''
$uri = "ws://127.0.0.1:9222/devtools/page/{PAGE_ID}"
$ws = [System.Net.WebSockets.ClientWebSocket]::New()
$ct = [System.Threading.CancellationToken]::None
$ws.ConnectAsync([Uri]$uri, $ct).Wait() | Out-Null
$payload = "{{`"id`":1,`"method`":`"Page.navigate`",`"params`":{{`"url`":`"{url}`"}}}}"
$msg = [System.Text.Encoding]::UTF8.GetBytes($payload)
$ws.SendAsync([ArraySegment[byte]]$msg, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $ct).Wait() | Out-Null
Start-Sleep -Milliseconds 1000
$buf = New-Object byte[] 4096
$r = ""
do {{
    $rec = $ws.ReceiveAsync([ArraySegment[byte]]$buf, $ct).Result
    $r += [System.Text.Encoding]::UTF8.GetString($buf, 0, $rec.Count)
}} while (-not $rec.EndOfMessage)
$ws.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "", $ct).Wait() | Out-Null
Write-Output $r
'''
    return run_ps(ps)

def pv(r):
    try:
        return json.loads(r).get("result",{}).get("result",{}).get("value","")
    except:
        return r

def main():
    # Reload the page first
    print("=== Reload page ===")
    cdp_nav("https://github.com/new")
    time.sleep(5)
    
    # Check page
    r = cdp("document.title")
    print(f"Title: {pv(r)}")
    
    # Use Input.insertText via separate CDP call - but we need to use a different approach
    # Let's try setting value and dispatching React's synthetic event
    print("\n=== Fill form ===")
    r = cdp(r"""
        (function() {
            var input = document.getElementById('repository-name-input');
            if (!input) return 'no input found';
            
            // Clear and set value using React's internal fiber
            var key = Object.keys(input).find(k => k.startsWith('__reactFiber$') || k.startsWith('__reactInternalInstance$'));
            var props = Object.keys(input).find(k => k.startsWith('__reactProps$'));
            
            if (props) {
                var reactProps = input[props];
                if (reactProps && reactProps.onChange) {
                    // Create a synthetic event
                    var syntheticEvent = {
                        target: input,
                        currentTarget: input,
                        type: 'change',
                        preventDefault: function(){},
                        stopPropagation: function(){},
                        nativeEvent: new Event('change'),
                        bubbles: true
                    };
                    input.value = 'my-openclaw';
                    reactProps.onChange(syntheticEvent);
                    return 'Set via React props: ' + input.value;
                }
            }
            
            // Fallback
            var setter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set;
            setter.call(input, 'my-openclaw');
            input.dispatchEvent(new Event('input', {bubbles: true}));
            input.dispatchEvent(new Event('change', {bubbles: true}));
            return 'Set via setter: ' + input.value;
        })()
    """)
    print(f"Result: {pv(r)}")
    
    time.sleep(2)
    
    # Check validation
    r = cdp("document.body.innerText.includes('Name cannot be blank') ? 'STILL BLANK' : 'OK'")
    print(f"Validation: {pv(r)}")
    
    # Click create
    print("\n=== Click Create ===")
    r = cdp(r"""
        (function() {
            var btn = Array.from(document.querySelectorAll('button')).find(b => b.textContent.trim() === 'Create repository');
            if (!btn) return 'button not found';
            btn.removeAttribute('disabled');
            btn.click();
            return 'clicked, disabled=' + btn.disabled;
        })()
    """)
    print(f"Result: {pv(r)}")
    
    time.sleep(8)
    
    # Verify
    r = cdp("document.title + ' ||| ' + location.href")
    print(f"Final: {pv(r)}")

if __name__ == "__main__":
    main()
