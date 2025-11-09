```
root@vm05:~# free -m
               total        used        free      shared  buff/cache   available
Mem:            1954         251        1035           0         759        1702
Swap:           1384           0        1384

root@vm05:~# swapoff -a
root@vm05:~# free -m
               total        used        free      shared  buff/cache   available
Mem:            1954         250        1036           0         759        1703
Swap:              0           0           0


root@vm05:~# swapon -a
root@vm05:~# free -m
               total        used        free      shared  buff/cache   available
Mem:            1954         251        1035           0         759        1702
Swap:           1384           0        1384
```