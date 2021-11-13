### 关闭鼠标选择自动进入visual模式

临时禁用

```
:set mouse-=a
```

长期禁用

```
touch ~/.vimrc
echo "set mouse-=a" > ~/.vimrc
source ~/.vimrc
```

### 在visual模式中进行复制/剪切/粘贴

1. 将鼠标移动到需要进行复制或者剪切的行上
2. 进入visual模式
   1. 按`v`进入
3. 移动鼠标选择内容
4. 按`y`复制，按`d`剪切
5. 移动到粘贴位置上
6. 按`P`粘贴到鼠标的前边，按`p`粘贴到鼠标的后边

## 参考

- [Disable vim automatic visual mode on mouse select](https://gist.github.com/u0d7i/01f78999feff1e2a8361)
- [How to Copy, Cut and Paste in Vim / Vi](https://linuxize.com/post/how-to-copy-cut-paste-in-vim/)