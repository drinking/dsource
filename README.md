# dsource
A bash script to link binary to source code. 
To help debug binary code without rebuilding with source code.


## How

思路源自美团的[美团 iOS 工程 zsource 命令背后的那些事儿](https://mp.weixin.qq.com/s/3qcv1NW4-ce87cvAS4Jsxg)，制作的简易Bash版。 
简单来讲就是解析指定的二进制文件(第一个路径参数)，获取到编译该二进制时的文件路径，然后在本地建立一个相同路径的文件夹，然后把源码复制或者链接过去(第二个路径为对应的源码文件夹)。
注意：可能由于文件夹名称或者层次结构不一致，导致处理失败。可以手动调整路径,确保路径下能找到对应的源文件。

## Usage

```bash
# for framework
./dsource.sh -l /path/to/xxx.framework/xxx /path/to/releated/xxx/source/

# for .a file
./dsource.sh -l /path/to/xxx.a /path/to/releated/xxx/source/

```

Or copy to `/usr/local/bin/` to use globally.



