.586
.MODEL FLAT, C


; Funcions definides en C
printChar_C PROTO C, value:SDWORD
printInt_C PROTO C, value:SDWORD
clearscreen_C PROTO C
clearArea_C PROTO C, value:SDWORD, value1: SDWORD
printMenu_C PROTO C
gotoxy_C PROTO C, value:SDWORD, value1: SDWORD
getch_C PROTO C
printBoard_C PROTO C, value: DWORD
initialPosition_C PROTO C


TECLA_S EQU 115   ;ASCII letra s es el 115


.data          
teclaSalir DB 0




.code   
   
;;Macros que guardan y recuperan de la pila los registros de proposito general de la arquitectura de 32 bits de Intel    
Push_all macro
	
	push eax
   	push ebx
    push ecx
    push edx
    push esi
    push edi
endm


Pop_all macro

	pop edi
   	pop esi
   	pop edx
   	pop ecx
   	pop ebx
   	pop eax
endm
   
   
public C posCurScreenP1, getMoveP1, moveCursorP1, movContinuoP1, openP1, openContinuousP1
                         

extern C opc: SDWORD, row:SDWORD, col: BYTE, carac: BYTE, carac2: BYTE, sea: BYTE, taulell: BYTE, sunk: SDWORD, indexMat: SDWORD, tocat: SDWORD
extern C rowCur: SDWORD, colCur: BYTE, rowScreen: SDWORD, colScreen: SDWORD, RowScreenIni: SDWORD, ColScreenIni: SDWORD
extern C rowIni: SDWORD, colIni: BYTE, indexMatIni: SDWORD


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Situar el cursor en una fila i una columna de la pantalla
; en funció de la fila i columna indicats per les variables colScreen i rowScreen
; cridant a la funció gotoxy_C.
;
; Variables utilitzades: 
; Cap
; 
; Paràmetres d'entrada : 
; Cap
;    
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxy:
   push ebp
   mov  ebp, esp
    Push_all
   

   ; Quan cridem la funció gotoxy_C(int row_num, int col_num) des d'assemblador 
   ; els paràmetres s'han de passar per la pila
      
   mov eax,[colScreen]
   push eax
   mov eax,[rowScreen]
   push eax
   call gotoxy_C
   pop eax
   pop eax 
   
    Pop_all

   mov esp, ebp
   pop ebp
   ret




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar un caràcter, guardat a la variable carac
; en la pantalla en la posició on està  el cursor,  
; cridant a la funció printChar_C.
; 
; Variables utilitzades: 
; carac : variable on està emmagatzemat el caracter a treure per pantalla
; 
; Paràmetres d'entrada : 
; Cap
;    
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printch:
   push ebp
   mov  ebp, esp
   ;guardem l'estat dels registres del processador perqué
   ;les funcions de C no mantenen l'estat dels registres.
   
   
   Push_all
   

   ; Quan cridem la funció printch_C(char c) des d'assemblador, 
   ; el paràmetre (carac) s'ha de passar per la pila.
 
   xor eax,eax
   mov  al, [carac]
   push eax 
   call printChar_C
 
   pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret
   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat   
; cridant a la funció getch_C
; i deixar-lo a la variable carac2.
;
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el caracter llegit
;; 
; Paràmetres d'entrada : 
; Cap
;    
; Paràmetres de sortida: 
; El caracter llegit s'emmagatzema a la variable carac
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getch:
   push ebp
   mov  ebp, esp
    
   ;push eax
   Push_all

   call getch_C
   
   mov [carac2],al
   
   ;pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la pantalla, dins el tauler, en funció de
; les variables (row) fila (int) i (col) columna (char), a partir dels
; valors de les constants RowScreenIni i ColScreenIni.
; Primer cal restar 1 a row (fila) per a que quedi entre 0 i 7 
; i convertir el char de la columna (A..H) a un número entre 0 i 7.
; Per calcular la posició del cursor a pantalla (rowScreen) i 
; (colScreen) utilitzar aquestes fórmules:
; rowScreen=rowScreenIni+(row*2)
; colScreen=colScreenIni+(col*4)
; Per a posicionar el cursor cridar a la subrutina gotoxy.
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu sea
; col       : columna per a accedir a la matriu sea
; rowScreen : fila on volem posicionar el cursor a la pantalla.
; colScreen : columna on volem posicionar el cursor a la pantalla.
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
posCurScreenP1:
    push ebp
	mov  ebp, esp
	push eax
	mov  eax, [row]
	sub eax, 1
	shl eax, 1
	add eax, [rowScreenIni]
	mov [rowScreen], eax

	xor eax, eax

	mov al, [col]
	sub al, 65
	shl al, 2
	add eax, [colScreenIni]
	mov [colScreen], eax

	call gotoxy
	pop eax

	mov esp, ebp
	pop ebp
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat   
; cridant a la subrutina getch
; Verificar que solament es pot introduir valors entre 'i' i 'l', o la tecla espai
; i deixar-lo a la variable carac2.
; 
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el caracter llegit
; op: Variable que indica en quina opció del menú principal estem
; 
; Paràmetres d'entrada : 
; Cap
;    
; Paràmetres de sortida: 
; El caracter llegit s'emmagatzema a la variable carac2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getMoveP1:
   push ebp
   mov  ebp, esp

   push eax

getMoveP1start:

   call getch

   mov al, [carac2]

   cmp al, ' '
   je getMoveP1End

   cmp al, 's'
   je getMoveP1End

   cmp al, 'i'
   jl getMoveP1start

   cmp al,'l'
   jg getMoveP1start

getMoveP1End:

   pop eax
   mov esp, ebp
   pop ebp
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Actualitzar les variables (rowCur) i (colCur) en funció de 
; la tecla premuda que tenim a la variable (carac2)
; (i: amunt, j:esquerra, k:avall, l:dreta).
; Comprovar que no sortim del tauler, (rowCur) i (colCur) només poden 
; prendre els valors [1..8] i [0..7]. Si al fer el moviment es surt 
; del tauler, no fer el moviment.
; No posicionar el cursor a la pantalla, es fa a posCurScreenP1.
; 
; Variables utilitzades: 
; carac2 : caràcter llegit de teclat
;          'i': amunt, 'j':esquerra, 'k':avall, 'l':dreta
; rowCur : fila del cursor a la matriu sea.
; colCur : columna del cursor a la matriu sea.
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursorP1:
   push ebp
   mov  ebp, esp 

   push eax
   push ebx

   ;call getMoveP1 //NO HACE FALTA POR AHORA

   mov al, [carac2]


   cmp al, 'i'
   jne moveCursorP1falseI
   mov ebx, [rowCur]
   cmp ebx, 1
   je moveCursorP1end
   dec ebx
   mov [rowCur], ebx
   
   xor ebx, ebx
   jmp moveCursorP1end


  moveCursorP1falseI:
   cmp al, 'j'
   jne moveCursorP1falseJ
   mov bl, [colCur]
   cmp bl, 'A'
   jle moveCursorP1end
   dec bl
   mov [colCur], bl
   
   xor ebx, ebx
   jmp moveCursorP1end
   
   xor ebx, ebx
  moveCursorP1falseJ:
   cmp al,'k'
   jne moveCursorP1falseK
   mov ebx, [rowCur]
   cmp ebx, 8
   je moveCursorP1end
   inc ebx
   mov [rowCur], ebx
   
   xor ebx, ebx
   jmp moveCursorP1end

  moveCursorP1falseK:
   cmp al,'l'
   jne moveCursorP1falseK
   mov bl, [colCur]
   cmp bl, 'H'
   jge rightBorder
   inc bl
   mov [colCur], bl
   
   xor ebx, ebx
   jmp moveCursorP1End

   rightBorder:
   mov [colCur], 'H'

   moveCursorP1end:

   pop ebx
   pop eax

   mov esp, ebp
   pop ebp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continuo. 
;
; Variables utilitzades: 
;		carac2   : variable on s’emmagatzema el caràcter llegit
;		rowCur   : Fila del cursor a la matriu sea
;		colCur   : Columna del cursor a la matriu sea
;		row      : Fila per a accedir a la matriu sea
;		col      : Columna per a accedir a la matriu sea
; 
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
movContinuoP1:
	push ebp
	mov  ebp, esp
	push eax
	push ebx

	movContinuoLoop:

	call getMoveP1
	mov al, [carac2]
	
	cmp al, 's'
	je movContinuoLoopEnd

	cmp al, ' '
	je movContinuoLoopEnd


	call moveCursorP1

	mov eax, [rowCur]
	mov [row], eax
	xor eax, eax

	xor bl, bl
	mov bl, [colCur]
	mov [col], bl
	xor bl, bl

	call posCurScreenP1

	jmp movContinuoLoop

	movContinuoLoopEnd:

	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calcular l'índex per a accedir a les matrius en assemblador.
; sea[row][col] en C, és [sea+indexMat] en assemblador.
; on indexMat = row*8 + col (col convertir a número).
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu sea
; col       : columna per a accedir a la matriu sea
; indexMat	: índex per a accedir a la matriu sea
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calcIndexP1:
	push ebp
	mov  ebp, esp
	push eax
	push ebx
	;ponemos en indexMat el resultado de la operación row*8 + col
	mov eax, [row]
	dec eax
	shl eax, 3
	xor ebx, ebx
	mov bl, [col]
	sub bl, 'A'
	add eax, ebx

	mov [indexMat], eax


	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Obrim una casella de la matriu sea
; En primer lloc calcular la posició de la matriu corresponent a la
; posició que ocupa el cursor a la pantalla, cridant a la 
; subrutina calcIndexP1 i mostrar 'T' si hi ha un barco o 'O' si és aigua
; cridant a la subrutina printch. L'índex per a accedir
; a la matriu (sea) el calcularem cridant a la subrutina calcIndexP1.
; No es pot obrir una casella que ja tenim oberta.
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu sea
; rowCur	: fila actual del cursor a la matriu
; col       : columna per a accedir a la matriu sea
; colCur	: columna actual del cursor a la matriu
; indexMat	: Índex per a accedir a la matriu sea
; tocat		: indica si em tocat un vaixell
; sea		: Matriu 8x8 on tenim les posicions dels borcos. 
; carac		: caràcter per a escriure a pantalla.
; taulell   : Matriu en la que anem indicant els valors de les nostres tirades 
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openP1:
	push ebp
	mov  ebp, esp
	push eax
	push ebx
	push ecx

	call calcIndexP1

	mov ebx, [indexMat]
	mov al, [taulell + ebx]
	cmp al, ' '
	jne openP1NoAction
	
	xor ecx, ecx
	

	mov cl, 'O'
	mov [taulell + ebx], cl
	
	xor ecx, ecx
	mov cl, [sea + ebx]
	cmp cl, 0
	je openP1End
	
	xor ecx, ecx
	mov cl, 'T'
	mov [taulell + ebx], cl
	inc tocat

	openP1End:
	
	mov cl, [taulell + ebx]
	mov [carac], cl

	call printch

	openP1NoAction:

	pop ecx
	pop ebx
	pop eax

	mov esp, ebp
	pop ebp
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa l’obertura continua de caselles. S’ha d’utiliitzar
; la tecla espai per a obrir una casella i la 's' per a sortir. 
;
; Variables utilitzades: 
; carac2   : Caràcter introduït per l’usuari
; rowCur   : Fila del cursor a la matriu sea
; colCur   : Columna del cursor a la matriu sea
; row      : Fila per a accedir a la matriu sea
; col      : Columna per a accedir a la matriz sea
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openContinuousP1:
push ebp
	mov  ebp, esp
	push eax
	push ebx

	openContinuousLoop:

	call getMoveP1
	mov al, [carac2]
	
	cmp al, 's'
	je openContinuousLoopEnd

	cmp al, ' '
	jne movePos
	call openP1
	jmp OpenContinuousLoop

	movePos:
	call moveCursorP1

	mov eax, [rowCur]
	mov [row], eax
	xor eax, eax

	xor bl, bl
	mov bl, [colCur]
	mov [col], bl
	xor bl, bl

	call posCurScreenP1

	jmp openContinuousLoop

	openContinuousLoopEnd:

	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que comprova si un vaixell que hem tocat està enfonsat
; i en cas afirmatiu marca totes les caselles del vaixell amb una H 
;
; Variables utilitzades: 
;	carac		: Caràcter a imprimir per pantalla
;	rowCur		: Fila del cursor a la matriu sea
;	colCur		: Columna del cursor a la matriu sea
;	row			: Fila per a accedir a la matriu sea
;	col			: Columna per a accedir a la matriz sea
;	sea			: Matriu en la que tenim emmagatzemats el mapa i els bracos
;	indexMat	: Variable que indica la posició de la matriu sea a la que
;				  volem accedir
;	sunk		: Variable que indica si un barco ha estat enfonsat (1) o no (0)
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sunk_boat:
	push ebp
	mov  ebp, esp




	mov esp, ebp
	pop ebp
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que marca com aigua totes les caselles que envolten un 
; vaixell enfonsat 
;
; Variables utilitzades: 
;		carac    : Caràcter a imprimir per pantalla
;		rowCur   : Fila del cursor a la matriu sea
;		colCur   : Columna del cursor a la matriu sea
;		row      : Fila per a accedir a la matriu sea
;		col      : Columna per a accedir a la matriu sea
;		rowIni	 : Fila on hem fet la tirada
;		colIni	 : Columna on hem fet la tirada
;		sea		 : Matriu en la que tenim emmagatzemats el mapa i els bracos
;		indexMat : Variable que indica la posició on està emmagatzemada
;	               la cel·la de la matriu sea a la que volem accedir
;		indexMatIni: Variable que indica la posició on està emmagatzemada
;	                 la cel·la de la matriu sea a la que hem fet la tirada
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
border:
	push ebp
	mov  ebp, esp






	mov esp, ebp
	pop ebp
	ret

END
