;��λ���ݶ����ʶ��---�û��Լ������λ���� 

	SMG0	BIT		P0.3	;��λ�����
	SMG1	BIT		P0.2	;ʮλ�����
	SMG2	BIT		P0.1	;��λ�����
	SMG3	BIT		P0.0	;ǧλ�����

	DAT		BIT		P0.7	;SER
	RST		BIT		P0.6	;G'
	RCK		BIT		P0.5	;RCK
	SCK		BIT		P0.4	;SRCK

	; �����ж�
	ORG 0013H ;�����ж�1��ڵ�ַ
	LJMP MAIN3
	ORG 0003H ;�����ж�0��ڵ�ַ
	LJMP MAIN4
	
	ORG 0000H
	SJMP 	MAIN1

	ORG 0030H

;----------------------------------------------------------------------
;------------------����1���������ʾLION ------------------------------
;----------------------------------------------------------------------

MAIN1: 
	 SETB EX1			 ;�����ж�1�ж�
	 SETB IT1			 ;�½��ش���
	 SETB PX1	
	 MOV SCON,#50H		 ;������ʽ2����������
		
	 SETB EA				 ;����ȫ���ж�
	 SETB EX0			 ;�����ж�1�ж�
	 SETB IT0			 ;�½��ش���
	 SETB PX0	
	 MOV SCON,#50H		 ;������ʽ2���������� 

	 MOV     SP,#60H   ;ջָ�룬���б���������
	 MOV     R4,#18   ;'n'����
	 ACALL   LIGHT   ;�����ӳ�����������ź�
	 SETB    SMG0   ;Ƭѡ��λ
	 ACALL   S_DELAY   ;������ʱ�������ʾ����
	
	 MOV     R4,#00      ;'0'����
	 ACALL   LIGHT      ;�����ӳ�����������ź�
	 SETB    SMG1      ;Ƭѡʮλ
	 ACALL   S_DELAY      ;������ʱ�������ʾ����
	
	 MOV     R4,#01   ;'1'����
	 ACALL   LIGHT   ;�����ӳ�����������ź�
	 SETB    SMG2   ;Ƭѡ��λ
	 ACALL   S_DELAY   ;������ʱ�������ʾ����
	
	 MOV     R4,#17   ;'L'����
	 ACALL   LIGHT   ;�����ӳ�����������ź�
	 SETB    SMG3   ;Ƭѡǧλ
	 ACALL   S_DELAY   ;������ʱ�������ʾ����

	 MOV     R4,#00H
	 ACALL   KB
	 CJNE 	 R4,#00H,MAIN2
	 SJMP    MAIN1   ;ѭ����ʾ
	 RETI

	
MAIN2:
	
   	MOV     SP,#60H		    ;ջָ�룬���б���������
	MOV     R4,#22         	;��ʼ��ʾ'.'����


;----------------------------------------------------------------------
;------------------����3��������̹�����ʾ---------------------------------
;----------------------------------------------------------------------


;������ʾ
SCR0LL_LIGHT:			
	LCALL   KB		;�����ӳ����жϰ��������ڲ���R4
	ACALL   LIGHT			;�����ӳ�����ڲ���R4,��������ź�
	SETB    SMG3			;Ƭѡǧλ
	MOV     R5,#02			;��ʱ����
	ACALL   L_DELAY			;��ʱ����������Ч��
	
	LCALL   KB		;�����ӳ����жϰ��������ڲ���R4	
	ACALL   LIGHT			;�����ӳ�����ڲ���R4,��������ź�
	SETB    SMG2			;Ƭѡ��λ
	MOV     R5,#02			;��ʱ����
	ACALL   L_DELAY			;��ʱ����������Ч��

	LCALL   KB		;�����ӳ����жϰ��������ڲ���R4
	ACALL   LIGHT			;�����ӳ�����ڲ���R4,��������ź�
	SETB    SMG1			;Ƭѡʮλ
	MOV     R5,#02			;��ʱ����
	ACALL   L_DELAY			;��ʱ����������Ч��

	LCALL   KB		;�����ӳ����жϰ��������ڲ���R4
	ACALL   LIGHT			;�����ӳ�����ڲ���R4,��������ź�
	SETB    SMG0			;Ƭѡ��λ
	MOV     R5,#02			;��ʱ����
	ACALL   L_DELAY			;��ʱ����������Ч��

	SJMP    SCR0LL_LIGHT	;ѭ������
	RETI


;----------------------------------------------------------------------
;------------------����4���Է����մ���ͨ��-----------------------------
;----------------------------------------------------------------------


MAIN3:
	MOV TH1,#0F3H	 	 ;װ�붨ʱ����
	MOV TL1,#0F3H
	MOV TMOD,#20H	     ;��ʱ��1���Զ���װ��ֵģʽ
	MOV PCON,#80H 		 ;�����ʼӱ�
	MOV SCON,#50H	   ;��ʽ2
	SETB	 TR1
		
	LCALL SEND			 ;��ȡ����ֵ������
	LCALL REC		   	 ;����	
LIGHT_3:	ACALL   LIGHT			;�����ӳ�����ڲ���R4,��������ź�
	SETB    SMG3			;Ƭѡǧλ
	MOV     R5,#02			;��ʱ����
	ACALL   L_DELAY			;��ʱ
	LJMP    LIGHT_3	  	  ;ѭ��
	RETI 

SEND:
	LCALL KB 		   ;��ȡ���󰴼���ֵ 
	MOV A,R4
	MOV SBUF,A			 ;����
	JNB TI,$             ;���ͱ�־��ti=0ʱδ���ͣ�ti=1ʱ���ͣ��ȴ��ж�
	CLR RI               ;���㣬���·���
	RET

REC:
	MOV A,SBUF			  ;����
	JNB RI,$			  ;�����жϱ�־��RI=0ʱδ���գ�ri=1ʱ���ͣ��ȴ��ж�             
	MOV R4,A
	RET	  	

;��ʱ�ӳ���
;time=(((R3*2)+3)*R2+3)*1us
L_DELAY:
	;�ɵ����ȳ���ʱ���������R5:����ʱ����
	ACALL   M_DELAY
	DJNZ    R5,L_DELAY								 
M_DELAY:
	;����ʱ��time=0.131s
    MOV     R2,#0FFH
	SJMP    DELAY0
S_DELAY:				   
    	;����ʱ������ȥ����time=12.828ms
	MOV     R2,#19H
DELAY0:
    MOV     R3,#0FFH
DELAY1:
    DJNZ    R3,DELAY1
	DJNZ    R2,DELAY0
	RET

;�����źų���
;��ڲ���R4������	 
LIGHT:	 	
  	CLR		SMG0			;λѡ��Ч���������
	CLR		SMG1
	CLR		SMG2
	CLR		SMG3

    MOV	    A,R4			
    ACALL	SMGDIP
	RET

;��ʾ�ӳ����ܣ������������
;��ڲ�����A����ʾ����
;�����ʾ�ַ�
SMGDIP:	
    MOV	    DPTR,#SMGTAB
	MOVC	A,@A+DPTR		;������õ���ʾ���ֵĶ���ֵ
    CLR		RST			    ; ���ʹ��
	MOV	    R2,#8           ;�ܴ���λ��
    ;��������SN74HC595
SER: 	
    RLC     A 	 			;���ݴ���λѭ�����ƣ���λΪ��Чλ
	MOV	    DAT,C	  		;��λ�������ݿ�
	CLR		SCK				;��������ʱ���½���
	SETB    SCK				;��������ʱ���Ͻ��أ�Ŀ��ʹ���ݴ�����λ�Ĵ���
	DJNZ	R2,SER
	CLR		RCK				;����ʱ���½���
	SETB	RCK				;����ʱ���Ͻ��أ�Ŀ�Ĵ��������������
	RET					    ;�ӳ������


;----------------------------------------------------------------------
;------------------����2���������ʶ��---------------------------------
;----------------------------------------------------------------------



;���������ӳ�������ܣ��������жϼ���
;���ڲ���R4�����̱�ţ�0~f)
;-------����������ж��ձ�--------
;      P2.0    P2.1    P2.2    P2.3
;P2.7 S16(0)  S12(1)  S08(2)  S04(3)
;P2.6 S15(4)  S11(5)  S07(6)  S03(7)
;P2.5 S14(8)  S10(9)  S06(A)  S02(B)
;P2.4 S13(C)  S09(D)  S05(E)  S01(F)
KB:
	MOV 	P2,#0F0H        ;�����ͳ�ȫ0�ź�
	MOV     A,P2            ;��ȡ����ֵ
	ANL     A,#0F0H         ;��ԭ״̬���룬��������A����
	CJNE    A,#0F0H,K1		;Aֵ�仯���м��룬�������˳��ӳ���
	RET
K1:
    LCALL   S_DELAY         ;��ʱ�ӳ���ȥ����
	MOV     P2,#0F0H        ;�����ٴ��ͳ�ȫ0�ź�
	MOV     A,P2            ;�ٴζ�ȡ����ֵ
	ANL     A,#0F0H         ;�ٴ���ԭ״̬����
	CJNE    A,#0F0H,K2		;Aֵ�仯�����ȶ�����
	RET
K2:
    MOV     R5,A            ;��������ֵ
	MOV 	P2,#0FH         ;�����ͳ�ȫ0�ź�
	MOV     A,P2            ;��ȡ����ֵ
K3:
	ORL     A,R5            ;������ȡ�ü�ֵ
	MOV     B,A             ;�ݴ��ֵ
K4:
	MOV     A,P2			;��ȡ����ֵ
	CJNE    A,#0FH,K4      ;�жϼ��Ƿ��ͷţ����ͷ����������
K5:
    LCALL   S_DELAY         ;��ʱ�ӳ���ȥ����
	MOV     A,P2			;�ٴζ�ȡ����ֵ
	CJNE    A,#0FH,K4      ;�ٴζ�ȡ����ֵȷ�ϰ������ȶ��ͷ�
K6:
	MOV     R6,#15          ;ʮ������������ֵ
	MOV     R4,#0			;����ָ��
	MOV     DPTR,#KEYTAB	;װ�����������ж��ձ�ͷ
K7:
    MOV     A,R4            ;ָ�븳ֵ��A
	MOVC    A,@A+DPTR		;������ֵ�����������ж��ձ�Ƚ�
	CJNE    A,B,K8         ;ֵ����ͬ�����´αȽ�
	AJMP    K9             ;��ת�ӳ������
K8:
	INC     R4               ;����ָ������
	DJNZ    R6,K7          ;δָ�����һλ�������һ�αȽ�
K9:
    RET                     ;�ӳ������


;----------------------------------------------------------------------
;------------------����4������Զ˴���ͨ��-----------------------------
;----------------------------------------------------------------------
MAIN4:	
	
	MOV TMOD,#20H	     ;��ʱ��1���Զ���װ��ֵģʽ4800bit/s
	MOV SCON,#50H	     ;��ʽ2
	MOV PCON,#80H 		 ;�����ʼӱ�
	MOV TH1,#0F3H	 	 ;װ�붨ʱ����
	MOV TL1,#0F3H

	SETB	 TR1

	MOV R1,#00
SEND_4:
	MOV A,R1    
	MOV DPTR,#TELEPHONE_NUMBER
	MOVC A,@A+DPTR
	;MOV B,A
	;LCALL K6_4
	;MOV A,R4
	CLR TI
	MOV SBUF,A			 ;����
	JNB TI,$             ;���ͱ�־��ti=0ʱδ���ͣ�ti=1ʱ���ͣ��ȴ��ж�	
	INC R1		  
	CJNE R1,#11,SEND_4               ;����11����ת
	LJMP G1

;������ʾ
G1:
	MOV R0,#10
GUN_PRINT:
	MOV A,R0     
	MOV DPTR,#TELEPHONE_NUMBER
	MOVC A,@A+DPTR

	MOV B,A
	LCALL K6_4

	ACALL   LIGHT			;�����ӳ�����ڲ���R4,��������ź�
	SETB    SMG3			;Ƭѡǧλ
	MOV     R5,#02			;��ʱ����
	ACALL   L_DELAY			;��ʱ����������Ч�� 
	
	
	MOV A,R0  
	MOV DPTR,#TELEPHONE_NUMBER   
	MOVC A,@A+DPTR
	MOV B,A
	LCALL K6_4
	ACALL   LIGHT			;�����ӳ�����ڲ���R4,��������ź�
	SETB    SMG2			;Ƭѡ��λ
	MOV     R5,#02			;��ʱ����
	ACALL   L_DELAY			;��ʱ����������Ч��


	
	MOV A,R0 
	MOV DPTR,#TELEPHONE_NUMBER    
	MOVC A,@A+DPTR
	MOV B,A
	LCALL K6_4
	ACALL   LIGHT			;�����ӳ�����ڲ���R4,��������ź�
	SETB    SMG1			;Ƭѡʮλ
	MOV     R5,#02			;��ʱ����
	ACALL   L_DELAY			;��ʱ����������Ч��

	
	MOV A,R0    
	MOV DPTR,#TELEPHONE_NUMBER
	MOVC A,@A+DPTR
	MOV B,A
	LCALL K6_4
	ACALL   LIGHT			;�����ӳ�����ڲ���R4,��������ź�
	SETB    SMG0			;Ƭѡ��λ
	MOV     R5,#02			;��ʱ����
	ACALL   L_DELAY			;��ʱ����������Ч��

	DEC R0					;ȡ��һ������
	CJNE R0,#00H,GUN_PRINT
	LJMP G1

K6_4:
	MOV     R6,#15          ;ʮ������������ֵ
	MOV     R4,#0			;����ָ��
	MOV     DPTR,#SMGTAB	;װ�����������ж��ձ�ͷ
K7_4:
    MOV     A,R4            ;ָ�븳ֵ��A
	MOVC    A,@A+DPTR		;������ֵ�����������ж��ձ�Ƚ�
	CJNE    A,B,K8_4         ;ֵ����ͬ�����´αȽ�
	AJMP    K9_4             ;��ת�ӳ������
K8_4:
	INC     R4               ;����ָ������
	DJNZ    R6,K7_4          ;δָ�����һλ�������һ�αȽ�
K9_4:
    RET                     ;�ӳ������

;�绰��
TELEPHONE_NUMBER:
	DB 06H,5BH,4FH,66H,6DH,7DH
	DB 07H,06H,5BH,4FH,66H

TELEPHONE:	
    DB  3FH,06H,5BH,4FH,66H,6DH,7DH,07H	  ;0(00),1(01),2(02),3(03),4(04),5(05),6(06),7(07)
	DB  7FH,67H,77H,7CH,39H,5EH,79H,71H	  ;8(08),9(09),A(10),B(11),C(12),D(13),E(14),F(15)

;����ܶ����
SMGTAB:	
  	DB  3FH,06H,5BH,4FH,66H,6DH,7DH,07H	  ;0(00),1(01),2(02),3(03),4(04),5(05),6(06),7(07)
	DB  7FH,67H,77H,7CH,39H,5EH,79H,71H	  ;8(08),9(09),A(10),B(11),C(12),D(13),E(14),F(15)
	DB  76H,38H,37H,3EH,73H,5CH,80H,40H	  ;H(16),L(17),n(18),u(19),P(20),o(21),.(22),-(23)

;����������ж��ձ�	
KEYTAB:					        ;   7	B	 D	  E
    DB  077H,07BH,07DH,07EH     ;7  (0)  (1)  (2)  (3) 
	DB  0B7H,0BBH,0BDH,0BEH	   	;B (4)  (5)	(6)	 (7)
	DB  0D7H,0DBH,0DDH,0DEH	  	 ;D (8)  (9)	(A)	 (B)
	DB  0E7H,0EBH,0EDH,0EEH	  	 ;E (C)  (D)	(E)	 (F)

END

	  