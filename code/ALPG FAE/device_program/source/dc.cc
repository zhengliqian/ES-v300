#include "global.h"

void DC_OPEN_SHORT (void)
{
    SM_VS vs[1153];	
	SM_DC dc[1153];

	SML_VS(OFF, 0 DC_V, R4V, M2MA, 2 DC_MA, -2 DC_MA); 
	PIN_OPEN();
	
	SML_TIME(1, 1 MS, VS);
	SML_VS(ON, 0.5 DC_V, R4V, M2MA, 2 DC_MA, -2 DC_MA); //UNIT mV, mA
    SML_LIMIT(VS, 200.0 DC_UA, 5.0 DC_UA);//UNIT mA
	SML_SRON();
    SML_MEAS_VS();
    SML_READ_VS(&vs[1]);
	SML_SROF();
	PrintLog("VSS Force 0.5V, Limit 5-200UA\n");
	
	SML_WAIT_TIME(100 MS);
    
	SML_TIME(1, 1 MS, DC);
    SML_ISVM(-100 DC_UA, R200UA, M10V, 1 DC_V, -1 DC_V);  // Unit is mV
    SML_LIMIT(DC, -100 DC_MV, -900 DC_MV);  // Unit is mV
	SML_SRON();
    SML_MEAS_DC(PIN1|PIN2|PIN3);
    SML_READ_DC(&dc[1]);
	SML_SROF();
	PrintLog("DRV Force -100uA, limit -0.9~-0.1V\n");
	
	DUT_LOOP(CDUT)
		PrintLog("DUT%d\tVSS  %4.3f uA\t%s\n", dut, vs[dut].value/1000, vs[dut].pf     == PASS ? "PASS" : "FAIL");
		PrintLog("DUT%d\tPIN1 %4.3f mV\t%s\n", dut, dc[dut].ch1_value,  dc[dut].ch1_pf == PASS ? "PASS" : "FAIL");
		PrintLog("DUT%d\tPIN2 %4.3f mV\t%s\n", dut, dc[dut].ch2_value,  dc[dut].ch2_pf == PASS ? "PASS" : "FAIL");
		PrintLog("DUT%d\tPIN3 %4.3f mV\t%s\n", dut, dc[dut].ch3_value,  dc[dut].ch3_pf == PASS ? "PASS" : "FAIL");
	DUT_LOOP_END
}

void DC_LEAKAGE (void)
{	
	SM_DC dc_L[1153],dc_H[1153];
	
	SML_VS(ON, 3.65 DC_V, R4V, M200MA, 200 DC_MA, -200 DC_MA);
	SML_IN(1, 1.26 DC_V, 0 DC_V); //chanel number
	SML_TIME(1, 1 MS, VS);
	SML_TIME(2, 1 MS, DAC);
	SML_TIME(3, 2 MS, DC);
	
	SML_LIMIT(DC, 10 DC_UA, -10 DC_UA);	
//IXL
	PIN_FIXH(0);
	SML_VSIM(0 DC_V, R10V, M200UA, 200 DC_UA, -200 DC_UA);
	SML_SRON();
    SML_MEAS_DC(PIN1|PIN2|PIN3);
    SML_READ_DC(&dc_L[1]);
	SML_SROF();

	SML_WAIT_TIME(100 MS);
	
//IXH
	PIN_FIXL(0);
	SML_VSIM(1.26 DC_V, R10V, M200UA, 200 DC_UA, -200 DC_UA);
	SML_SRON();
    SML_MEAS_DC(PIN1|PIN2|PIN3);
    SML_READ_DC(&dc_H[1]);
	SML_SROF();
	
	PrintLog("VCC Force 3.65V, DRV FORCE 0V~1.26V, limit +-10UA\n");
	
	DUT_LOOP(CDUT)
		PrintLog("DUT%d\tPIN1 IXL %4.3f uA\tIXH %4.3f uA\t%s\n", 
				dut, dc_L[dut].ch1_value*1000, dc_H[dut].ch1_value*1000,
				(dc_L[dut].ch1_pf == PASS)&&(dc_H[dut].ch1_pf == PASS)? "PASS" : "FAIL");
		PrintLog("DUT%d\tPIN1 IXL %4.3f uA\tIXH %4.3f uA\t%s\n", 
				dut, dc_L[dut].ch2_value*1000, dc_H[dut].ch2_value*1000,
				(dc_L[dut].ch2_pf == PASS)&&(dc_H[dut].ch2_pf == PASS)? "PASS" : "FAIL");
		PrintLog("DUT%d\tPIN1 IXL %4.3f uA\tIXH %4.3f uA\t%s\n", 
				dut, dc_L[dut].ch3_value*1000, dc_H[dut].ch3_value*1000,
				(dc_L[dut].ch3_pf == PASS)&&(dc_H[dut].ch3_pf == PASS)? "PASS" : "FAIL");
	DUT_LOOP_END
} 

void DC_ICC_GROSS (void)
{	
	SM_VS vs[1153];
	
	SML_VS(ON, 3.65 DC_V, R4V, M2MA, 200 DC_MA, -200 DC_MA);
	SML_IN(1, 1.26 DC_V, 0 DC_V);
	SML_IN(2, 1.26 DC_V, 0 DC_V);
	SML_IN(3, 1.26 DC_V, 0 DC_V);
	PIN_FIXL(1); //1:CE,2:CLK,3:DQ
	PIN_FIXH(2);
	PIN_FIXL(3);
	SML_TIME(1, 1 MS, VS);
	SML_TIME(2, 1 MS, DAC);
	SML_TIME(3, 2 MS, DC);
	
	SML_LIMIT(VS, 4 DC_MA, -5 DC_UA);	

	SML_SRON();
    SML_MEAS_VS();
    SML_READ_VS(&vs[1]);
	SML_SROF();
	
	PrintLog("VCC Force 3.65V, CE/WE/DQ FORCE 0V/1.26V/0V, limit -5~4000UA\n");
	
	DUT_LOOP(CDUT)
		PrintLog("DUT%d\tICC_GROSS\t%4.3f uA\t%s\n", dut, vs[dut].value/1000, vs[dut].pf     == PASS ? "PASS" : "FAIL");
	DUT_LOOP_END
} 

void DC_ICC_STANDBY (void)
{	
	SM_VS vs[1153];
	
	PowerUp(3.65 DC_V,1.26 DC_V);
	SML_LIMIT(VS, 500 DC_UA, -5 DC_UA);	

    SML_MEAS_VS();
    SML_READ_VS(&vs[1]);
	SML_SROF();
	
	PrintLog("VCC Force 3.65V, CE/WE/DQ 0~1.26V, limit -5~500UA\n");
	
	DUT_LOOP(CDUT)
		PrintLog("DUT%d\tICC_STANDBY\t%4.3f uA\t%s\n", dut, vs[dut].value/1000, vs[dut].pf     == PASS ? "PASS" : "FAIL");
	DUT_LOOP_END
} 

void PowerUp (float vcc, float vccq)
{	
	PrintLog("PowerUp\tVCC=%1.2f V,VCCQ=%1.2f V\n", vcc/1000, vccq/1000);
	SML_VS(ON, vcc, R4V, M2MA, 200 DC_MA, -200 DC_MA);
	SML_IN(1, vccq,   0 DC_V);
	SML_IN(2, vccq,   0 DC_V);
	SML_IN(3, vccq,   0 DC_V);
	SML_OUT(1, vccq/2, vccq/2);
	SML_OUT(2, vccq/2, vccq/2);
	SML_OUT(3, vccq/2, vccq/2);
	SML_TIME(1, 1 MS, VS);
	SML_TIME(2, 1 MS, DAC);
	SML_TIME(3, 2 MS, DC);
	
	StdTim();
	ADDR_1();
	PIN_SET();
	
	SML_PCON(ON);
	SML_SRON();
} 