# dsource
A bash script that wraps `dwarfdump` to help linking binary to source code and 
debuging binary code with out rebuilding with source code.


## How

思路源自美团的[美团 iOS 工程 zsource 命令背后的那些事儿](https://mp.weixin.qq.com/s/3qcv1NW4-ce87cvAS4Jsxg)，制作的简易Bash版。 

简单来讲就是解析指定的二进制文件(第一个路径参数)，获取到编译该二进制时的文件路径，然后在本地建立一个相同路径的文件夹，然后把源码复制或者链接过去(第二个路径为对应的源码文件夹)。

## Usage

```bash
# for binary in framework
./dsource.sh -l /path/to/xxx.framework/xxx /path/to/releated/xxx/source/

# or for .a file
./dsource.sh -l /path/to/xxx.a /path/to/releated/xxx/source/

```

copy this script to `/usr/local/bin/` to use globally.


## Error handling

Incase some mismatch, you can use `dsource.sh -f` to find the compile directory and create it manually by `mkdir -p`,
copy source code to that path, and run `dsource.sh -c` to check if it matches, 
modify the path name or hierarchical structure if neeeded.






