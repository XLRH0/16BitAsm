stack segment stack
    db 1000h dup(0)
stack ends

data segment
    inputBuffer db 200h dup(' ')
    coutbreak db 0dh, 0ah,"$"
    coutfile1 db "Please Input Some Word:$"
    coutfile2 db "1:add User,2:delect User,3:change User,4:select User$"
    coutfile3 db "5:readfile,6:savefile,7:exit$"

    coutadd db "Please Input Name phone address:$"
    coutdelete db "Please Input delete Number:$"
    coutchange db "Please Input oldNumber newName newphone newaddress:$"
    coutselect db "0:all,1:Name,2:Phone,3:Address$"
    coutgood db "Operate good!$$"
    couterror db "Operate error!$$"

    ;临时存储
    ;m_IsUse db 00
    ;m_Number db 00h
    ;m_Name db 10h dup('$') 
    ;m_Phone db 10h dup('$') 
    ;m_Address db 2eh dup('$')
;
    g_Number dw 0000h
    g_Buffer db 2000h dup('$')

    readFileName db "File.txt",00
    coutBuffer db "$$$$"
    readFileBuffer db 2000h dup('$')
data ends

code segment
;读取文件 无参
myReadFile proc far c uses bx cx si di dx
    local @handle:word
    mov dx,offset readFileName
    mov al, 0              ;al=属性：0读，1写，3读/写   
    mov ah, 3dh            ;打开文件
    int 21h
    mov @handle,ax          ;保存文件代号
    
    ;读取文件
    mov dx,offset g_Buffer
    mov bx,@handle
    mov cx,2000h
    mov ah, 3fh
    int 21h

    mov dx,0h
    mov bx,50h
    div bx
    mov si,offset g_Number
    mov [si],ax

    ;关闭文件
    mov bx,@handle
    mov ah,3eh
    int 21h 

    ;打印读取内容
    mov dx,offset readFileBuffer
    mov ah,9h;
    int 21h;

    ret
myReadFile endp

;写文件 无参
myWriteFile proc far c uses bx cx si di dx
    local @handle:word
    mov dx,offset readFileName
    mov al, 1              ;al=属性：0读，1写，3读/写   
    mov ah, 3dh            ;打开文件
    int 21h
    mov @handle,ax         ;保存文件代号
    
    ;计算写入字节数
    mov ax,50h
    mov si,offset g_Number
    mov bl,[si]
    mul bl
    mov cx,ax
    
    ;写文件
    mov dx,offset g_Buffer
    mov bx,@handle
    mov ah,40h
    int 21h

    ;关闭文件
    mov bx,@handle
    mov ah,3eh
    int 21h 

    ret
myWriteFile endp

;显示字符 
coutByte proc far c uses bx cx si di dx pbuff1:word
    mov si,offset coutBuffer
    mov ax,pbuff1
    mov bl,10h
    div bl

    ;al商 ah余数
    cmp al,09h
    ja coutbyte1
    add al,30h
    mov [si],al
    inc si
    jmp coutbyteal
coutbyte1:
    add al,51h
    mov [si],al
    inc si

coutbyteal:
    cmp ah,09h
    ja coutbyte2
    add ah,30h
    mov [si],ah
    inc si
    jmp coutbyteoutput
coutbyte2:
    add ah,51h
    mov [si],ah
    inc si

coutbyteoutput:
    mov dx,offset coutBuffer
    mov ah,09h
    int 21h
    ret
coutByte endp

;显示字符串 
cout proc far c uses bx cx si di dx pbuff1:word
    mov dx,pbuff1
    mov ah,09h
    int 21h
    mov dx,offset coutbreak
    mov ah,09h
    int 21h
    ret
cout endp

;显示换行
coutcol proc far c uses bx cx si di dx
    mov dx,offset coutbreak
    mov ah,09h
    int 21h
    ret
coutcol endp

;求字符串长度，存于ax中     strlen
mystrlenspace proc far c uses bx cx si di dx pbuff1:word
    ;工作
    mov si,pbuff1   ;字符串地址
    xor ax,ax       ;清空ax记录长度

mystrlen1:
    mov ch,[si]
    cmp ch,' '
    JZ strlenexit   ;如果等于'$'则结束
    inc ax          ;计数+1
    inc si          ;下一个待判断的字符
    jmp mystrlen1 

strlenexit:
    ret
mystrlenspace endp

;求字符串长度，存于ax中     strlen
mystrlendl proc far c uses bx cx si di dx pbuff1:word
    ;工作
    mov si,pbuff1   ;字符串地址
    xor ax,ax       ;清空ax记录长度

mystrlen1:
    mov ch,[si]
    cmp ch,'$'
    JZ strlenexit   ;如果等于'$'则结束
    inc ax          ;计数+1
    inc si          ;下一个待判断的字符
    jmp mystrlen1 

strlenexit:
    ret
mystrlendl endp

;拷贝字符串     strcpy  串1 串2 串2拷贝到串1
mystrcpyspace proc far c uses bx cx si di dx pbuff1:word,pbuff2:word
    ;工作
    mov si,pbuff1   ;字符串地址
    mov di,pbuff2
    xor ax,ax       ;清空ax记录长度

mystrcpy1:
    mov ch,[di]
    mov [si],ch
    cmp ch,' '
    JZ mystrcpyexit   ;如果等于' '则结束
    inc di            ;计数+1
    inc si            ;
    jmp mystrcpy1 
mystrcpyexit:
    ret
mystrcpyspace endp

;拷贝字符串     strcpy  串1 串2 串2拷贝到串1
mystrcpydl proc far c uses bx cx si di dx pbuff1:word,pbuff2:word
    ;工作
    mov si,pbuff1   ;字符串地址
    mov di,pbuff2
    xor ax,ax       ;清空ax记录长度

mystrcpydl1:
    mov ch,[di]
    mov [si],ch
    cmp ch,'$'
    JZ mystrcpydlexit   ;如果等于' '则结束
    inc di            ;计数+1
    inc si            ;
    jmp mystrcpydl1 
mystrcpydlexit:
    mov bx,' '
    mov [si],bx
    ret
mystrcpydl endp

;拷贝字符串     strcpy  串1 串2 串2拷贝到串1
mystrcpyspaceafter proc far c uses bx cx si di dx pbuff1:word,pbuff2:word
    ;工作
    mov si,pbuff1   ;字符串地址
    mov di,pbuff2
    xor ax,ax       ;清空ax记录长度

mystrcpy2:
    mov ch,[di]
    cmp ch,' '
    JZ mystrcpyexit   ;如果等于' '则结束
    mov [si],ch
    inc di            ;计数+1
    inc si            ;
    jmp mystrcpy2
mystrcpyexit:
    ret
mystrcpyspaceafter endp

;查询子串
mystrstrdlspace proc far c uses bx cx si di dx pbuff1:word,pbuff2:word
    local @length1:word
    local @length2:word
    local @dltlength:word

    ;工作
    mov ax,ds
    mov es,ax
    mov si,pbuff1   ;字符串1地址
    mov di,pbuff2   ;字符串2地址
    invoke mystrlendl,pbuff1
    mov @length1,ax
    mov bx,ax
    invoke mystrlenspace,pbuff2
    mov @length2,ax
    sub bx,ax
    mov @dltlength,bx

    xor ax,ax

mystrstrwhile1:
    cmp ax,@dltlength   ;如果ax大于dltlength,返回ffffh
    ja mystrstrerror
    
    mov si,pbuff1
    add si,ax
    mov di,pbuff2
    mov cx,@length2

    CLD
	repz cmpsb      ;当前字符相同则继续循环
    je mystrstrexit ;相同，退出
    inc ax
    jmp mystrstrwhile1
    
mystrstrerror:
    mov ax,0ffffh

mystrstrexit:
    ret
mystrstrdlspace endp

;清空内存
mymemset proc far c uses bx cx si di dx es pbuff1:word,nlength:word
    mov cx,nlength
    mov ax,ds
    mov es,ax
    mov al,'$'
    mov di,pbuff1
    CLD
    rep stosb
mymemsetexit:
    ret
mymemset endp


;十六进制字符转int类型
wordtoint proc far c uses bx cx si di dx es pbuff1:word
    mov bx,pbuff1
    mov al,bl
    mov bl,bh
    mov bh,al
    cmp bh,'9'
    ja wordtoint1
    sub bh,30h
    jmp wordtoint2
wordtoint1:
    sub bh,51h
wordtoint2:
    cmp bl,'9'
    ja wordtoint3
    sub bl,30h
    jmp wordtoint4
wordtoint3:
    sub bl,51h
wordtoint4:
    mov al,10h
    mul bh
    add al,bl
    ret
wordtoint endp


myreadone proc far c uses bx cx si di dx pbuff1:word,pbuff2:word
    ;计算基址放入si
    mov bx,pbuff1
    mov si,offset g_Number
    mov ax,[si]
    mov cx,50h
    mul cx
    add bx,ax
    mov si,bx

    ;是否存在
    mov ah,1h
    mov [si],ah
    add si,1

    ;编号
    mov bx,offset g_Number
    mov ah,[bx]
    inc ah
    mov [bx],ah
    mov [si],ah
    add si,1

    ;姓名
    mov di,pbuff2
    invoke mystrcpyspaceafter,si,di
    invoke mystrlenspace,di
    mov bx,ax
    mov dh,'$'
    mov [si+bx],dh
    add si,10h
    add di,ax
    inc di

    ;电话
    invoke mystrcpyspaceafter,si,di
    invoke mystrlenspace,di
    mov bx,ax
    mov dh,'$'
    mov [si+bx],dh
    add si,10h
    add di,ax
    inc di

    ;住址
    invoke mystrcpyspaceafter,si,di
    invoke mystrlenspace,di
    mov bx,ax
    mov dh,'$'
    mov [si+bx-1],dh
    add si,10h
    add di,ax
    inc di

    ret
myreadone endp

mychangeone proc far c uses bx cx si di dx pbuff1:word,pbuff2:word,nNumber:byte
    ;计算基址放入si
    mov si,pbuff1

    ;是否存在
    mov al,1h
    mov [si],al
    add si,1

    ;编号
    mov al,nNumber
    mov [si],al
    add si,1

    ;姓名
    mov di,pbuff2
    invoke mystrcpyspaceafter,si,di
    invoke mystrlenspace,di
    mov bx,ax
    mov dh,'$'
    mov [si+bx],dh
    add si,10h
    add di,ax
    inc di

    ;电话
    invoke mystrcpyspaceafter,si,di
    invoke mystrlenspace,di
    mov bx,ax
    mov dh,'$'
    mov [si+bx],dh
    add si,10h
    add di,ax
    inc di

    ;住址
    invoke mystrcpyspaceafter,si,di
    invoke mystrlenspace,di
    mov bx,ax
    mov dh,'$'
    mov [si+bx-1],dh
    add si,10h
    add di,ax
    inc di

    ret
mychangeone endp




myselect1 proc far c uses bx cx si di dx
    ;获取输入信息
    invoke cout,offset coutadd
    mov dx,offset inputBuffer
    mov ah,0ah
    int 21h

    ;将输入信息放入g_Buffer中
    mov si,offset g_Buffer
    mov di,offset inputBuffer
    add di,2
    invoke myreadone,si,di
    ret
myselect1 endp

myselect2 proc far c uses bx cx si di dx
    invoke cout,offset coutdelete
    ;获取输入信息
    mov dx,offset inputBuffer
    mov ah,0ah
    int 21h

    ;读取编号
    mov bx,offset inputBuffer
    add bx,2
    mov ax,[bx]
    invoke wordtoint,ax

    dec al
    mov cl,50h
    mul cl

    mov si,offset g_Buffer
    add si,ax

    mov ah,0
    mov [si],ah

    ret
myselect2 endp

myselect3 proc far c uses bx cx si di dx
    local @Number:byte
    invoke cout,offset coutchange
    ;获取输入信息
    mov dx,offset inputBuffer
    mov ah,0ah
    int 21h

    ;读取编号
    mov bx,offset inputBuffer
    add bx,2
    mov ax,[bx]
    invoke wordtoint,ax
    mov @Number,al
    dec ax

    ;获取输入信息
    mov dx,offset inputBuffer
    mov ah,0ah
    int 21h

    mov cl,50h
    mul cl

    mov si,offset g_Buffer
    add si,ax
    
    mov di,offset inputBuffer
    add di,2
    invoke mychangeone,si,di,@Number

    ret
myselect3 endp

myselect40 proc far c uses bx cx si di dx
    mov bx,offset g_Number
    mov cx,[bx]
    mov si,offset g_Buffer
s40:
    ;0已删除
    mov bl,[si]
    cmp bl,1h
    je c40
    add si,50h
    dec cx
    cmp cx,0h
    je s40exit
    jmp s40
c40:
    inc si
    ;输出编号
    mov al,[si]
    invoke coutbyte,al
    invoke coutcol
    inc si
    ;输出姓名
    invoke cout,si
    add si,10h
    ;输出电话
    invoke cout,si
    add si,10h
    ;输出住址
    invoke cout,si
    add si,2eh
    loop s40
s40exit:
    ret
myselect40 endp

myselect41 proc far c uses bx cx si di dx
    ;获取输入信息
    mov dx,offset inputBuffer
    mov ah,0ah
    int 21h
    ;循环次数、基址
    mov bx,offset g_Number
    mov cx,[bx]
    mov si,offset g_Buffer
    mov di,offset inputBuffer
    add di,2
    ;回车置位
    invoke mystrlenspace,di
    mov bx,ax
    mov ax,' '
    mov [di+bx-1],ax
    
s41:
    mov al,[si]
    cmp al,1h
    je ss41
    add si,50h
    dec cx
    jmp s41

ss41:
    add si,2
    invoke mystrstrdlspace,si,di

    cmp ax,0ffffh
    jne c41
    add si,4eh
    loop s41

c41:
    ;输出编号
    mov al,[si-1]
    invoke coutbyte,al
    invoke coutcol
    ;输出姓名
    invoke cout,si
    add si,10h
    ;输出电话
    invoke cout,si
    add si,10h
    ;输出住址
    invoke cout,si
    add si,2eh
    loop s41
s41exit:
    ret
myselect41 endp


START:
    ;初始化数据段、堆栈段
    assume ds:data,ss:stack
    mov ax,data
    mov ds,ax
    mov ax,stack
    mov ss,ax
    
    ;invoke myReadFile
    ;invoke writeFile
    ;invoke mystrlen,offset writeFileBuffer
    ;invoke coutByte,"I"
    ;invoke coutByte," "
    ;invoke mystrcpy,offset strcpyBuffer,offset writeFileBuffer
    ;invoke cout,offset strcpyBuffer
    ;invoke mymemset,offset strcpyBuffer,10h
    ;invoke mystrstr,offset writeFileBuffer,offset temp

    invoke myReadFile
    invoke myselect41

MyMainWhile:
    mov cx,200h
    mov si,offset inputBuffer
pre1:
    mov ax,' '
    mov [si],ax
    inc si
    loop pre1

    invoke coutcol
    invoke coutcol
    invoke cout,offset coutfile1
    invoke cout,offset coutfile2
    invoke cout,offset coutfile3


MyMainNoInput:
    ;判断是否有输入
    ;mov ah,0bh
    ;int 21h
    ;cmp al,0h
    ;je MyMainNoInput
    ;;获取键盘输入
    ;mov dl,0ffh
    ;mov ah,06h
    ;int 21h

    ;获取输入信息
    mov dx,offset inputBuffer
    mov ah,0ah
    int 21h
    
    ;读取编号
    mov bx,offset inputBuffer
    add bx,2
    mov al,[bx]

    ;如果是1,添加信息
    cmp al,'1'
    je select1
    ;如果是2,删除信息
    cmp al,'2'
    je select2
    ;如果是3,修改信息
    cmp al,'3'
    je select3
    ;如果是4,查询信息
    cmp al,'4'
    je select4
    ;如果是5,读取文件
    cmp al,'5'
    je select5
    ;如果是6,存储文件
    cmp al,'6'
    je select6
    ;如果是7,退出
    cmp al,'7'
    je select7
    ;输入正确数字
    invoke cout,offset couterror
    jmp MyMainWhile
    
select1:
    invoke myselect1
    ;invoke cout,offset coutgood
    jmp MyMainWhile


select2:
    invoke myselect2
    jmp MyMainWhile

select3:
    invoke myselect3
    jmp MyMainWhile

select4:
    invoke cout,offset coutselect
    ;获取输入信息
    mov dx,offset inputBuffer
    mov ah,0ah
    int 21h
    
    ;读取编号
    mov bx,offset inputBuffer
    add bx,2
    mov ah,[bx]

    cmp ah,'0'
    je select40
    cmp ah,'1'
    je select41
    cmp ah,'2'
    je select42
    cmp ah,'3'
    je select43
    invoke cout,offset couterror
    jmp MyMainWhile

select40:
    invoke myselect40
    jmp MyMainWhile

select41:
    invoke myselect41
    jmp MyMainWhile

select42:
    ;invoke myselect42
    jmp MyMainWhile

select43:
    ;invoke myselect43
    jmp MyMainWhile

select5:
    invoke cout,offset coutgood
    invoke myReadFile
    jmp MyMainWhile
    
select6:
    invoke cout,offset coutgood
    invoke myWriteFile
    jmp MyMainWhile

select7:
    mov ah,4ch
    int 21h


code ends
end start


