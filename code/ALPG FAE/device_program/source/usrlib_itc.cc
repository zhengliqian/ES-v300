#include "global.h"


// Add ITC, global variable for flow
int g_Bin = 0;
int g_Rej = 0;

int dut;
int TD;
int STP;

SM_DUTINFO *dutinfo;

SM_FBC fbc;
SM_DUM dum[20000];
char   pm[20000];
SM_DC  dc[DUT_SIZE];
SM_VS  vs[DUT_SIZE];
SM_FCN fcn[DUT_SIZE];

char item[100];
char start_date[20];
char mpa[100];
char startPc[100];

float grand_start_time;
float grand_end_time;
float start_time;
float end_time;
float UNIT = 1.0;

void PIN_SET(void)
{
	SML_PD(PIN1, ON, IN2, I_NRZA,                    ACLK2,BCLK2,CCLK2, C1, HINIT);	// CE#
	SML_PD(PIN2, ON, IN1, I_RZO,                     ACLK1,BCLK1,CCLK1, C0, HINIT);	// CLK
	SML_PC(      ON, IN3, NRZA,  DRENRZ, OUT1, STRB, ACLK3,BCLK3,CCLK3, D0, OFF  );	// I/O
}

void PIN_FIXH(int sel)
{
	switch(sel){

	case 1  : SML_PD(PIN1, ON, IN1, FIXH,                      ACLK2,BCLK2,CCLK2, C1, HINIT);	// CE#
	          break;

	case 2  : SML_PD(PIN2, ON, IN1, FIXH,                      ACLK1,BCLK1,CCLK1, C0, HINIT);	// CLK
	          break;

	case 3  : SML_PC(      ON, IN1, FIXH,  DRENRZ, OUT1, STRB, ACLK3,BCLK3,CCLK3, D0, LINIT);	// I/O
	          break;

	default : SML_PD(PIN1, ON, IN1, FIXH,                      ACLK2,BCLK2,CCLK2, C1, HINIT);	// CE#
	          SML_PD(PIN2, ON, IN1, FIXH,                      ACLK1,BCLK1,CCLK1, C0, HINIT);	// CLK
	          SML_PC(      ON, IN1, FIXH,  DRENRZ, OUT1, STRB, ACLK3,BCLK3,CCLK3, D0, LINIT);	// I/O
	}
}

void PIN_FIXL(int sel)
{
	switch(sel){

	case 1  : SML_PD(PIN1, ON, IN1, FIXL,                      ACLK2,BCLK2,CCLK2, C1, HINIT);	// CE#
	          break;

	case 2  : SML_PD(PIN2, ON, IN1, FIXL,                      ACLK1,BCLK1,CCLK1, C0, HINIT);	// CLK
	          break;

	case 3  : SML_PC(      ON, IN1, FIXL,  DRENRZ, OUT1, STRB, ACLK3,BCLK3,CCLK3, D0, LINIT);	// I/O
	          break;

	default : SML_PD(PIN1, ON, IN1, FIXL,                      ACLK2,BCLK2,CCLK2, C1, HINIT);	// CE#
	          SML_PD(PIN2, ON, IN1, FIXL,                      ACLK1,BCLK1,CCLK1, C0, HINIT);	// CLK
	          SML_PC(      ON, IN1, FIXL,  DRENRZ, OUT1, STRB, ACLK3,BCLK3,CCLK3, D0, LINIT);	// I/O
	}
}

void PIN_OPEN(void)
{
	SML_PD(PIN1, OFF, IN1, FIXL,                      ACLK2,BCLK2,CCLK2, C1, HINIT);	// CE#
	SML_PD(PIN2, OFF, IN1, FIXL,                      ACLK1,BCLK1,CCLK1, C0, HINIT);	// CLK
	SML_PC(      OFF, IN1, FIXL,  DRENRZ, OUT1, STRB, ACLK3,BCLK3,CCLK3, D0, LINIT);	// I/O
}

void StdTim(void)
{
	UL_SML_RATE(   50 NS,100 NS,200 NS,500 NS,1000 NS,5000 NS,20000 NS,	50 NS);
	UL_SML_ACLK(1,  0 NS,  0 NS,  0 NS,  0 NS,   0 NS,   0 NS,    0 NS,  0 NS);
	UL_SML_BCLK(1,  0 NS,  0 NS,  0 NS,  0 NS,   0 NS,   0 NS,    0 NS,  0 NS);
	UL_SML_CCLK(1, 25 NS, 50 NS,100 NS,250 NS, 500 NS,2500 NS,10000 NS,	15 NS);
	UL_SML_ACLK(2,  0 NS,  0 NS,  0 NS,  0 NS,   0 NS,   0 NS,    0 NS,  0 NS);
	UL_SML_BCLK(2,  0 NS,  0 NS,  0 NS,  0 NS,   0 NS,   0 NS,    0 NS,  0 NS);
	UL_SML_CCLK(2, 25 NS, 50 NS,100 NS,250 NS, 500 NS,2500 NS,10000 NS, 15 NS);
	UL_SML_ACLK(3,  0 NS,  0 NS,  0 NS,  0 NS,   0 NS,   0 NS,    0 NS,  0 NS);
	UL_SML_BCLK(3,  0 NS,  0 NS,  0 NS,  0 NS,   0 NS,   0 NS,    0 NS,  0 NS);
	UL_SML_CCLK(3, 25 NS, 50 NS,100 NS,250 NS, 500 NS,2500 NS,10000 NS, 15 NS);
	UL_SML_DREL(    0 NS,  0 NS,  0 NS,  0 NS,   0 NS,   0 NS,    0 NS,  0 NS);
	UL_SML_DRET(    0 NS,  0 NS,  0 NS,  0 NS,   0 NS,   0 NS,    0 NS,  0 NS);
	UL_SML_STRB(   25 NS,150 NS,100 NS,250 NS, 500 NS,2500 NS,10000 NS, 40 NS); //timeset check
}

void ADDR_1(void)
{
	INN_SET_NAND(AS1,	X7,		X6,		X5,		X4,		X3,		X2,		X1,		X0);
	INN_SET_NAND(AS2,	L,		X14,	X13,	X12,	X11,	X10,	X9,		X8);
	INN_SET_NAND(AS3,	Y7,		Y6,		Y5,		Y4,		Y3,		Y2,		Y1,		Y0);
	INN_SET_NAND(AS4,	Z3,		Z2,		Z1,		Z0,		Y11,	Y10,	Y9,		Y8);
	INN_SET_NAND(AS5,	Z11,	Z10,	Z9,		Z8,		Z7,		Z6,		Z5,		Z4);
	INN_SET_NAND(AS6,	L,		L,		L,		L,		L,		L,		L,		Z12);
}


void TEST_INIT(void)
{
	char date[20];
	char OPTION[2048];

	SML_GDAY(start_date,0);
	SML_START_TIMER(R1MS);
	SML_READ_TIMER(&grand_start_time);
	start_time = grand_start_time;

	#ifdef LOGFILE
		#ifdef OPEMODE
			LogFileRemove("/home/test/sy/C/test/data");
			LogFileOpen  ("/home/test/sy/C/test/data");
		#else
			LogFileRemove("./");
			LogFileOpen  ("./");
		#endif
	#endif

	SML_GDAY(date, 0);			// YYYY/MM/DD HH:MM:SS
	PrintLog("[ ZCSET NAND Demo Program ] %s\n", date);


	SML_GET_OPTION(OPTION);
	PrintLog("OPTION : %s\n", OPTION);

	SML_SET_IDX_MODE(1);		// 0:+2_times 1:+1_times
	SML_SEND_MPAT("function");
	SML_RESET_DUM();
//	TestStart();
}

void TEST_END(void)
{
	SML_READ_TIMER(&grand_end_time);
	end_time = grand_end_time;
	PrintLog("Test time: %f\n", end_time - start_time);
	
	g_pin_open == 1;
	SML_SROF();	
}

#define SHOW 1
void START_MPAT(void)
{
	SML_REG_MPAT(CFLG31, 0);	// not use new_match

	#if SHOW
	Show_Reg_Mpat();
	PrintLog("\tSTART MPAT\n");
	#endif
	SML_START_MPAT();
}
void START_MPAT(int md)
{
	SML_REG_MPAT(CFLG31, 0);	// not use new_match

	#if SHOW
	Show_Reg_Mpat();
	PrintLog("\tSTART MPAT(%d)\n", md);
	#endif
	SML_START_MPAT(md);
}
void MEAS_MPAT(int use_new_match)
{
	#if SHOW
	Show_Reg_Mpat();
	PrintLog("\tMEAS MPAT(%d)\n", use_new_match);
	#endif

	#ifdef USE_NEW_MATCH
		NEW_MATCH_MEAS_MPAT(use_new_match);
	#else
		SML_MEAS_MPAT();
	#endif
}
void Show_Reg_Mpat(void)
{
	char         comment[256];
	int          tno;
	unsigned int acc;

	SML_GET_PART(ITEM, item);
	SML_GET_PART(COMMENT, comment);
	SML_READ_TEST_NO(&tno);			// bin

	PrintLog("\t////////////////////////////////////////////////////////\n");
	PrintLog("\tITEM         : %s\n", item);
	PrintLog("\tCOMMENT      : %s\n", comment);
	PrintLog("\tBin No       : %d\n", tno);
	PrintLog("\tPattern file : %s\n", mpa);
	PrintLog("\tPC           : %s\n", startPc);
	if(SML_GET_REG_MPAT(CFLG1,   &acc)) PrintLog("\tCFLG1  = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG2,   &acc)) PrintLog("\tCFLG2  = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG3,   &acc)) PrintLog("\tCFLG3  = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG4,   &acc)) PrintLog("\tCFLG4  = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG5,   &acc)) PrintLog("\tCFLG5  = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG6,   &acc)) PrintLog("\tCFLG6  = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG7,   &acc)) PrintLog("\tCFLG7  = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG8,   &acc)) PrintLog("\tCFLG8  = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG9,   &acc)) PrintLog("\tCFLG9  = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG10,  &acc)) PrintLog("\tCFLG10 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG11,  &acc)) PrintLog("\tCFLG11 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG12,  &acc)) PrintLog("\tCFLG12 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG13,  &acc)) PrintLog("\tCFLG13 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG14,  &acc)) PrintLog("\tCFLG14 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG15,  &acc)) PrintLog("\tCFLG15 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG16,  &acc)) PrintLog("\tCFLG16 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG17,  &acc)) PrintLog("\tCFLG17 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG18,  &acc)) PrintLog("\tCFLG18 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG19,  &acc)) PrintLog("\tCFLG19 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG20,  &acc)) PrintLog("\tCFLG20 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG21,  &acc)) PrintLog("\tCFLG21 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG22,  &acc)) PrintLog("\tCFLG22 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG23,  &acc)) PrintLog("\tCFLG23 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG24,  &acc)) PrintLog("\tCFLG24 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG25,  &acc)) PrintLog("\tCFLG25 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG26,  &acc)) PrintLog("\tCFLG26 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG27,  &acc)) PrintLog("\tCFLG27 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG28,  &acc)) PrintLog("\tCFLG28 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG29,  &acc)) PrintLog("\tCFLG29 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG30,  &acc)) PrintLog("\tCFLG30 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG31,  &acc)) PrintLog("\tCFLG31 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(CFLG32,  &acc)) PrintLog("\tCFLG32 = %d\n",           acc, acc);
	if(SML_GET_REG_MPAT(D1,      &acc)) PrintLog("\tD1     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(D2,      &acc)) PrintLog("\tD2     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(D3,      &acc)) PrintLog("\tD3     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(D4,      &acc)) PrintLog("\tD4     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(D5,      &acc)) PrintLog("\tD5     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(D6,      &acc)) PrintLog("\tD6     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(D7,      &acc)) PrintLog("\tD7     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(D8,      &acc)) PrintLog("\tD8     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(D9,      &acc)) PrintLog("\tD9     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(D10,     &acc)) PrintLog("\tD10    = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(D11,     &acc)) PrintLog("\tD11    = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(D12,     &acc)) PrintLog("\tD12    = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(D13,     &acc)) PrintLog("\tD13    = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(D14,     &acc)) PrintLog("\tD14    = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(D15,     &acc)) PrintLog("\tD15    = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(D16,     &acc)) PrintLog("\tD16    = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(X,       &acc)) PrintLog("\tX      = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(Y,       &acc)) PrintLog("\tY      = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(Z,       &acc)) PrintLog("\tZ      = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(TPH1,    &acc)) PrintLog("\tTPH1   = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(TPH2,    &acc)) PrintLog("\tTPH2   = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(TPH3,    &acc)) PrintLog("\tTPH3   = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(TPH4,    &acc)) PrintLog("\tTPH4   = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(TPH5,    &acc)) PrintLog("\tTPH5   = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(TPH6,    &acc)) PrintLog("\tTPH6   = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(TPH7,    &acc)) PrintLog("\tTPH7   = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(TPH8,    &acc)) PrintLog("\tTPH8   = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(TP,      &acc)) PrintLog("\tTP     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(Q1,      &acc)) PrintLog("\tQ1     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(Q2,      &acc)) PrintLog("\tQ2     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(Q3,      &acc)) PrintLog("\tQ3     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(Q4,      &acc)) PrintLog("\tQ4     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(Q5,      &acc)) PrintLog("\tQ5     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(Q6,      &acc)) PrintLog("\tQ6     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(Q7,      &acc)) PrintLog("\tQ7     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(Q8,      &acc)) PrintLog("\tQ8     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(MSTA,    &acc)) PrintLog("\tMSTA   = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(P1,      &acc)) PrintLog("\tP1     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(P2,      &acc)) PrintLog("\tP2     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(P3,      &acc)) PrintLog("\tP3     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(P4,      &acc)) PrintLog("\tP4     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(P5,      &acc)) PrintLog("\tP5     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(P6,      &acc)) PrintLog("\tP6     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(P7,      &acc)) PrintLog("\tP7     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(P8,      &acc)) PrintLog("\tP8     = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(PSTA,    &acc)) PrintLog("\tPSTA   = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(RDM,     &acc)) PrintLog("\tRDM    = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(MSKSTB,  &acc)) PrintLog("\tMSKSTB = 0x%08X\n"      , acc, acc);
	if(SML_GET_REG_MPAT(IDX1,    &acc)) PrintLog("\tIDX1   = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(IDX2,    &acc)) PrintLog("\tIDX2   = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(IDX3,    &acc)) PrintLog("\tIDX3   = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(IDX4,    &acc)) PrintLog("\tIDX4   = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(IDX5,    &acc)) PrintLog("\tIDX5   = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(IDX6,    &acc)) PrintLog("\tIDX6   = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(IDX7,    &acc)) PrintLog("\tIDX7   = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(IDX8,    &acc)) PrintLog("\tIDX8   = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(IDX9,    &acc)) PrintLog("\tIDX9   = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(IDX10,   &acc)) PrintLog("\tIDX10  = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(IDX11,   &acc)) PrintLog("\tIDX11  = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(IDX12,   &acc)) PrintLog("\tIDX12  = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(IDX13,   &acc)) PrintLog("\tIDX13  = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(IDX14,   &acc)) PrintLog("\tIDX14  = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(IDX15,   &acc)) PrintLog("\tIDX15  = 0x%08X\t(%d)\n", acc, acc);
	if(SML_GET_REG_MPAT(IDX16,   &acc)) PrintLog("\tIDX16  = 0x%08X\t(%d)\n", acc, acc);
	PrintLog("\t--------------------------------------------------------\n");
}

void GET_AFM(int x_st, int x_sp, int y_st, int y_sp, int z_st, int z_sp, int io_sel, int mut_c)
{
	SML_GET_AFM(&fbc, dum, x_st, x_sp, y_st, y_sp, z_st, z_sp, io_sel, mut_c);

	#if SHOW
		int size, sta;
		size = (x_sp - x_st + 1) * (y_sp - y_st + 1) * (z_sp - z_st + 1);
			     sta  = 0;
		if(z_st) sta  = (x_sp - x_st + 1) * (y_sp - y_st + 1) * z_st;
		if(y_st) sta += (x_sp - x_st + 1)                     * y_st;
		if(x_st) sta +=                                         x_st;

		PrintLog("\tSML_GET_DUM(&fbc, dum, %d,%d, %d,%d, %d,%d, 0x%02X, 0x%03X)\n", 
		                        &fbc, dum, x_st, x_sp, y_st, y_sp, z_st, z_sp, io_sel, mut_c);
		DUT_LOOP(EDUT)
		int cnt = 0;
		PrintLog("\tDUT : FBC = %d\n", fbc.value[dut-1]);

		for(int addr=sta; addr<size; addr++){
			PrintLog("\tDUT : %4d\taddr = %d\tdata = 0x%02X\n", dut, addr, dum[addr].value[dut-1]);
			cnt++;
			if(cnt > 7) break;
		}
		DUT_LOOP_END
		PrintLog("\n");
	#endif
}

void GET_DUM(int sta, int size)
{
	SML_GET_DUM(sta, size, dum);

	#if SHOW
		PrintLog("\tSML_GET_DUM(%d, %d, dum)\n", sta, size);
		DUT_LOOP(EDUT)
		int cnt = 0;
		for(int addr=sta; addr<size; addr++){
			PrintLog("\tDUT : %4d\taddr = %d\tdata = 0x%02X\n", dut, addr, dum[addr].value[dut-1]);
			cnt++;
			if(cnt > 7) break;
		}
		DUT_LOOP_END
		PrintLog("\n");
	#endif
}

void SET_DUM(int sta, int size)
{
	SML_SET_DUM(sta, size, dum);

	#if SHOW
		PrintLog("\tSML_SET_DUM(%d, %d, dum)\n", sta, size);
		DUT_LOOP(EDUT)
		int cnt = 0;
		for(int addr=sta; addr<size; addr++){
			PrintLog("\tDUT : %4d\taddr = %d\tdata = 0x%02X\n", dut, addr, dum[addr].value[dut-1]);
			cnt++;
			if(cnt > 7) break;
		}
		DUT_LOOP_END
		PrintLog("\n");
	#endif
}

void SET_PM(int sta, int size)
{
	SML_SET_PM(sta, size, pm);
	#if SHOW
	int cnt = 0;
		for(int addr=sta; addr<size; addr++){
			PrintLog("\tDUT : %4d\taddr = %d\tdata = 0x%02X\n", dut, addr, pm[addr]);
			cnt++;
			if(cnt > 7) break;
		}
		PrintLog("\n");
	#endif
}

void NEW_MATCH_MEAS_MPAT(int use_new_match)
{
	char label[256];

	unsigned int Xadd, Yadd, Zadd;
	unsigned int MSTAadd;
	int          Match_Fail_Process;
	int          FAIL_MATCH_DUT[DUT_SIZE+1];

	memset(FAIL_MATCH_DUT,0,sizeof(FAIL_MATCH_DUT));

	SML_REG_MPAT(CFLG31, use_new_match);
	SML_MEAS_MPAT_PARA(label);
	Match_Fail_Process = 0;
	while(strlen(label)){
	  if(!strcmp(label, "JJJ")){
	    SML_READ_REGISTER_PARA(X   , &Xadd);
	    SML_READ_REGISTER_PARA(Y   , &Yadd);
	    SML_READ_REGISTER_PARA(Z   , &Zadd);
	    SML_READ_REGISTER_PARA(MSTA, &MSTAadd);

	    DUT_LOOP(MFDUT)
	      FAIL_MATCH_DUT[dut] = 1;
	      PrintLog("\tJJJ:MFDUT=%4d,MPA=%s,StartPC=%s,X=0x%04x,Y=0x%04x,Z=0x%04x,MSTA=0x%05x\n",
	                        dut,    mpa,   startPc,   Xadd,    Yadd,    Zadd,    MSTAadd);
	      SML_SET_EXCLUSION(OFF, dut);
	      Match_Fail_Process = 1;
	    DUT_LOOP_END
	  }
	  else break;
	  SML_MEAS_MPAT_PARA_RETURN(label);
	}

	if(Match_Fail_Process){
	  DUT_LOOP(MDUT)
	    if(FAIL_MATCH_DUT[dut]){
	      SML_RESET_EXCLUSION(OFF,dut);
	      SML_SET_FUNC(dut);
	      PrintLog("\tDUT %4d : Match Fail << ",dut);
	      SML_SET_CATEGORY(dut, -1);
	      if(g_Rej){
	           SML_SET_REJECTION(dut);
	           PrintLog("REJECTED !!\n");
	      }
	      else PrintLog("\n");
	    }
	  DUT_LOOP_END
	}
}

void Read_Timer_End(int flg)
{
	int        tno;
	char       comment[256];
	SM_RESULT  result[DUT_SIZE];
	SML_READ_TEST_NO(&tno);
	SML_GET_PART    (COMMENT, comment);
	SML_READ_TIMER  (&end_time);

	// PrintFbin_AllDut
	
	//
	if(flg){
		SML_READ_RESULT(3, result);

		DUT_LOOP(MDUT)
			PrintLog("[D%04d] %-30s %4d ETT %10.0f      ",
			           dut, 
			           comment, 
			           tno, 
			           end_time - start_time );

			if(result[dut-1].pf){
			  PrintLog("F");
			  if(g_Rej){
			    SML_SET_REJECTION(dut);
			    PrintLog(": Rejected");
			  }
			}
			else PrintLog("P"); 
			PrintLog("\n");
		DUT_LOOP_END
	}
	PrintLog("\ntest time: %f\n",(end_time - start_time));
	#ifdef LOGPRINT
	fflush(stdout);
	#endif
}

void UL_SML_WAIT_TIME( float t ) 
{
	SML_WAIT_TIME( t *ITC_UNIT_CONV );
}

void UL_SML_VSIM( float vs , int vr , int ir , float c1 , float c2 ) 
{
	SML_VSIM( vs *ITC_UNIT_CONV , vr , ir , c1 *ITC_UNIT_CONV , c2 *ITC_UNIT_CONV );
}

void UL_SML_ISVM( float is , int ir , int vr , float c1 , float c2 ) 
{
	SML_ISVM( is *ITC_UNIT_CONV , ir , vr , c1 *ITC_UNIT_CONV , c2 *ITC_UNIT_CONV );
}

void UL_SML_VS( int onoff , float vs , int vr , int ir , float ip , float im ) 
{
	SML_VS( onoff , vs *ITC_UNIT_CONV , vr , ir , ip *ITC_UNIT_CONV , im *ITC_UNIT_CONV );
}

void UL_SML_LIMIT( int unit , float u , float l ) 
{
	SML_LIMIT( unit , u *ITC_UNIT_CONV , l *ITC_UNIT_CONV );
}

void UL_SML_IN( int n , float vih , float vil ) 
{
	SML_IN( n , vih *ITC_UNIT_CONV , vil *ITC_UNIT_CONV );
}

void UL_SML_OUT( int n , float voh , float vol )
{
	SML_OUT( n , voh *ITC_UNIT_CONV , vol *ITC_UNIT_CONV);
}

void UL_SML_TIME( int n, float t , int unit )
{
	SML_TIME( n, t *ITC_UNIT_CONV , unit );
}

void UL_SML_SROF( float t )
{
	SML_SROF( t *ITC_UNIT_CONV );
}

void UL_SML_ROF( float t , int unit ) 
{
	SML_ROF( t *ITC_UNIT_CONV , unit );
}

void UL_SML_RON( float t , int unit )
{
	SML_RON( t *ITC_UNIT_CONV , unit );
}

void UL_SML_READ_DC( SM_DC *dc )
{
	SML_READ_DC( dc );
	for(int dut=0; dut<DUT_SIZE; dut++) {
		dc[dut].ch1_value /= ITC_UNIT_CONV;
		dc[dut].ch2_value /= ITC_UNIT_CONV;
		dc[dut].ch3_value /= ITC_UNIT_CONV;
	}
}

void UL_SML_READ_VS( SM_VS *vs ) 
{
	SML_READ_VS( vs );
	for(int dut=0; dut<DUT_SIZE; dut++) {
		vs[dut].value /= ITC_UNIT_CONV;
	}
}

void UL_SML_MVM_WAIT(float t1, float t2)
{
	SML_MVM_WAIT( t1 *ITC_UNIT_CONV , t2 *ITC_UNIT_CONV );
}

void UL_SML_VSIM_WAIT(float t1, float t2)
{
	SML_VSIM_WAIT( t1 *ITC_UNIT_CONV , t2 *ITC_UNIT_CONV );
}

void UL_SML_ISVM_WAIT(float t1, float t2)
{
	SML_ISVM_WAIT( t1 *ITC_UNIT_CONV , t2 *ITC_UNIT_CONV );
}

void UL_SML_VS_WAIT(float t1)
{
	SML_VS_WAIT( t1 *ITC_UNIT_CONV );
}

void UL_SML_RATE(double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8)
{
	INN_RATE( ts1 *ITC_UNIT_CONV , ts2 *ITC_UNIT_CONV , ts3 *ITC_UNIT_CONV , ts4 *ITC_UNIT_CONV , ts5 *ITC_UNIT_CONV , ts6 *ITC_UNIT_CONV , ts7 *ITC_UNIT_CONV , ts8 *ITC_UNIT_CONV );
}

void UL_SML_ACLK(int id, double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8)
{
	INN_ACLK( id, ts1 *ITC_UNIT_CONV , ts2 *ITC_UNIT_CONV , ts3 *ITC_UNIT_CONV , ts4 *ITC_UNIT_CONV , ts5 *ITC_UNIT_CONV , ts6 *ITC_UNIT_CONV , ts7 *ITC_UNIT_CONV , ts8 *ITC_UNIT_CONV );
}

void UL_SML_BCLK(int id, double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8)
{
	INN_BCLK( id, ts1 *ITC_UNIT_CONV , ts2 *ITC_UNIT_CONV , ts3 *ITC_UNIT_CONV , ts4 *ITC_UNIT_CONV , ts5 *ITC_UNIT_CONV , ts6 *ITC_UNIT_CONV , ts7 *ITC_UNIT_CONV , ts8 *ITC_UNIT_CONV );
}

void UL_SML_CCLK(int id, double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8)
{
	INN_CCLK( id, ts1 *ITC_UNIT_CONV , ts2 *ITC_UNIT_CONV , ts3 *ITC_UNIT_CONV , ts4 *ITC_UNIT_CONV , ts5 *ITC_UNIT_CONV , ts6 *ITC_UNIT_CONV , ts7 *ITC_UNIT_CONV , ts8 *ITC_UNIT_CONV );
}

void UL_SML_DREL(double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8)
{
	INN_DREL( ts1 *ITC_UNIT_CONV , ts2 *ITC_UNIT_CONV , ts3 *ITC_UNIT_CONV , ts4 *ITC_UNIT_CONV , ts5 *ITC_UNIT_CONV , ts6 *ITC_UNIT_CONV , ts7 *ITC_UNIT_CONV , ts8 *ITC_UNIT_CONV );
}

void UL_SML_DRET(double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8)
{
	INN_DRET( ts1 *ITC_UNIT_CONV , ts2 *ITC_UNIT_CONV , ts3 *ITC_UNIT_CONV , ts4 *ITC_UNIT_CONV , ts5 *ITC_UNIT_CONV , ts6 *ITC_UNIT_CONV , ts7 *ITC_UNIT_CONV , ts8 *ITC_UNIT_CONV );
}

void UL_SML_STRB(double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8)
{
	INN_STRB( ts1 *ITC_UNIT_CONV , ts2 *ITC_UNIT_CONV , ts3 *ITC_UNIT_CONV , ts4 *ITC_UNIT_CONV , ts5 *ITC_UNIT_CONV , ts6 *ITC_UNIT_CONV , ts7 *ITC_UNIT_CONV , ts8 *ITC_UNIT_CONV );
}

void UL_SML_RATE(int ts, double t)
{
	SML_RATE( ts, t *ITC_UNIT_CONV );
}

void UL_SML_ACLK(int n, int ts, double t)
{
	SML_ACLK( n, ts, t*ITC_UNIT_CONV );
}

void UL_SML_BCLK(int n, int ts, double t)
{
	SML_BCLK( n, ts, t*ITC_UNIT_CONV );
}

void UL_SML_CCLK(int n, int ts, double t)
{
	SML_CCLK( n, ts, t*ITC_UNIT_CONV );
}

void UL_SML_DREL(int ts, double t)
{
	SML_DREL( ts, t*ITC_UNIT_CONV );
}

void UL_SML_DRET(int ts, double t)
{
	SML_DRET( ts, t*ITC_UNIT_CONV );
}

void UL_SML_STRB(int ts, double t)
{
	SML_STRB( ts, t*ITC_UNIT_CONV );
}
