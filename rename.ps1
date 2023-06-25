# 定义路径和变量
$filepath = $args[1] #aria2 调用或者传入
$filename = Split-Path $filepath -Leaf   # 获取文件名
$directory = Split-Path $filepath -Parent  # 获取文件所在的目录
$configpath = "D:\ariaConfig" #配置文件和控制台文件的地址
$mediapath = "D:\result" #媒体库位置，会在这个文件夹下面添加rename中对应的目录
$isOk = $false  # 初始化为假

# 定义函数以写入 console.txt
function Write-Console {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"  # 获取当前日期和时间
    Add-Content "$configpath\console.txt" "$($timestamp)：$($args[0])"  # 将内容添加到 console.txt
}

# 将初始数据写入 console.txt
Write-Console "-------------------"
Write-Console "$args"

# 读取 rename.txt 文件
$lines = Get-Content "$configpath\rename.txt" -Encoding UTF8

$regex = '^' + $directory + '/([^/]+/){2,}[^/]+\.(mp3|mp4|mkv)$'

# 如果文件路径匹配正则表达式
if ($filepath -match $regex) {
    Write-Console "：种子路径过深，不予处理"
    Write-Output "true"
    Exit
}

# 只处理文件，不处理目录
if (!(Test-Path -LiteralPath $filepath -PathType Leaf)) {
    Write-Console "没有找到对应文件，跳过"
    Exit
}

Write-Console "开始处理 $filename 文件夹为 $directory"

# 提取集数
# 先查找[02]这种至少两位数的纯数字 举例： [愛戀字幕社][4月新番][百合是我的工作！][Watashi no Yuri wa Oshigoto desu!][09][720P][MP4][BIG5][繁中] 提取09
if ($filename -match "\[([0-9]{2,})[vV]?\w*\]") { 
    $episode = $Matches[1]
}

# 再查找[02v1]这种带版本号的数字 举例：【悠哈璃羽字幕社】[天国大魔境_Tengoku Daimakyou][01v2][x264 1080p][CHS] 提取01
elseif ($filename -match "\[([0-9]+)[vV]?\w*\]") { 
    $episode = $Matches[1]
}

# 再查找[02xxxx]这种括号内带杂七杂八内容的数字 [4月新番][百合是我的工作！][Watashi no Yuri wa Oshigoto desu!][09] 比如这种就会把 4 提取出来
elseif ($filename -match "\[([0-9]+)\]") {
    $episode = $Matches[1]
}

# 再查找 02 这种数字 举例：[LoliHouse] 邻人似银河  Otonari ni Ginga - 12 [WebRip 1080p HEVC-10bit AAC][简繁内封字幕][END]
elseif ($filename -match "([0-9]+)") {
    $episode = $Matches[1]
}
else {
    Write-Console "未找到集数，跳过"
    Exit
} 

Write-Console "分辨为第${episode}集，开始下一步"

# 读取 rename.txt 中的数据
foreach ($line in $lines) {
    $data = $line -split ';'  # 使用 ';' 分隔数据
    $name = $data[0]
    $binder = $data[1]
    $s = $data[2]
    # 如果文件名包含 name
    if ($filename.Contains($name)) {
        Write-Console "$name 被匹配上"
        if ($s) {
            $binder = "$binder\S$s"
            Write-Console "S存在，路径 $binder"
        }
        else {
            $s = '01'
        }
        # 重命名文件
        $new_filename = "S${s}E${episode} - $filename"
        Rename-Item -LiteralPath $filepath -NewName "$directory\$new_filename"
        Write-Console "重命名为 $new_filename"
        # 创建目标目录并移动文件到该目录
        $target_dir = "$mediapath\$binder"
        if (!(Test-Path -LiteralPath $target_dir)) {
            New-Item -ItemType Directory -Force -Path $target_dir
            Write-Console "新建文件夹 $binder"
        }
        
        Move-Item -LiteralPath "$directory\$new_filename" -Destination "$target_dir" 

        Write-Console "移动到 $target_dir"
        $isOk = $true  # 设置为真
        break
    }
}

# 如果没有匹配到，写入 console.txt
if ($isOk -eq $false) {
    Write-Console "该条没有被匹配上"
}
