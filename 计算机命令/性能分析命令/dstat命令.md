### dstat

> versatile tool for generating system resource statistics

dstat可以替换vmstat、iostat、ifstat

dstat示例

```
$ dstat
You did not select any stats, using -cdngy by default.
----total-cpu-usage---- -dsk/total- -net/total- ---paging-- ---system--
usr sys idl wai hiq siq| read  writ| recv  send|  in   out | int   csw
  2   3  95   0   0   0| 431B   57k|   0     0 |   0     0 |6533    22k
  5   8  86   1   0   0|   0   144k|  16k   41k|   0     0 |  30k   58k
  4   7  89   0   0   0|   0    40k|5903B 9497B|   0     0 |  29k   56k
  3   7  90   0   0   0|   0    40k|1681B 3591B|   0     0 |  28k   55k
  3   7  90   0   0   0|   0     0 |1390B 3392B|   0     0 |  28k   55k
```
