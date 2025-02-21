#include "global.h"

int g_por = 0;
bool g_bb[1153][1980]  = {false};

void FUN_POR(void)
{
    PowerUp(3.3 DC_V, 1.2 DC_V);
	
	RUN_PATTERN("POR");
	LOAD_REGISTER(0x84,0x7306,0x1); //reg_ulpc
	
	g_pin_open = 0;
	g_por = 1;
}

void FUN_SLC_ERS(void)
{
    if(g_por == 0)
	{
		FUN_POR();
	}
	
	SML_REG_MPAT(CFLG1, 0); //enter slc mode
	RUN_PATTERN("ERS_ALL_MLT_PL");
	SML_GET_DUM(0, 495, dum);
	SML_GET_FBC_COUNTER(&fbc);
	
	DUT_LOOP(CDUT)
		int gbbcnt = 0;
		for(int blk = 0; blk < 495; blk++)
		{
			if((dum[blk].value[dut-1]&0xE0) != 0x00)
			{
				g_bb[dut][blk*4+0] = true;
				g_bb[dut][blk*4+1] = true;
				g_bb[dut][blk*4+2] = true;
				g_bb[dut][blk*4+3] = true;
				gbbcnt += 4;
			}
			else if((dum[blk].value[dut-1]&0x0F) != 0)
			{
				for (int plane = 0; plane < 4; plane++)
				{
					if(((dum[blk].value[dut-1]>>plane)&0x01) != 0)
					{
						g_bb[dut][blk*4+plane] = true;
						gbbcnt++;
					}
				}
			}
		}
		PrintLog("DUT%d GBB=%d POLLINGCOUNT=%d\n", dut, gbbcnt, fbc.value[dut-1]);
	DUT_LOOP_END
}

void FUN_SLC_PGM(void)
{	
    if(g_por == 0)
	{
		FUN_POR();
	}

//load data to C Latch
	int data;
	if(strstr(g_tname, "INV"))
	{
		data = 0xFFFF0000; //INVERSE
	}
	else if(strstr(g_tname, "ALL0"))
	{
		data = 0x00000000; //ALL0
	}
	else
	{
		data = 0x0000FFFF; //default
	}
	SML_REG_MPAT(TPH1, data);
	PrintLog("DATA: %08X\n", data);
	RUN_PATTERN("LOAD_PAGE_BUFFER");

//C Latch -> D2 Latch
	SML_REG_MPAT(TPH1, 0x000000D7); //pb operation
	SML_REG_MPAT(TPH2, 0x00000F12); //C Latch -> D2 Latch
	RUN_PATTERN("SET_FEATURE");

//SLC Program
	RUN_PATTERN("SLC_PGM_ALL_MLT_PL");
	SM_DUM *dum_slcpg = new SM_DUM[495*768]; //blk*slcpage = 380160
	SML_GET_DUM(0, 495*768, dum_slcpg);
	SML_GET_FBC_COUNTER(&fbc);
	
	DUT_LOOP(CDUT)
		int result[1980] = {0};
		int bpg		= 0;
		int bblk	= 0;
		int newbblk	= 0;
		for(int idx = 0; idx < 495*768; idx++)
		{
			if((dum_slcpg[idx].value[dut-1]&0xE0) != 0x00)
			{
				int blk = idx % 495;
				result[blk*4+0]++;
				result[blk*4+1]++;
				result[blk*4+2]++;
				result[blk*4+3]++;
			}
			else if((dum_slcpg[idx].value[dut-1]&0x0F) != 0)
			{
				int blk = idx % 495;
				for (int plane = 0; plane < 4; plane++)
				{
					if(((dum_slcpg[idx].value[dut-1]>>plane)&0x01) != 0)
					{
						result[blk*4+plane]++;
					}
				}
			}
		}
		for(int blk = 0; blk < 1980; blk++)
		{
			if(result[blk] != 0)
			{
				bpg += result[blk];
				bblk++;
				if(!g_bb[dut][blk])
				{
					newbblk++;
				}
			}
		}
		PrintLog("DUT%d NEWGBB=%d GBB=%d BADPAGE=%d POLLINGCOUNT=%d\n", dut, newbblk, bblk, bpg, fbc.value[dut-1]);
	DUT_LOOP_END
	delete[] dum_slcpg;
} 

void FUN_SLC_RD_ONEPAGE (void)
{	
    if(g_por == 0)
	{
		FUN_POR();
	}
	
	SML_REG_MPAT(Y, 100);
	SML_REG_MPAT(Z, 100);
	RUN_PATTERN("SLC_READ_MLT_PL_ONEPAGE");
	
	SM_DUM *dum_slcrd = new SM_DUM[4*18432]; //4plane*18432byte
	SML_GET_DUM(0, 4*18432, dum_slcrd);
#if 1 //printout
	DUT_LOOP(CDUT)
		PrintLog("=====DUT%d read out=====\nADDR 00000-00032:", dut);
		for(int i=0; i<32; i++)
		{
			PrintLog("%02X ",dum_slcrd[i].value[dut-1]);
		}
		PrintLog("\nADDR 73696-73728:");
		for(int i=73696; i<73728; i++)
		{
			PrintLog("%02X ",dum_slcrd[i].value[dut-1]);
		}
		PrintLog("\n");
	DUT_LOOP_END
#endif

	int mask;
	if(strstr(g_tname, "INV"))
	{
		mask = 0xFFFF0000; //INVERSE
	}
	else if(strstr(g_tname, "ALL0"))
	{
		mask = 0x00000000; //ALL0
	}
	else
	{
		mask = 0x0000FFFF; //default
	}
	
	DUT_LOOP(CDUT)
		int fbc[4] = {0};
		for(int plane=0; plane<4; plane++)
		{
			for(int bit=plane*18432*8; bit<(plane+1)*18432*8; bit++)
			{
				if( ((dum_slcrd[bit/8].value[dut-1]>>bit%8) ^ (mask>>bit%32)) & 0x01)
				{
					fbc[plane]++;
				}
			}
		}
		PrintLog("DUT%d FBC=%d,%d,%d,%d\n", dut, fbc[0], fbc[1], fbc[2], fbc[3]);
	DUT_LOOP_END
	delete[] dum_slcrd;
} 

void RUN_PATTERN(char* pattern)
{	
	SML_RESET_DUM_AREA(0xfffff,1);
	char label[16];
	int stpcnt = 0;
	
	PrintLog("Run\tPattern %s\n", pattern);
	SML_REG_MPATPC(pattern);	
	SML_REG_MPAT(CFLG31,1);//use new match mode
	SML_MEAS_MPAT_PARA(label);
	while(strlen(label) != 0)
	{
		int dutcnt = 0;
		DUT_LOOP(MDUT)
			dutcnt++;
		DUT_LOOP_END
		PrintLog("\tPattern stop %d times\tLabel %s\tFailed dut count %d\n", ++stpcnt, label, dutcnt);
		
		if(!strcmp(label, "JJJ"))
		{
			PrintLog("\tClose CFLG31\n");
			SML_REG_MPAT_PARA(CFLG31,0);
		}
		
		if(!strcmp(label, "SHOWREG"))
		{
			unsigned int acc;
			SML_READ_REGISTER_PARA(Q1,	&acc);	PrintLog("\tQ1 = %d\t",	acc);
			SML_READ_REGISTER_PARA(X,	&acc);	PrintLog("\tX = %d\t",	acc);
			SML_READ_REGISTER_PARA(Y,	&acc);	PrintLog("\tY = %d\t",	acc);
			SML_READ_REGISTER_PARA(Z,	&acc);	PrintLog("Z = %d\n",	acc);
		}		
		
		SML_MEAS_MPAT_PARA_RETURN(label);
	}
	PrintLog("\tPattern end\n");
	PATTERN_END_PRINT();
} 

void LOAD_REGISTER(int mode, int addr, int data)
{	
	SML_REG_MPAT(TPH1, mode);
	SML_REG_MPAT(TPH2, addr);
	SML_REG_MPAT(TPH3, data);
	RUN_PATTERN("LOAD_REGISTER");
	PrintLog("Load Register, ADDR %04X, data %d\n",addr, data);
} 

void PATTERN_END_PRINT()
{	
	SML_GET_DUM(0xfffff, 1, dum);
	SML_GET_FBC_COUNTER(&fbc);
	DUT_LOOP(CDUT)
		PrintLog("DUT%d POR SR=0x%2X POLLINGCOUNT=%d\n", dut, dum[0].value[dut-1]^0xE0, fbc.value[dut-1]);
	DUT_LOOP_END
} 