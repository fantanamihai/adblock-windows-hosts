$tmpdir = "C:\Temp"
$hostsFilename="hosts"
$tmphostsFile = "$tmpdir\$hostsFilename"

$websites = @(
	"http://winhelp2002.mvps.org/hosts.txt";
	"http://someonewhocares.org/hosts/zero/hosts";
	"http://www.hostsfile.org/Downloads/hosts.txt";
	"http://adblock.gjtech.net/?format=hostfile";
	"http://pgl.yoyo.org/as/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext";
)

New-Item -Path "$tmpdir" -Force -ItemType directory

echo "Retrieve hosts files"
$client = new-object System.Net.WebClient
for($i = 0; $i -lt $websites.Count; $i++ ) {
	$tmpWebHostsFile = "$tmpdir\$hostsFilename$i.web"
	try {
		$client.DownloadFile($websites[$i], "$tmpWebHostsFile")
		echo $websites[$i]	'[OK]'
	} catch [System.Exception] {
		echo $websites[$i]	'[FAIL]'
		$_.Exception | format-list -force
#		return
	}
}

echo "Combine websites files, filter, sort, eliminate duplicates, write hosts file"
Get-ChildItem -LiteralPath "$tmpdir" -filter "$hostsFilename*.web" | % { Get-Content "$tmpdir\$_" | Select-String -Pattern '^(127|0)\..+' | Foreach-Object { $_ -replace '^[0127]+\.0\.0\.[01]\s+([^\s]+).*','127.0.0.1 $1' } } | sort | get-unique | out-file -Encoding ascii "$env:SystemRoot\System32\drivers\etc\hosts"

$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")