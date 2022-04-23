redo log缓冲区是一块内存区域，保存将要写入redo log的数据。

mysql 崩溃恢复是需要redo log的。

redo log缓冲区大小由innodb_log_buffer_size配置选项定义。

redo log缓冲区会定期把内存中的回滚日志刷到磁盘上。一个大的redo log缓冲区意味着允许大事务运行，而无需在事务提交之前将redo log写入磁盘。因此，如果您有更新，插入或删除多行的事务，则使用更大的redo log缓冲区可节省磁盘I/O。


## 参考

- [redo log 缓冲区](https://www.notedeep.com/page/222)
- [mysql日志：redo log、binlog、undo log 区别与作用](https://learnku.com/articles/49614)
- [MySQL之InnoDB存储引擎：浅谈Redo Log重做日志](https://xyzghio.xyz/RedoLogOfInnoDB/)
