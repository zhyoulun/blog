```
zyl@debian:~/codes/zhyoulun/6.828-xv6-2018$ objdump -D obj/kern/kernel | less
```

## 首行

```
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
f0100000:       02 b0 ad 1b 00 00       add    0x1bad(%eax),%dh
f0100006:       00 00                   add    %al,(%eax)
f0100008:       fe 4f 52                decb   0x52(%edi)
f010000b:       e4                      in     $0x66,%al

f010000c <entry>:
f010000c:       66 c7 05 72 04 00 00    movw   $0x1234,0x472
f0100013:       34 12
f0100015:       b8 00 d0 10 00          mov    $0x10d000,%eax
f010001a:       0f 22 d8                mov    %eax,%cr3
f010001d:       0f 20 c0                mov    %cr0,%eax
f0100020:       0d 01 00 01 80          or     $0x80010001,%eax
f0100025:       0f 22 c0                mov    %eax,%cr0
f0100028:       b8 2f 00 10 f0          mov    $0xf010002f,%eax
f010002d:       ff e0                   jmp    *%eax

f010002f <relocated>:
f010002f:       bd 00 00 00 00          mov    $0x0,%ebp
f0100034:       bc 00 b0 10 f0          mov    $0xf010b000,%esp
f0100039:       e8 68 00 00 00          call   f01000a6 <i386_init>

f010003e <spin>:
f010003e:       eb fe                   jmp    f010003e <spin>
```

## i386_init函数

```
f01000a6 <i386_init>:
f01000a6:       55                      push   %ebp
f01000a7:       89 e5                   mov    %esp,%ebp
f01000a9:       53                      push   %ebx
f01000aa:       83 ec 08                sub    $0x8,%esp
f01000ad:       e8 0a 01 00 00          call   f01001bc <__x86.get_pc_thunk.bx>
f01000b2:       81 c3 56 c2 00 00       add    $0xc256,%ebx
f01000b8:       c7 c2 60 e0 10 f0       mov    $0xf010e060,%edx
f01000be:       c7 c0 c0 e6 10 f0       mov    $0xf010e6c0,%eax
f01000c4:       29 d0                   sub    %edx,%eax
f01000c6:       50                      push   %eax
f01000c7:       6a 00                   push   $0x0
f01000c9:       52                      push   %edx
f01000ca:       e8 0a 15 00 00          call   f01015d9 <memset>
f01000cf:       e8 40 05 00 00          call   f0100614 <cons_init>
f01000d4:       83 c4 08                add    $0x8,%esp
f01000d7:       68 ac 1a 00 00          push   $0x1aac
f01000dc:       8d 83 4f 57 ff ff       lea    -0xa8b1(%ebx),%eax
f01000e2:       50                      push   %eax
f01000e3:       e8 56 09 00 00          call   f0100a3e <cprintf>
f01000e8:       c7 04 24 05 00 00 00    movl   $0x5,(%esp)
f01000ef:       e8 4c ff ff ff          call   f0100040 <test_backtrace>
f01000f4:       83 c4 10                add    $0x10,%esp
f01000f7:       83 ec 0c                sub    $0xc,%esp
f01000fa:       6a 00                   push   $0x0
f01000fc:       e8 81 07 00 00          call   f0100882 <monitor>
f0100101:       83 c4 10                add    $0x10,%esp
f0100104:       eb f1                   jmp    f01000f7 <i386_init+0x51>
```

## monitor函数

```
f0100882 <monitor>:
f0100882:       55                      push   %ebp
f0100883:       89 e5                   mov    %esp,%ebp
f0100885:       57                      push   %edi
f0100886:       56                      push   %esi
f0100887:       53                      push   %ebx
f0100888:       83 ec 68                sub    $0x68,%esp
f010088b:       e8 2c f9 ff ff          call   f01001bc <__x86.get_pc_thunk.bx>
f0100890:       81 c3 78 ba 00 00       add    $0xba78,%ebx
f0100896:       8d 83 70 5b ff ff       lea    -0xa490(%ebx),%eax
f010089c:       50                      push   %eax
f010089d:       e8 9c 01 00 00          call   f0100a3e <cprintf>
f01008a2:       8d 83 94 5b ff ff       lea    -0xa46c(%ebx),%eax
f01008a8:       89 04 24                mov    %eax,(%esp)
f01008ab:       e8 8e 01 00 00          call   f0100a3e <cprintf>
f01008b0:       83 c4 10                add    $0x10,%esp
f01008b3:       8d bb 2a 5a ff ff       lea    -0xa5d6(%ebx),%edi
f01008b9:       eb 4a                   jmp    f0100905 <monitor+0x83>
f01008bb:       83 ec 08                sub    $0x8,%esp
f01008be:       0f be c0                movsbl %al,%eax
f01008c1:       50                      push   %eax
f01008c2:       57                      push   %edi
f01008c3:       e8 d2 0c 00 00          call   f010159a <strchr>
f01008c8:       83 c4 10                add    $0x10,%esp
f01008cb:       85 c0                   test   %eax,%eax
f01008cd:       74 08                   je     f01008d7 <monitor+0x55>
f01008cf:       c6 06 00                movb   $0x0,(%esi)
f01008d2:       8d 76 01                lea    0x1(%esi),%esi
f01008d5:       eb 79                   jmp    f0100950 <monitor+0xce>
f01008d7:       80 3e 00                cmpb   $0x0,(%esi)
f01008da:       74 7f                   je     f010095b <monitor+0xd9>
f01008dc:       83 7d a4 0f             cmpl   $0xf,-0x5c(%ebp)
f01008e0:       74 0f                   je     f01008f1 <monitor+0x6f>
f01008e2:       8b 45 a4                mov    -0x5c(%ebp),%eax
f01008e5:       8d 48 01                lea    0x1(%eax),%ecx
f01008e8:       89 4d a4                mov    %ecx,-0x5c(%ebp)
f01008eb:       89 74 85 a8             mov    %esi,-0x58(%ebp,%eax,4)
f01008ef:       eb 44                   jmp    f0100935 <monitor+0xb3>
f01008f1:       83 ec 08                sub    $0x8,%esp
f01008f4:       6a 10                   push   $0x10
f01008f6:       8d 83 2f 5a ff ff       lea    -0xa5d1(%ebx),%eax
f01008fc:       50                      push   %eax
f01008fd:       e8 3c 01 00 00          call   f0100a3e <cprintf>
f0100902:       83 c4 10                add    $0x10,%esp
f0100905:       8d 83 26 5a ff ff       lea    -0xa5da(%ebx),%eax
f010090b:       89 45 a4                mov    %eax,-0x5c(%ebp)
f010090e:       83 ec 0c                sub    $0xc,%esp
f0100911:       ff 75 a4                push   -0x5c(%ebp)
f0100914:       e8 2f 0a 00 00          call   f0101348 <readline>
f0100919:       89 c6                   mov    %eax,%esi
f010091b:       83 c4 10                add    $0x10,%esp
f010091e:       85 c0                   test   %eax,%eax
f0100920:       74 ec                   je     f010090e <monitor+0x8c>
f0100922:       c7 45 a8 00 00 00 00    movl   $0x0,-0x58(%ebp)
f0100929:       c7 45 a4 00 00 00 00    movl   $0x0,-0x5c(%ebp)
f0100930:       eb 1e                   jmp    f0100950 <monitor+0xce>
f0100932:       83 c6 01                add    $0x1,%esi
f0100935:       0f b6 06                movzbl (%esi),%eax
f0100938:       84 c0                   test   %al,%al
f010093a:       74 14                   je     f0100950 <monitor+0xce>
f010093c:       83 ec 08                sub    $0x8,%esp
f010093f:       0f be c0                movsbl %al,%eax
f0100942:       50                      push   %eax
f0100943:       57                      push   %edi
f0100944:       e8 51 0c 00 00          call   f010159a <strchr>
f0100949:       83 c4 10                add    $0x10,%esp
f010094c:       85 c0                   test   %eax,%eax
f010094e:       74 e2                   je     f0100932 <monitor+0xb0>
f0100950:       0f b6 06                movzbl (%esi),%eax
f0100953:       84 c0                   test   %al,%al
f0100955:       0f 85 60 ff ff ff       jne    f01008bb <monitor+0x39>
f010095b:       8b 45 a4                mov    -0x5c(%ebp),%eax
f010095e:       c7 44 85 a8 00 00 00    movl   $0x0,-0x58(%ebp,%eax,4)
f0100965:       00
f0100966:       85 c0                   test   %eax,%eax
f0100968:       74 9b                   je     f0100905 <monitor+0x83>
f010096a:       83 ec 08                sub    $0x8,%esp
f010096d:       8d 83 f6 59 ff ff       lea    -0xa60a(%ebx),%eax
f0100973:       50                      push   %eax
f0100974:       ff 75 a8                push   -0x58(%ebp)
f0100977:       e8 bd 0b 00 00          call   f0101539 <strcmp>
f010097c:       83 c4 10                add    $0x10,%esp
f010097f:       85 c0                   test   %eax,%eax
f0100981:       74 38                   je     f01009bb <monitor+0x139>
f0100983:       83 ec 08                sub    $0x8,%esp
f0100986:       8d 83 04 5a ff ff       lea    -0xa5fc(%ebx),%eax
f010098c:       50                      push   %eax
f010098d:       ff 75 a8                push   -0x58(%ebp)
f0100990:       e8 a4 0b 00 00          call   f0101539 <strcmp>
f0100995:       83 c4 10                add    $0x10,%esp
f0100998:       85 c0                   test   %eax,%eax
f010099a:       74 1a                   je     f01009b6 <monitor+0x134>
f010099c:       83 ec 08                sub    $0x8,%esp
f010099f:       ff 75 a8                push   -0x58(%ebp)
f01009a2:       8d 83 4c 5a ff ff       lea    -0xa5b4(%ebx),%eax
f01009a8:       50                      push   %eax
f01009a9:       e8 90 00 00 00          call   f0100a3e <cprintf>
f01009ae:       83 c4 10                add    $0x10,%esp
f01009b1:       e9 4f ff ff ff          jmp    f0100905 <monitor+0x83>
f01009b6:       b8 01 00 00 00          mov    $0x1,%eax
f01009bb:       83 ec 04                sub    $0x4,%esp
f01009be:       8d 04 40                lea    (%eax,%eax,2),%eax
f01009c1:       ff 75 08                push   0x8(%ebp)
f01009c4:       8d 55 a8                lea    -0x58(%ebp),%edx
f01009c7:       52                      push   %edx
f01009c8:       ff 75 a4                push   -0x5c(%ebp)
f01009cb:       ff 94 83 10 1d 00 00    call   *0x1d10(%ebx,%eax,4)
f01009d2:       83 c4 10                add    $0x10,%esp
f01009d5:       85 c0                   test   %eax,%eax
f01009d7:       0f 89 28 ff ff ff       jns    f0100905 <monitor+0x83>
f01009dd:       8d 65 f4                lea    -0xc(%ebp),%esp
f01009e0:       5b                      pop    %ebx
f01009e1:       5e                      pop    %esi
f01009e2:       5f                      pop    %edi
f01009e3:       5d                      pop    %ebp
f01009e4:       c3                      ret
```