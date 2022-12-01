;给位数据定义标识符---用户自己定义的位名称 

	SMG0	BIT		P0.3	;个位数码管
	SMG1	BIT		P0.2	;十位数码管
	SMG2	BIT		P0.1	;百位数码管
	SMG3	BIT		P0.0	;千位数码管

	DAT		BIT		P0.7	;SER
	RST		BIT		P0.6	;G'
	RCK		BIT		P0.5	;RCK
	SCK		BIT		P0.4	;SRCK

	; 配置中断
	ORG 0013H ;串行中断1入口地址
	LJMP MAIN3
	ORG 0003H ;串行中断0入口地址
	LJMP MAIN4
	
	ORG 0000H
	SJMP 	MAIN1

	ORG 0030H

;----------------------------------------------------------------------
;------------------功能1：数码管显示LION ------------------------------
;----------------------------------------------------------------------

MAIN1: 
	 SETB EX1			 ;允许中断1中断
	 SETB IT1			 ;下降沿触发
	 SETB PX1	
	 MOV SCON,#50H		 ;工作方式2，接收允许
		
	 SETB EA				 ;允许全局中断
	 SETB EX0			 ;允许中断1中断
	 SETB IT0			 ;下降沿触发
	 SETB PX0	
	 MOV SCON,#50H		 ;工作方式2，接收允许 

	 MOV     SP,#60H   ;栈指针，此行保留不更改
	 MOV     R4,#18   ;'n'段码
	 ACALL   LIGHT   ;调用子程序，输出亮灯信号
	 SETB    SMG0   ;片选个位
	 ACALL   S_DELAY   ;加入延时，提高显示亮度
	
	 MOV     R4,#00      ;'0'段码
	 ACALL   LIGHT      ;调用子程序，输出亮灯信号
	 SETB    SMG1      ;片选十位
	 ACALL   S_DELAY      ;加入延时，提高显示亮度
	
	 MOV     R4,#01   ;'1'段码
	 ACALL   LIGHT   ;调用子程序，输出亮灯信号
	 SETB    SMG2   ;片选百位
	 ACALL   S_DELAY   ;加入延时，提高显示亮度
	
	 MOV     R4,#17   ;'L'段码
	 ACALL   LIGHT   ;调用子程序，输出亮灯信号
	 SETB    SMG3   ;片选千位
	 ACALL   S_DELAY   ;加入延时，提高显示亮度

	 MOV     R4,#00H
	 ACALL   KB
	 CJNE 	 R4,#00H,MAIN2
	 SJMP    MAIN1   ;循环显示
	 RETI

	
MAIN2:
	
   	MOV     SP,#60H		    ;栈指针，此行保留不更改
	MOV     R4,#22         	;初始显示'.'段码


;----------------------------------------------------------------------
;------------------功能3：矩阵键盘滚动显示---------------------------------
;----------------------------------------------------------------------


;滚动显示
SCR0LL_LIGHT:			
	LCALL   KB		;调用子程序，判断按键，出口参数R4
	ACALL   LIGHT			;调用子程序，入口参数R4,输出亮灯信号
	SETB    SMG3			;片选千位
	MOV     R5,#02			;延时次数
	ACALL   L_DELAY			;延时，产生滚动效果
	
	LCALL   KB		;调用子程序，判断按键，出口参数R4	
	ACALL   LIGHT			;调用子程序，入口参数R4,输出亮灯信号
	SETB    SMG2			;片选百位
	MOV     R5,#02			;延时次数
	ACALL   L_DELAY			;延时，产生滚动效果

	LCALL   KB		;调用子程序，判断按键，出口参数R4
	ACALL   LIGHT			;调用子程序，入口参数R4,输出亮灯信号
	SETB    SMG1			;片选十位
	MOV     R5,#02			;延时次数
	ACALL   L_DELAY			;延时，产生滚动效果

	LCALL   KB		;调用子程序，判断按键，出口参数R4
	ACALL   LIGHT			;调用子程序，入口参数R4,输出亮灯信号
	SETB    SMG0			;片选个位
	MOV     R5,#02			;延时次数
	ACALL   L_DELAY			;延时，产生滚动效果

	SJMP    SCR0LL_LIGHT	;循环滚动
	RETI


;----------------------------------------------------------------------
;------------------功能4：自发自收串口通信-----------------------------
;----------------------------------------------------------------------


MAIN3:
	MOV TH1,#0F3H	 	 ;装入定时常数
	MOV TL1,#0F3H
	MOV TMOD,#20H	     ;定时器1，自动重装初值模式
	MOV PCON,#80H 		 ;波特率加倍
	MOV SCON,#50H	   ;方式2
	SETB	 TR1
		
	LCALL SEND			 ;读取按键值，发送
	LCALL REC		   	 ;接收	
LIGHT_3:	ACALL   LIGHT			;调用子程序，入口参数R4,输出亮灯信号
	SETB    SMG3			;片选千位
	MOV     R5,#02			;延时次数
	ACALL   L_DELAY			;延时
	LJMP    LIGHT_3	  	  ;循环
	RETI 

SEND:
	LCALL KB 		   ;获取矩阵按键的值 
	MOV A,R4
	MOV SBUF,A			 ;发送
	JNB TI,$             ;发送标志，ti=0时未发送，ti=1时发送，等待中断
	CLR RI               ;清零，重新发送
	RET

REC:
	MOV A,SBUF			  ;接收
	JNB RI,$			  ;接收中断标志，RI=0时未接收，ri=1时发送，等待中断             
	MOV R4,A
	RET	  	

;延时子程序
;time=(((R3*2)+3)*R2+3)*1us
L_DELAY:
	;可调长度长延时，参数入口R5:中延时次数
	ACALL   M_DELAY
	DJNZ    R5,L_DELAY								 
M_DELAY:
	;中延时，time=0.131s
    MOV     R2,#0FFH
	SJMP    DELAY0
S_DELAY:				   
    	;短延时，用于去抖，time=12.828ms
	MOV     R2,#19H
DELAY0:
    MOV     R3,#0FFH
DELAY1:
    DJNZ    R3,DELAY1
	DJNZ    R2,DELAY0
	RET

;亮灯信号程序
;入口参数R4：段码	 
LIGHT:	 	
  	CLR		SMG0			;位选无效，关数码管
	CLR		SMG1
	CLR		SMG2
	CLR		SMG3

    MOV	    A,R4			
    ACALL	SMGDIP
	RET

;显示子程序功能：段码送数码管
;入口参数：A：显示数字
;查表显示字符
SMGDIP:	
    MOV	    DPTR,#SMGTAB
	MOVC	A,@A+DPTR		;查段码表得到显示数字的段码值
    CLR		RST			    ; 输出使能
	MOV	    R2,#8           ;总传输位数
    ;串行输入SN74HC595
SER: 	
    RLC     A 	 			;数据带进位循环左移，进位为有效位
	MOV	    DAT,C	  		;进位传入数据口
	CLR		SCK				;数据输入时钟下降沿
	SETB    SCK				;数据输入时钟上降沿，目的使数据存入移位寄存器
	DJNZ	R2,SER
	CLR		RCK				;锁存时钟下降沿
	SETB	RCK				;锁存时钟上降沿，目的传入锁存器，输出
	RET					    ;子程序出口


;----------------------------------------------------------------------
;------------------功能2：矩阵键盘识别---------------------------------
;----------------------------------------------------------------------



;键盘输入子程序程序功能：反极法判断键入
;出口参数R4：键盘编号（0~f)
;-------矩阵键盘行列对照表--------
;      P2.0    P2.1    P2.2    P2.3
;P2.7 S16(0)  S12(1)  S08(2)  S04(3)
;P2.6 S15(4)  S11(5)  S07(6)  S03(7)
;P2.5 S14(8)  S10(9)  S06(A)  S02(B)
;P2.4 S13(C)  S09(D)  S05(E)  S01(F)
KB:
	MOV 	P2,#0F0H        ;列线送出全0信号
	MOV     A,P2            ;读取行线值
	ANL     A,#0F0H         ;与原状态相与，若无输入A不变
	CJNE    A,#0F0H,K1		;A值变化则有键入，不变则退出子程序
	RET
K1:
    LCALL   S_DELAY         ;延时子程序去抖动
	MOV     P2,#0F0H        ;列线再次送出全0信号
	MOV     A,P2            ;再次读取行线值
	ANL     A,#0F0H         ;再次与原状态相与
	CJNE    A,#0F0H,K2		;A值变化则有稳定键入
	RET
K2:
    MOV     R5,A            ;记下行线值
	MOV 	P2,#0FH         ;行线送出全0信号
	MOV     A,P2            ;读取列线值
K3:
	ORL     A,R5            ;或运算取得键值
	MOV     B,A             ;暂存键值
K4:
	MOV     A,P2			;读取列线值
	CJNE    A,#0FH,K4      ;判断键是否释放，若释放则继续程序
K5:
    LCALL   S_DELAY         ;延时子程序去抖动
	MOV     A,P2			;再次读取列线值
	CJNE    A,#0FH,K4      ;再次读取列线值确认按键已稳定释放
K6:
	MOV     R6,#15          ;十六键查表计数初值
	MOV     R4,#0			;计数指针
	MOV     DPTR,#KEYTAB	;装入矩阵键盘行列对照表头
K7:
    MOV     A,R4            ;指针赋值给A
	MOVC    A,@A+DPTR		;将按键值与矩阵键盘行列对照表比较
	CJNE    A,B,K8         ;值不相同跳入下次比较
	AJMP    K9             ;跳转子程序出口
K8:
	INC     R4               ;计数指针自增
	DJNZ    R6,K7          ;未指向最后一位则进入下一次比较
K9:
    RET                     ;子程序出口


;----------------------------------------------------------------------
;------------------功能4：与电脑端串口通信-----------------------------
;----------------------------------------------------------------------
MAIN4:	
	
	MOV TMOD,#20H	     ;定时器1，自动重装初值模式4800bit/s
	MOV SCON,#50H	     ;方式2
	MOV PCON,#80H 		 ;波特率加倍
	MOV TH1,#0F3H	 	 ;装入定时常数
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
	MOV SBUF,A			 ;发送
	JNB TI,$             ;发送标志，ti=0时未发送，ti=1时发送，等待中断	
	INC R1		  
	CJNE R1,#11,SEND_4               ;等于11，跳转
	LJMP G1

;滚动显示
G1:
	MOV R0,#10
GUN_PRINT:
	MOV A,R0     
	MOV DPTR,#TELEPHONE_NUMBER
	MOVC A,@A+DPTR

	MOV B,A
	LCALL K6_4

	ACALL   LIGHT			;调用子程序，入口参数R4,输出亮灯信号
	SETB    SMG3			;片选千位
	MOV     R5,#02			;延时次数
	ACALL   L_DELAY			;延时，产生滚动效果 
	
	
	MOV A,R0  
	MOV DPTR,#TELEPHONE_NUMBER   
	MOVC A,@A+DPTR
	MOV B,A
	LCALL K6_4
	ACALL   LIGHT			;调用子程序，入口参数R4,输出亮灯信号
	SETB    SMG2			;片选百位
	MOV     R5,#02			;延时次数
	ACALL   L_DELAY			;延时，产生滚动效果


	
	MOV A,R0 
	MOV DPTR,#TELEPHONE_NUMBER    
	MOVC A,@A+DPTR
	MOV B,A
	LCALL K6_4
	ACALL   LIGHT			;调用子程序，入口参数R4,输出亮灯信号
	SETB    SMG1			;片选十位
	MOV     R5,#02			;延时次数
	ACALL   L_DELAY			;延时，产生滚动效果

	
	MOV A,R0    
	MOV DPTR,#TELEPHONE_NUMBER
	MOVC A,@A+DPTR
	MOV B,A
	LCALL K6_4
	ACALL   LIGHT			;调用子程序，入口参数R4,输出亮灯信号
	SETB    SMG0			;片选个位
	MOV     R5,#02			;延时次数
	ACALL   L_DELAY			;延时，产生滚动效果

	DEC R0					;取下一个号码
	CJNE R0,#00H,GUN_PRINT
	LJMP G1

K6_4:
	MOV     R6,#15          ;十六键查表计数初值
	MOV     R4,#0			;计数指针
	MOV     DPTR,#SMGTAB	;装入矩阵键盘行列对照表头
K7_4:
    MOV     A,R4            ;指针赋值给A
	MOVC    A,@A+DPTR		;将按键值与矩阵键盘行列对照表比较
	CJNE    A,B,K8_4         ;值不相同跳入下次比较
	AJMP    K9_4             ;跳转子程序出口
K8_4:
	INC     R4               ;计数指针自增
	DJNZ    R6,K7_4          ;未指向最后一位则进入下一次比较
K9_4:
    RET                     ;子程序出口

;电话表
TELEPHONE_NUMBER:
	DB 06H,5BH,4FH,66H,6DH,7DH
	DB 07H,06H,5BH,4FH,66H

TELEPHONE:	
    DB  3FH,06H,5BH,4FH,66H,6DH,7DH,07H	  ;0(00),1(01),2(02),3(03),4(04),5(05),6(06),7(07)
	DB  7FH,67H,77H,7CH,39H,5EH,79H,71H	  ;8(08),9(09),A(10),B(11),C(12),D(13),E(14),F(15)

;数码管段码表
SMGTAB:	
  	DB  3FH,06H,5BH,4FH,66H,6DH,7DH,07H	  ;0(00),1(01),2(02),3(03),4(04),5(05),6(06),7(07)
	DB  7FH,67H,77H,7CH,39H,5EH,79H,71H	  ;8(08),9(09),A(10),B(11),C(12),D(13),E(14),F(15)
	DB  76H,38H,37H,3EH,73H,5CH,80H,40H	  ;H(16),L(17),n(18),u(19),P(20),o(21),.(22),-(23)

;矩阵键盘行列对照表	
KEYTAB:					        ;   7	B	 D	  E
    DB  077H,07BH,07DH,07EH     ;7  (0)  (1)  (2)  (3) 
	DB  0B7H,0BBH,0BDH,0BEH	   	;B (4)  (5)	(6)	 (7)
	DB  0D7H,0DBH,0DDH,0DEH	  	 ;D (8)  (9)	(A)	 (B)
	DB  0E7H,0EBH,0EDH,0EEH	  	 ;E (C)  (D)	(E)	 (F)

END

	  