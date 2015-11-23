Foreach ($directory_path in (Get-Content C:\Users\aurimasr\Desktop\createfolders.txt))
	{
	if((Test-Path $directory_path) -eq 0) { New-Item -ItemType Directory -Force -Path $directory_path }
	}