
; NAME: MUHAMMAD ZOHAIB
; Roll Num: 24L-2530
; Section: BDS-3B

[org 0x0100]
jmp start
	pos: dw 330,346,540,470,780,1010,398,450,870,980
	orig: dw 330,346,540,470,780,1010,398,450,870,980  
	player: dw 3758
	oldisr: dd 0
	lives: dw 5
	livesPos: dw 154
	
	flag: dw 0
	bulletPos: dw 0
	bulletActive: dw 0
	score: dw 0
	bubblesLeft: dw 10
	speed: dw 3
	
	msg1: db 'You lost! Better luck next time!',0
	msg2: db 'Score: ',0
    msg3: db 'You won! Well played!',0
    msg4: db 'Final Score: ',0
    msg5: db '80s BUBBLE BLASTER',0
    msg6: db 'Lives: ',0


	bullDelay: dw 1
	bubDelay: dw 7

start:
	call installTimer
	call setup
  
    xor ax,ax
    mov es,ax
    mov ax,[es:9*4]
    mov [oldisr],ax
    mov ax,[es:9*4+2]
    mov [oldisr+2],ax
    
    cli
    mov word[es:9*4],kbisr
    mov [es:9*4+2],cs
    sti

	l2:
		cmp word[flag],1
		je finish
		
		dec word[bullDelay]
		jnz movBubb
		
		mov word[bullDelay],1
		cmp word[bulletActive],1
		jne movBubb
		call moveBullet
		
	movBubb:
		dec word[bubDelay]
		jnz noBubb
		mov word[bubDelay],7
		call movebubbles
	noBubb:
	    cmp word[flag],1
	    je finish
		call checkHit
		call delayLoop
		jmp l2
finish:
    cli
    mov ax,[oldisr]
    mov [es:9*4],ax
    mov ax,[oldisr+2]
    mov [es:9*4+2],ax
    sti
    mov ax,0x4c00
    int 0x21
stopTimer:
	push ax
	mov ax, 0
    mov es, ax
    mov ax, [oldisr]
    mov [es:8*4], ax
    mov ax, [oldisr+2]
    mov [es:8*4+2], ax
	pop ax
	ret
installTimer:
	push ax
	mov ax, 0
    mov es, ax
    
    mov ax, [es:8*4]
    mov [oldisr], ax
    mov ax, [es:8*4+2]
    mov [oldisr+2], ax
    
    cli
    mov word [es:8*4], timer
    mov [es:8*4+2], cs
    sti
	pop ax
	ret
setup:
	push ax
	call clrScr
	mov ax,0x1E00
	push ax
    mov ax,64
	push ax
	push msg5
	call displayStr
	mov ax,0x1E00
	push ax
    mov ax,132
	push ax
	push msg6
	call displayStr
	call extras
    call drawborder
    call drawplayer
    call drawbubbles
    mov ax,0x1E00
	push ax
    mov ax,4
	push ax
	push msg2
	call displayStr
	mov ax,18
	push ax
	push word[score]
	call printNum
	pop ax
	ret
timer:
	push ax
    push ds
    
    push cs
    pop ds
    
    dec word [speed]
	jnz skip
    
    mov word [speed], 1
	
	skip:
		mov al,0x20
		out 0x20,al
		pop ds
		pop ax
		iret
kbisr:
    push ax
	
    in al,0x60
	
    cmp al,0x01
    je endgame
	
    cmp al,0x4B
    je movLeft
	
    cmp al,0x4D
    je movRight
	
    cmp al,0x48
    je shootBull
	
    jmp done2

	endgame:
		mov word[flag],1
		jmp done2

	movLeft:
		call moveleft
		jmp done2

	movRight:
		call moveright
		jmp done2

	shootBull:
		call fireBullet
		
	done2:
		mov al,0x20
		out 0x20,al
		pop ax
		iret
fireBullet:
    push ax
    push di
    push es
	
	mov ax,0xB800
    mov es,ax
	
    cmp word[bulletActive],1
    je done3
   
    mov di,[player]
    sub di,160
    
    cmp di,160
    jl done3
    
    mov [bulletPos],di
    mov word[bulletActive],1
    mov ax,0x3F2A
    mov [es:di],ax
    
	done3:
		pop es
		pop di
		pop ax
		ret
moveBullet:
    push ax
    push di
    push es
    
    mov ax,0xB800
    mov es,ax
    mov di,[bulletPos]
    
    mov word[es:di],0x1020
    sub di,160
    
    cmp di,320
    jl hitUp
    
    call checkBulletHit
    cmp ax,1
    je bullethit
    
    mov ax,0x1F2A
    mov [es:di],ax
    mov [bulletPos],di
    jmp done4
    
	bullethit:
		mov word[bulletActive],0
		mov word[bulletPos],0
		jmp done4
    
	hitUp:
		mov word[bulletActive],0
		mov word[bulletPos],0
    
	done4:
		pop es
		pop di
		pop ax
		ret
checkBulletHit:
    push bx
    push cx
    push si
    push di
	push es
	
    mov ax,0xb800
	mov es,ax
	
    mov ax,0
    mov cx,10
    mov si,pos
    mov bx,[bulletPos]
    
	bullLoop:
		mov di,[si]
		cmp di,0
		je bulletnext
		cmp di,bx
		je bulletfound
		
	bulletnext:
		add si,2
		loop bullLoop
		jmp bulletnohit
		
	bulletfound:
		mov word[es:di],0x1020
		
		mov word[si],0
		inc word[score]
		dec word[bubblesLeft]
		
		mov di,18
		push di
		push word[score]
		call printNum
		
		cmp word[bubblesLeft],0
		jne bulletnotwin
		
		mov word[flag],1
		
		call boxPrint
		call win
		
	bulletnotwin:
		mov ax,1
		jmp done5
		
	bulletnohit:
		mov ax,0
	done5:
		pop es
		pop di
		pop si
		pop cx
		pop bx
		ret
win:
    push di
    push ax
    
    mov ax,0x1E00
    push ax
	mov di,2136
	push di
	push msg3
	call displayStr
	mov ax,0x1E00
	push ax
	mov di,2462
	push di
	push msg4
	call displayStr
	mov di,2488
	push di
	push word[score]
	call printNum
	
	pop ax
	pop di
	ret
printNum:
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push es
	
	mov ax,0xb800
	mov es,ax
	mov ax,[bp+4]
	mov bx,10
	mov di,[bp+6]
	mov cx,0
	loop4:
		mov dx,0
		div bx
		add dl,0x30
		push dx
		inc cx
		cmp ax,0
		jne loop4
	loop5:
		pop dx
		mov dh,0x1F
		mov [es:di],dx
		add di,2
		dec cx
		jnz loop5
	pop es
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 4
moveleft:
    push ax
    push di
    push es
    
    mov ax,0xb800
    mov es,ax
    mov di,[player]
    mov word[es:di],0x1020
    sub di,2
    
    cmp di,3680
    jge leftOk
    mov di,3680
    
	leftOk:
		mov ax,0x19DB
		mov [es:di],ax
		mov [player],di
    
    pop es
    pop di
    pop ax
    ret

moveright:
    push ax
    push di
    push es
    
    mov ax,0xb800
    mov es,ax
    mov di,[player]
    mov word[es:di],0x1020
    add di,2
    
    cmp di,3838
    jle rightOk
    mov di,3838
    
	rightOk:
		mov ax,0x1EDB
		mov [es:di],ax
		mov [player],di
    
    pop es
    pop di
    pop ax
    ret
checkHit:
    push ax
    push bx
    push cx
    push si
    push di
    push es
    
    mov ax,0xB800
    mov es,ax
	
    mov cx,10
    mov si,pos
    
    mov bx,[player]
    sub bx,160
    
	plyLoop:
		mov ax,[si]
		cmp ax,0
		je plyHit
		cmp ax,bx
		jne plyHit
		
		mov di,[livesPos]
		mov word[es:di],0x1020
		sub di,2
		mov [livesPos],di
		dec word[lives]
		jnz notZero
		
		mov word[flag],1
		call boxPrint
		call lose
		jmp done6
		
	notZero:
		mov ax,[si]
		mov di,ax
		mov word[es:di],0x1020
		
		push si
		push cx
		mov si,orig
		mov cx,10
		
	findorigin:
		cmp si,pos
		je originfound
		add si,2
		loop findorigin
	originfound:
		mov ax,[si]
		pop cx
		pop si
		mov [si],ax
	plyHit:
		add si,2
		cmp word[flag],0
	    jne done6
		call drawplayer
		loop plyLoop
	done6:
		pop es
		pop di
		pop si
		pop cx
		pop bx
		pop ax
		ret
lose:
    push di
    push ax
    
    mov ax,0x1E00
    push ax
	mov di,2128
	push di
	push msg1
	call displayStr
	mov ax,0x1E00
	push ax
	mov di,2462
	push di
	push msg4
	call displayStr
	mov di,2488
	push di
	push word[score]
	call printNum
	
	pop ax
	pop di
	ret
drawplayer:
    push ax
    push di
    push es
    
    mov ax,0xB800
    mov es,ax
	
    mov di,[player]
    mov ax,0x1EDB
    mov [es:di],ax
    
    pop es
    pop di
    pop ax
    ret
displayStr:
    push bp
    mov bp,sp
    push ax
    push si
    push di
    push es
    
    mov ax,0xB800
    mov es,ax
    mov di,[bp+6]
    mov si,[bp+4]
    mov ax,[bp+8]
	l1:
		mov al,[si]
		cmp al,0
		je done1
		mov [es:di],ax
		add di,2
		inc si
		jmp l1

	done1:
		pop es
		pop di
		pop si
		pop ax
		pop bp
		ret 6
drawborder:
    push ax
    push cx
	push si
    push di
    push es
    
    mov ax,0xb800
    mov es,ax
    
	cld
    mov cx,80
    mov di,160
    mov ax,0x19DB
    rep stosw
    
    mov cx,80
    mov di,3840
    mov ax,0x19DB
    rep stosw
    
    mov di,160
	mov si,318
    mov cx,24
    mov ax,0x19DB
	drawV:
		mov [es:di],ax
		add di,160
		mov [es:si],ax
		add si,160
		loop drawV
    
    mov di,[livesPos]
    mov cx,5
	
    pop es
    pop di
	pop si
    pop cx
    pop ax
    ret
extras:
    push ax
    push cx
    push di
    push es
    
    mov ax,0xb800
    mov es,ax
    
    mov di,[livesPos]
    mov cx,5
	
	drawLives:
		mov word[es:di],0x1403
		sub di,2
		loop drawLives
    
    mov di,56
	mov word[es:di],0x1C3C
	add di,2
	mov word[es:di],0x1C2D
	add di,2
	mov word[es:di],0x1C3E
	
	mov di,102
	mov word[es:di],0x1C3C
	add di,2
	mov word[es:di],0x1C2D
	add di,2
	mov word[es:di],0x1C3E
	
	pop es
	pop di
	pop cx
	pop ax
	ret
boxPrint:
	push ax
	push cx
	push si
	push di
	push es
	
	call clrScr
	call drawborder
	mov ax,0xb800
	mov es,ax
	
	mov di,1640
	mov si,2760
	mov ax,0x1FCD
	mov cx,40
	l5:
		mov [es:di],ax
		add di,2
		mov [es:si],ax
		add si,2
		loop l5
	
	mov si,di
	mov di,1640
	mov ax,0x1FBA
	mov cx,8
	l6:
		mov [es:di],ax
		add di,160
		mov [es:si],ax
		add si,160
		loop l6
	pop es
	pop di
	pop si
	pop cx
	pop ax
	ret
movebubbles:
    push ax
    push bx
    push cx
    push si
    push di
    push es
    
    mov ax,0xb800
    mov es,ax
    mov ax,0x1A4F
    mov si,pos
    mov bx,orig
    mov cx,10

	bubLoop:
		mov di,[si]
		cmp di,0
		je skip1
		
		mov word[es:di],0x1020
		add di,160
		
		cmp di,3680
		jl bubbledraw
		
		mov di,[bx]
	bubbledraw:
		mov [es:di],ax
		mov [si],di
		
	skip1:
		add si,2
		add bx,2
		loop bubLoop
    
    pop es
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret
delayLoop:
    push cx
    push dx
	
    mov cx,0x0060
	l3:
		mov dx,0x100

		l4:
			nop
			dec dx
			jnz l4
		dec cx
		jnz l3
		
    pop dx
    pop cx
    ret
drawbubbles:
    push ax
    push cx
    push si
    push di
    push es
    
    mov ax,0xb800
    mov es,ax
    mov ax,0x1A4F
    mov si,pos
    mov cx,10

	drawLoop:
		mov di,[si]
		cmp di,0
		je skip2
		mov [es:di],ax
	skip2:
		add si,2
		loop drawLoop
    
    pop es
    pop di
    pop si
    pop cx
    pop ax
    ret
clrScr:
    push ax
    push cx
    push di
    push es
    
    mov ax,0xb800
    mov es,ax
    
    cld
    mov di,0
    mov cx,2000
    mov ax,0x1020
    rep stosw
    
    pop es
    pop di
    pop cx
    pop ax
    ret