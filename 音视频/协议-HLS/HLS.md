## tag说明

示例

```
#EXTM3U
#EXT-X-TARGETDURATION:10
#EXTINF:9.009,
http://media.example.com/first.ts
#EXTINF:9.009,
http://media.example.com/second.ts
#EXTINF:3.003,
http://media.example.com/third.ts
```

### `#EXTM3U`

首行，格式标识

### `#EXT-X-TARGETDURATION:10`

表示每个segment大约10秒左右

### `#EXTINF:9.009`

segment的时长

## 参考

- rfc8216
