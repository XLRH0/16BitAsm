;俄罗斯方块汇编版本
;墙和块
WALL equ 1
BLOCK equ 0

ROW equ 0ch
COL equ 10h

data_seg SEGMENT 
    pointxy db 2h dup(0h)   ;bh左右，bl上下
    randkind db 2h dup(0h)  ;bh种类，bl样式
    g_time db 2h dup(0h)    ;计算时间
    g_score db 2h dup(0h)   ;分数

    inputBuffer db 20h dup(' ')
    coutbytebuffer db 4h dup('$')
    coutbreak db 0dh, 0ah,"$"
    coutbreakrn db 0dh, 0ah,"$"

    g_outputmap db 0c0h dup(BLOCK)

    g_map_buffer1 db 100h dup(0)

    g_map db WALL, ROW - 2 dup(BLOCK), WALL
    g_map_1 db WALL, ROW - 2 dup(BLOCK), WALL
    g_map_2 db WALL, ROW - 2 dup(BLOCK), WALL
    g_map_3 db WALL, ROW - 2 dup(BLOCK), WALL
    g_map_4 db WALL, ROW - 2 dup(BLOCK), WALL
    g_map_5 db WALL, ROW - 2 dup(BLOCK), WALL
    g_map_6 db WALL, ROW - 2 dup(BLOCK), WALL
    g_map_7 db WALL, ROW - 2 dup(BLOCK), WALL
    g_map_8 db WALL, ROW - 2 dup(BLOCK), WALL
    g_map_9 db WALL, ROW - 2 dup(BLOCK), WALL
    g_map_10 db WALL, ROW - 2 dup(BLOCK), WALL
    g_map_11 db WALL, ROW - 2 dup(BLOCK), WALL
    g_map_12 db WALL, ROW - 2 dup(BLOCK), WALL
    g_map_13 db WALL, ROW - 2 dup(BLOCK), WALL
    g_map_14 db WALL, ROW - 2 dup(BLOCK), WALL
    g_map_15 db ROW dup(WALL)

    g_map_buffer2 db 100h dup(0)

    g_block1 db 1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0
    g_block2 db 1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0
    g_block3 db 1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0
    g_block4 db 1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0
    g_block5 db 0,1,0,0,1,1,1,0,0,0,0,0,0,0,0,0,1,0,0,0,1,1,0,0,1,0,0,0,0,0,0,0
    g_block6 db 1,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,1,0,0,0,1,0,0,0,0,0,0

    g_map_buffer3 db 100h dup(0)
    
data_seg ENDS


stack_seg SEGMENT stack
    db 1024 dup(00)
stack_seg ENDS

showmap PROTO far c 

selecta PROTO far c 
selectd PROTO far c 
selects PROTO far c 
selectw PROTO far c 
selectq PROTO far c 

cout PROTO far c pbuff1:word
coutrn PROTO far c 
coutcls PROTO far c 
coutbyte PROTO far c pbuff1:word
setrandkind PROTO far c 
gettime PROTO far c 

setpoint PROTO far c pbuff1:word
fixblock PROTO far c pbuff1:word
ismoveok PROTO far c pbuff1:word
calnumber PROTO far c pbuff1:word
iserase PROTO far c pbuff1:word
erasemap PROTO far c pbuff1:word,pbuff1:word
isend PROTO far c pbuff1:word
mymemcpy PROTO far c pbuff1:word,pbuff2:word,nlength:word 

code_seg SEGMENT
START:
    ;初始化数据段、堆栈段
    assume ds:data_seg,ss:stack_seg
    mov ax,data_seg
    mov ds,ax
    mov ax,stack_seg
    mov ss,ax

    ;设置初始点、清屏
    mov ah,5h
    mov al,00h
    invoke setpoint,ax
    invoke coutcls

    ;拷贝数组后
    mov bx,0c0h
    invoke mymemcpy,offset g_outputmap,offset g_map,bx

    ;固定方格后打印
    invoke setrandkind
    invoke fixblock,offset g_outputmap
    invoke showmap

    ;计算时间存储
    invoke gettime
    mov si,offset g_time
    mov [si],ax

MyMainInput:
    ;判断是否有输入
    mov ah,0bh
    int 21h
    cmp al,0h
    je MyMainInput1
    ;获取键盘输入
    mov dl,0ffh
    mov ah,06h
    int 21h

MyMainInput1:
    mov bl,al
    cmp bl,'a'
    jne InputNa
    invoke selecta
    jmp MyMainInput
InputNa:
    cmp bl,'d'
    jne InputNd
    invoke selectd
    jmp MyMainInput
InputNd:
    cmp bl,'s'
    jne InputNs
    invoke selects
    jmp MyMainInput
InputNs:
    cmp bl,'w'
    jne InputNq
    invoke selectw
    jmp MyMainInput
InputNq:
    cmp bl,'q'
    jne InputEnd
    invoke selectq
InputEnd:
    invoke gettime
    mov cx,ax
    mov si,offset g_time
    mov dx,[si]
    cmp ah,dh
    je gettimecmp
    add al,100
 gettimecmp:
    add dl,20
    cmp al,dl
    jna MyMainInput
    mov [si],cx
    invoke coutcls
    invoke selects
    invoke showmap
    jmp MyMainInput


;显示字符串 
cout proc far c uses bx cx si di dx pbuff1:word
    mov dx,pbuff1
    mov ah,09h
    int 21h
    ret
cout endp

;显示换行
coutrn proc far c uses bx cx si di dx
    mov dx,offset coutbreakrn
    mov ah,09h
    int 21h
    ret
coutrn endp

;清屏
coutcls proc far c uses bx cx si di dx
    mov ah, 15
    int 10h
    mov ah, 0
    int 10h
    ret
coutcls endp

;显示方块
coutbyte proc far c uses bx cx si di dx pbuff1:word
    mov si,pbuff1
    mov di,offset coutbytebuffer
    mov bl,[si]
    cmp bl,1h
    je coutbyte1
    mov cl,' '
    mov [di],cl
    jmp coutbyteexit

coutbyte1:
    mov cx,'*'
    mov [di],cx

coutbyteexit:
    mov dx,di
    mov ah,09h
    int 21h
    ret
coutbyte endp


setrandkind proc far c uses bx cx si di dx
    invoke gettime
    mov bl,3
    xor ah,ah
    div bl
    mov si,offset randkind
    mov [si+1],ah
    ret
setrandkind endp

gettime proc far c uses bx cx si di dx
    mov ah, 2ch
    int 21h
    mov ax,dx
    ret
gettime endp

setpoint proc far c uses bx cx si di dx pbuff1:word
    mov bx,pbuff1
    mov di,offset pointxy
    mov [di],bx
    ret
setpoint endp

fixblock proc far c uses bx cx si di dx pbuff1:word
    mov bx,offset pointxy
    mov bx,[bx]
;计算存储地址
    mov di,pbuff1
    xor dx,dx
    add dl,bh
    add di,dx
    xor ax,ax
    mov al,0ch
    mul bl
    add di,ax
;计算方格地址
    mov bx,offset randkind
    mov bx,[bx]
    mov si,offset g_block1
    mov al,40h
    mul bh
    add si,ax
    mov al,10h
    mul bl
    add si,ax

;循环四次，将方格加进去
    mov cx,4
fixblockwhile1:
    mov bl,[si]
    add [di],bl
    inc si
    inc di
    mov bl,[si]
    add [di],bl
    inc si
    inc di
    mov bl,[si]
    add [di],bl
    inc si
    inc di
    mov bl,[si]
    add [di],bl
    inc si
    inc di
    
    add di,08h
    loop fixblockwhile1
    ret
fixblock endp

;1为不存在2，0为存在
ismoveok proc far c uses bx cx si di dx pbuff1:word
;计算存储地址
    mov di,pbuff1
    mov cx,0c0h
    mov ax,1
    mov bl,2h
;循环检测是否出现2
ismoveokwhile1:
    cmp [di],bl
    je ismoveokerror
    inc di
    loop ismoveokwhile1
    jmp ismovokexit
ismoveokerror:
    xor ax,ax
ismovokexit:
    ret
ismoveok endp



iserase proc far c uses bx cx si di dx pbuff1:word
    mov si,pbuff1
    mov cx,COL
iseraseloop1:
    invoke calnumber,si
    cmp ah,ROW
    je iseraseexit
    xor ax,ax
iseraseloop2:

    loop iseraseloop1
    ret
iserase endp

calnumber proc far c uses bx cx si di dx pbuff1:word
    mov si,pbuff1
    mov cx,ROW
    xor ax,ax
calnumberloop1:
    mov al,[si]
    add ah,al
    inc si
    loop calnumberloop1
    ret
calnumber endp

erasemap proc far c uses bx cx si di dx pbuff1:word,pbuff2:word




    ret
erasemap endp

isend proc far c uses bx cx si di dx pbuff1:word
    invoke calnumber,pbuff1
    cmp ah,2
    je isendexit
    invoke selectq
isendexit:
    ret
isend endp


mymemcpy proc far c uses bx cx si di dx pbuff1:word,pbuff2:word,nlength:word
    mov bx,ds
    mov es,bx
    mov di,pbuff1
    mov si,pbuff2
    mov cx,nlength
    cld 
    rep movsb
    ret
mymemcpy endp

;显示俄罗斯方块
showmap proc far c uses bx cx si di dx
    mov dx,offset g_outputmap
    mov cx,COL
showmapwhile1:
    mov bx,ROW

showmapwhile2:
    cmp bx,00h
    je showmapwhile2end
    invoke coutByte,dx
    inc dx
    dec bx
    jmp showmapwhile2

showmapwhile2end:
    invoke coutrn
    loop showmapwhile1
    ret
showmap endp

selecta proc far c uses bx cx si di dx
    mov si,offset pointxy
    mov bx,[si]
    ;向左移动
    dec bh
    mov [si],bx
    invoke mymemcpy,offset g_outputmap,offset g_map,0c0h
    invoke fixblock,offset g_outputmap
    invoke ismoveok,offset g_outputmap
    cmp ax,1
    je selectamoveok
    
    ;撤销操作
    inc bh
    mov [si],bx
    ;重新绘图
    invoke mymemcpy,offset g_outputmap,offset g_map,0c0h
    invoke fixblock,offset g_outputmap

selectamoveok:

    ret
selecta endp

selectd proc far c uses bx cx si di dx
    mov si,offset pointxy
    mov bx,[si]
    ;向左移动
    inc bh
    mov [si],bx
    invoke mymemcpy,offset g_outputmap,offset g_map,0c0h
    invoke fixblock,offset g_outputmap
    invoke ismoveok,offset g_outputmap
    cmp ax,1
    je selectamoveok
    
    ;撤销操作
    dec bh
    mov [si],bx
    ;重新绘图
    invoke mymemcpy,offset g_outputmap,offset g_map,0c0h
    invoke fixblock,offset g_outputmap

selectamoveok:

    ret
selectd endp

selects proc far c uses bx cx si di dx
    mov si,offset pointxy
    mov bx,[si]
    ;向下移动
    inc bl
    mov [si],bx
    invoke mymemcpy,offset g_outputmap,offset g_map,0c0h
    invoke fixblock,offset g_outputmap
    invoke ismoveok,offset g_outputmap
    cmp ax,1
    je selectsmoveok
    ;撤销操作
    dec bl
    mov [si],bx
    ;重新绘图
    invoke mymemcpy,offset g_outputmap,offset g_map,0c0h
    invoke fixblock,offset g_outputmap
    ;变成墙壁
    invoke mymemcpy,offset g_map,offset g_outputmap,0c0h
    mov bh,5h
    mov bl,0h
    mov [si],bx

    ;检测游戏是否结束
    invoeke isend,offset g_map

    ;检测是否消行
    invoke iserase,offset g_map
    cmp ax,0
    je continue
    invoke erasemap,offset g_map,ax

continue:
    ;设置新随机
    invoke setrandkind


;发生移动
selectsmoveok:
    ;无需操作，直接等待打印正确图形
    ret
selects endp

selectw proc far c uses bx cx si di dx
    mov si,offset randkind
    mov bx,[si]
    inc bl
    cmp bl,4
    jne seletewexit
    mov bl,0
seletewexit:
    mov [si],bx
    ret
selectw endp

selectq proc far c uses bx cx si di dx
    mov ah,4ch
    int 21h
    ret
selectq endp

code_seg ends
end START