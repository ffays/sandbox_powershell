ls | ft mode,@{n='LastWriteTime';e={$_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")};a="right"},@{n='Length';e={$_.length};a="right"},name,@{n='Target';e={$_.Target}}
