# powershell_rename_anime
重命名动漫以适应刮削器的命名规则

## 简介

这是一个用于自动重命名和分类文件的脚本，设计用于配合aria2下载完成后进行调用。该脚本能根据设定的文件关键词，将对应的文件重命名并移动到指定的目录下，特别适合用于整理你的多媒体文件库。
也可以在代码中直接修改$filepath参数然后直接运行
```
$filepath = D:\download\Watashi no Yuri wa Oshigoto desu!.mp4
```

## 快速开始

首先，你需要在同一个文件夹内创建两个文件，分别名为：`console.txt` 和 `rename.txt`，并记住这两个文件所在文件夹的绝对路径。例如：`D:\ariaConfig`。

### 配置文件

你需要在 `rename.txt` 中进行一些配置。配置的格式为“文件关键词;文件夹名称;季数”。如果未填写季数，程序会默认为S01。例如：

```
Watashi no Yuri wa Oshigoto desu!;百合是我的工作！;
```

这行配置意味着，如果文件名包含 `Watashi no Yuri wa Oshigoto desu!`，那么此文件会被重命名并移动到 `百合是我的工作！` 的文件夹中，同时标记为第一季。

如果你要处理的是第二季的文件，你需要在配置中指定季数，例如：

```
Watashi no Yuri wa Oshigoto desu!;百合是我的工作！;02
```

请注意，这个匹配是贪婪匹配，配置文件请注意名称顺序，必须让短文件名在长文件下面，不然会被短文件名给匹配掉。
比如向山进发，如果Yama no Susume放在Yama no Susume Second Season上面，那么Yama no Susume Second Season就会应为匹配到了Yama no Susume而被归类到第一季。
应当按以下顺序写入配置
```
Next Summit;向山进发;04;
Yama no Susume Second Season;向山进发;02;
Yama no Susume Third Season;向山进发;03;
Yama no Susume Omoide Present;向山进发;00;
Yama no Susume;向山进发;
```

### 修改代码中的路径

在运行脚本前，你需要修改代码中的 `$configpath` 和 `$mediapath`。其中，`$configpath` 是 `console.txt` 和 `rename.txt` 所在的文件夹路径，`$mediapath` 是你希望媒体文件被归类存储的位置。新建的目录会在这个文件夹下生成。

例如：

```ps1
$configpath = "D:\ariaConfig" # console.txt 和 rename.txt 所在的文件夹地址
$mediapath = "D:\result" # 媒体库位置，新的文件夹会在此目录下生成
```

### 运行

你需要在aria2的配置文件中添加 `on-download-complete=脚本路径` 来调用这个脚本。然后，当aria2完成下载后，此脚本将自动被调用以重命名并分类下载的文件。

## 贡献

欢迎提交问题或改进建议，你可以通过issue或者pull request进行提交。

## 许可证

该项目采用MIT许可证。

## 注意事项

- 此工具为面向ChatGPT编程，只测试了代码注释中使用的文件名。在openwrt上的linux版本，日常我自己使用三个月没出过问题。
- 这个readme也是ChatGPT生成的，如果没看懂可以和我说我添加使用方法
- 此工具目前仅处理文件，不处理目录。对于深层目录结构的种子文件，此脚本将直接跳过。
- 该工具需要能在文件名中识别到集数，也就是说，文件名中必须包含数字以表示集数，否则无法处理。
