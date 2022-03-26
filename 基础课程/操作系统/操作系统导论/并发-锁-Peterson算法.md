### 基础

Peterson算法保证两个线程不会同时进入临界区

算法使用两个控制变量flag和turn，其中`flag[n]`的值为真，表示ID号为n的进程希望进入临界区，变量turn保存有权限访问共享资源的进程的ID号

Peterson算法不需要原子(atomic)操作，即它是纯软件途径解决了互斥锁的实现。但需要注意限制CPU对内存的访问顺序的优化改变。

### 代码

```c
int flag[2];
int turn;

void init(){
    flag[0] = flag[0] = false;
    turn = 0;
}

void lock(){
    flag[self] = 1;
    turn = 1 - self;
    while(flag[1-self]==true && turn == 1-self); //spin-wait
}

void unlock(){
    flag[self] = 0;
}
```

### 分析

```c
flag[0] = false;
flag[1] = false;
int turn;
```

P0

```c
flag[0] = true; //希望进入临界区
turn = 1;//对方有访问权限
while(flag[1] == true && turn == 1);//busy wait（如果进程1希望进入临界区，并且1有访问权限，则等待）
//临界区
flag[0] = false;
```

P1

```c
flag[1] = true; //希望进入临界区
turn = 0;//对方有访问权限
while(flag[0] == true && turn == 0);//busy wait（如果进程0希望进入临界区，并且0有访问权限，则等待）
//临界区
flag[1] = false;
```

### 扩展到N个线程

```c
// initialization
level[N] = { -1 };     // current level of processes 0...N-1
waiting[N-1] = { -1 }; // the waiting process of each level 0...N-2

// code for process #i
for(l = 0; l < N-1; ++l) { // go through each level
    level[i] = l;
    waiting[l] = i;
    while(waiting[l] == i &&
          (there exists k ≠ i, such that level[k] ≥ l)) {
        // busy wait
    }
}

// critical section

level[i] = -1; // exit section
```

## 参考

- [Peterson算法](https://zh.wikipedia.org/wiki/Peterson%E7%AE%97%E6%B3%95)