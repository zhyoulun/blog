```
zyl@debian:~/codes/zhyoulun/6.828-xv6-2018$ objdump -D obj/boot/boot.out

obj/boot/boot.out:     file format elf32-i386


Disassembly of section .text:

00007c00 <start>:
    7c00:	fa                   	cli
    7c01:	fc                   	cld
    7c02:	31 c0                	xor    %eax,%eax
    7c04:	8e d8                	mov    %eax,%ds
    7c06:	8e c0                	mov    %eax,%es
    7c08:	8e d0                	mov    %eax,%ss

00007c0a <seta20.1>:
    7c0a:	e4 64                	in     $0x64,%al
    7c0c:	a8 02                	test   $0x2,%al
    7c0e:	75 fa                	jne    7c0a <seta20.1>
    7c10:	b0 d1                	mov    $0xd1,%al
    7c12:	e6 64                	out    %al,$0x64

00007c14 <seta20.2>:
    7c14:	e4 64                	in     $0x64,%al
    7c16:	a8 02                	test   $0x2,%al
    7c18:	75 fa                	jne    7c14 <seta20.2>
    7c1a:	b0 df                	mov    $0xdf,%al
    7c1c:	e6 60                	out    %al,$0x60
    7c1e:	0f 01 16             	lgdtl  (%esi)
    7c21:	64 7c 0f             	fs jl  7c33 <protcseg+0x1>
    7c24:	20 c0                	and    %al,%al
    7c26:	66 83 c8 01          	or     $0x1,%ax
    7c2a:	0f 22 c0             	mov    %eax,%cr0
    7c2d:	ea 32 7c 08 00   	ljmp   $0xb866,$0x87c32

00007c32 <protcseg>:
    7c32:	66 b8 10 00          	mov    $0x10,%ax
    7c36:	8e d8                	mov    %eax,%ds
    7c38:	8e c0                	mov    %eax,%es
    7c3a:	8e e0                	mov    %eax,%fs
    7c3c:	8e e8                	mov    %eax,%gs
    7c3e:	8e d0                	mov    %eax,%ss
    7c40:	bc 00 7c 00 00       	mov    $0x7c00,%esp
    7c45:	e8 cf 00 00 00       	call   7d19 <bootmain>

00007c4a <spin>:
    7c4a:	eb fe                	jmp    7c4a <spin>

00007c4c <gdt>:
	...
    7c54:	ff                   	(bad)
    7c55:	ff 00                	incl   (%eax)
    7c57:	00 00                	add    %al,(%eax)
    7c59:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c60:	00 92 cf 00      	add    %dl,0x1700cf(%edx)

00007c64 <gdtdesc>:
    7c64:	17                   	pop    %ss
    7c65:	00 4c 7c 00          	add    %cl,0x0(%esp,%edi,2)
	...

00007c6a <waitdisk>:
    7c6a:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c6f:	ec                   	in     (%dx),%al
    7c70:	83 e0 c0             	and    $0xffffffc0,%eax
    7c73:	3c 40                	cmp    $0x40,%al
    7c75:	75 f8                	jne    7c6f <waitdisk+0x5>
    7c77:	c3                   	ret

00007c78 <readsect>:
    7c78:	55                   	push   %ebp
    7c79:	89 e5                	mov    %esp,%ebp
    7c7b:	57                   	push   %edi
    7c7c:	50                   	push   %eax
    7c7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    7c80:	e8 e5 ff ff ff       	call   7c6a <waitdisk>
    7c85:	b0 01                	mov    $0x1,%al
    7c87:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7c8c:	ee                   	out    %al,(%dx)
    7c8d:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7c92:	89 c8                	mov    %ecx,%eax
    7c94:	ee                   	out    %al,(%dx)
    7c95:	89 c8                	mov    %ecx,%eax
    7c97:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7c9c:	c1 e8 08             	shr    $0x8,%eax
    7c9f:	ee                   	out    %al,(%dx)
    7ca0:	89 c8                	mov    %ecx,%eax
    7ca2:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7ca7:	c1 e8 10             	shr    $0x10,%eax
    7caa:	ee                   	out    %al,(%dx)
    7cab:	89 c8                	mov    %ecx,%eax
    7cad:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7cb2:	c1 e8 18             	shr    $0x18,%eax
    7cb5:	83 c8 e0             	or     $0xffffffe0,%eax
    7cb8:	ee                   	out    %al,(%dx)
    7cb9:	b0 20                	mov    $0x20,%al
    7cbb:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7cc0:	ee                   	out    %al,(%dx)
    7cc1:	e8 a4 ff ff ff       	call   7c6a <waitdisk>
    7cc6:	b9 80 00 00 00       	mov    $0x80,%ecx
    7ccb:	8b 7d 08             	mov    0x8(%ebp),%edi
    7cce:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7cd3:	fc                   	cld
    7cd4:	f2 6d                	repnz insl (%dx),%es:(%edi)
    7cd6:	5a                   	pop    %edx
    7cd7:	5f                   	pop    %edi
    7cd8:	5d                   	pop    %ebp
    7cd9:	c3                   	ret

00007cda <readseg>:
    7cda:	55                   	push   %ebp
    7cdb:	89 e5                	mov    %esp,%ebp
    7cdd:	57                   	push   %edi
    7cde:	56                   	push   %esi
    7cdf:	53                   	push   %ebx
    7ce0:	83 ec 0c             	sub    $0xc,%esp
    7ce3:	8b 7d 10             	mov    0x10(%ebp),%edi
    7ce6:	8b 5d 08             	mov    0x8(%ebp),%ebx
    7ce9:	8b 75 0c             	mov    0xc(%ebp),%esi
    7cec:	c1 ef 09             	shr    $0x9,%edi
    7cef:	01 de                	add    %ebx,%esi
    7cf1:	47                   	inc    %edi
    7cf2:	81 e3 00 fe ff ff    	and    $0xfffffe00,%ebx
    7cf8:	39 f3                	cmp    %esi,%ebx
    7cfa:	73 15                	jae    7d11 <readseg+0x37>
    7cfc:	50                   	push   %eax
    7cfd:	50                   	push   %eax
    7cfe:	57                   	push   %edi
    7cff:	47                   	inc    %edi
    7d00:	53                   	push   %ebx
    7d01:	81 c3 00 02 00 00    	add    $0x200,%ebx
    7d07:	e8 6c ff ff ff       	call   7c78 <readsect>
    7d0c:	83 c4 10             	add    $0x10,%esp
    7d0f:	eb e7                	jmp    7cf8 <readseg+0x1e>
    7d11:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7d14:	5b                   	pop    %ebx
    7d15:	5e                   	pop    %esi
    7d16:	5f                   	pop    %edi
    7d17:	5d                   	pop    %ebp
    7d18:	c3                   	ret

00007d19 <bootmain>:
    7d19:	55                   	push   %ebp
    7d1a:	89 e5                	mov    %esp,%ebp
    7d1c:	56                   	push   %esi
    7d1d:	53                   	push   %ebx
    7d1e:	52                   	push   %edx
    7d1f:	6a 00                	push   $0x0
    7d21:	68 00 10 00 00       	push   $0x1000
    7d26:	68 00 00 01 00       	push   $0x10000
    7d2b:	e8 aa ff ff ff       	call   7cda <readseg>
    7d30:	83 c4 10             	add    $0x10,%esp
    7d33:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d3a:	45 4c 46
    7d3d:	75 38                	jne    7d77 <bootmain+0x5e>
    7d3f:	a1 1c 00 01 00       	mov    0x1001c,%eax
    7d44:	0f b7 35 2c 00 01 00 	movzwl 0x1002c,%esi
    7d4b:	8d 98 00 00 01 00    	lea    0x10000(%eax),%ebx
    7d51:	c1 e6 05             	shl    $0x5,%esi
    7d54:	01 de                	add    %ebx,%esi
    7d56:	39 f3                	cmp    %esi,%ebx
    7d58:	73 17                	jae    7d71 <bootmain+0x58>
    7d5a:	50                   	push   %eax
    7d5b:	83 c3 20             	add    $0x20,%ebx
    7d5e:	ff 73 e4             	push   -0x1c(%ebx)
    7d61:	ff 73 f4             	push   -0xc(%ebx)
    7d64:	ff 73 ec             	push   -0x14(%ebx)
    7d67:	e8 6e ff ff ff       	call   7cda <readseg>
    7d6c:	83 c4 10             	add    $0x10,%esp
    7d6f:	eb e5                	jmp    7d56 <bootmain+0x3d>
    7d71:	ff 15 18 00 01 00    	call   *0x10018
    7d77:	ba 00 8a 00 00       	mov    $0x8a00,%edx
    7d7c:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
    7d81:	66 ef                	out    %ax,(%dx)
    7d83:	b8 00 8e ff ff       	mov    $0xffff8e00,%eax
    7d88:	66 ef                	out    %ax,(%dx)
    7d8a:	eb fe                	jmp    7d8a <bootmain+0x71>

Disassembly of section .eh_frame:

00007d8c <__bss_start-0x9c>:
    7d8c:	14 00                	adc    $0x0,%al
    7d8e:	00 00                	add    %al,(%eax)
    7d90:	00 00                	add    %al,(%eax)
    7d92:	00 00                	add    %al,(%eax)
    7d94:	01 7a 52             	add    %edi,0x52(%edx)
    7d97:	00 01                	add    %al,(%ecx)
    7d99:	7c 08                	jl     7da3 <bootmain+0x8a>
    7d9b:	01 1b                	add    %ebx,(%ebx)
    7d9d:	0c 04                	or     $0x4,%al
    7d9f:	04 88                	add    $0x88,%al
    7da1:	01 00                	add    %eax,(%eax)
    7da3:	00 10                	add    %dl,(%eax)
    7da5:	00 00                	add    %al,(%eax)
    7da7:	00 1c 00             	add    %bl,(%eax,%eax,1)
    7daa:	00 00                	add    %al,(%eax)
    7dac:	be fe ff ff 0e       	mov    $0xefffffe,%esi
    7db1:	00 00                	add    %al,(%eax)
    7db3:	00 00                	add    %al,(%eax)
    7db5:	00 00                	add    %al,(%eax)
    7db7:	00 20                	add    %ah,(%eax)
    7db9:	00 00                	add    %al,(%eax)
    7dbb:	00 30                	add    %dh,(%eax)
    7dbd:	00 00                	add    %al,(%eax)
    7dbf:	00 b8 fe ff ff 62    	add    %bh,0x62fffffe(%eax)
    7dc5:	00 00                	add    %al,(%eax)
    7dc7:	00 00                	add    %al,(%eax)
    7dc9:	41                   	inc    %ecx
    7dca:	0e                   	push   %cs
    7dcb:	08 85 02 42 0d 05    	or     %al,0x50d4202(%ebp)
    7dd1:	42                   	inc    %edx
    7dd2:	87 03                	xchg   %eax,(%ebx)
    7dd4:	02 5b c7             	add    -0x39(%ebx),%bl
    7dd7:	41                   	inc    %ecx
    7dd8:	c5 0c 04             	lds    (%esp,%eax,1),%ecx
    7ddb:	04 28                	add    $0x28,%al
    7ddd:	00 00                	add    %al,(%eax)
    7ddf:	00 54 00 00          	add    %dl,0x0(%eax,%eax,1)
    7de3:	00 f6                	add    %dh,%dh
    7de5:	fe                   	(bad)
    7de6:	ff                   	(bad)
    7de7:	ff                   	(bad)
    7de8:	3f                   	aas
    7de9:	00 00                	add    %al,(%eax)
    7deb:	00 00                	add    %al,(%eax)
    7ded:	41                   	inc    %ecx
    7dee:	0e                   	push   %cs
    7def:	08 85 02 42 0d 05    	or     %al,0x50d4202(%ebp)
    7df5:	46                   	inc    %esi
    7df6:	87 03                	xchg   %eax,(%ebx)
    7df8:	86 04 83             	xchg   %al,(%ebx,%eax,4)
    7dfb:	05 72 c3 41 c6       	add    $0xc641c372,%eax
    7e00:	41                   	inc    %ecx
    7e01:	c7 41 c5 0c 04 04 00 	movl   $0x4040c,-0x3b(%ecx)
    7e08:	1c 00                	sbb    $0x0,%al
    7e0a:	00 00                	add    %al,(%eax)
    7e0c:	80 00 00             	addb   $0x0,(%eax)
    7e0f:	00 09                	add    %cl,(%ecx)
    7e11:	ff                   	(bad)
    7e12:	ff                   	(bad)
    7e13:	ff 73 00             	push   0x0(%ebx)
    7e16:	00 00                	add    %al,(%eax)
    7e18:	00 41 0e             	add    %al,0xe(%ecx)
    7e1b:	08 85 02 42 0d 05    	or     %al,0x50d4202(%ebp)
    7e21:	42                   	inc    %edx
    7e22:	86 03                	xchg   %al,(%ebx)
    7e24:	83 04 00 00          	addl   $0x0,(%eax,%eax,1)

Disassembly of section .comment:

00000000 <.comment>:
   0:	47                   	inc    %edi
   1:	43                   	inc    %ebx
   2:	43                   	inc    %ebx
   3:	3a 20                	cmp    (%eax),%ah
   5:	28 44 65 62          	sub    %al,0x62(%ebp,%eiz,2)
   9:	69 61 6e 20 31 32 2e 	imul   $0x2e323120,0x6e(%ecx),%esp
  10:	32 2e                	xor    (%esi),%ch
  12:	30 2d 31 34 29 20    	xor    %ch,0x20293431
  18:	31 32                	xor    %esi,(%edx)
  1a:	2e 32 2e             	xor    %cs:(%esi),%ch
  1d:	30 00                	xor    %al,(%eax)
```