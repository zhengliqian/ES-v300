/*-----------------------------------------------------------------------------------
				File name:		userlib.h

				Contents:		user sel-define functions declaration

				Revision:	 2012.12.07

				Last modified:  Freeting

------------------------------------------------------------------------------------*/

#ifndef _USERLIB_H
#define _USERLIB_H

#if 0
#define NA    *1e-9
#define UA    *1e-6
#define MA    *1e-3
#define  A    *1.0
#define UV    *1e-6
#define MV    *1e-3
#define  V    *1.0

#define NS    *1e-9
#define US    *1e-6
#define MS    *1e-3
#define  S    *1.0
#endif

#define ONE_PASS_PROGRAM 0
#define TWO_PASS_PROGRAM 1
#define THREE_PASS_PROGRAM 2


#define PASS     0
#define FAIL     1
#define NOTTEST  -1

#define IDXI_1    1
#define IDXI_2    2
#define IDXI_3    3
#define IDXI_4    4
#define IDXI_5    5
#define IDXI_6    6
#define IDXI_7    7
#define IDXI_8    8

#define MATCH_CYCLE_TIME    (1000 NS) 
#define NO_SETTING	999     
typedef unsigned long long int DUT_MASK;

extern int g_debug_print;

#define DebugPrintf(fmt, ...)   DebugPrintf_(__func__, __LINE__, fmt, ##__VA_ARGS__)
#define ErrorPrintf(fmt, ...)   ErrorPrintf_(__func__, __LINE__, fmt, ##__VA_ARGS__)

#if 0
void ulCreatePinListWithNumber(char *plst, int type, int num);
void ulCreatePinListWithList(char *plst, int type, ...);

void ulConfigFcm(char *pinlist, int xbit, int ybit);
void ulConfigFcmMMA(char *pinlist, int xbit, int ybit);
void ulConfigFcmByXYListMMA(char *pinlist, char *x_list, char *y_list);
void ulWriteFcm(void *data, int size, int x_st, int x_sp, int y_st, int y_sp, int dut);
#endif
void ulReadFcm(void *data, int size, int x_st, int x_sp, int y_st, int y_sp, int dut);
#if 0
void ulReadFcm_for_pgm(void *data, int size, int block_start_bit, int page_shift_bit, int x_st, int x_sp, int y_st, int y_sp, int dut);
void ulReadFcm_for_rdmlc(void *data, int size, int block_shift_bit, int x_st, int x_sp, int y_st, int y_sp, int dut);
void ulDisableFcm(void);
void ulPresetFcm(int data);
void ulPresetFcmAll(int data);
#endif
void ulSerialTestStart();
void ulSerialTestEnd();
int  ulIsSerialTest();
int ulGetUbmAllDutFlag();
#if 0
void ulConfigBbmMaskMode(int x_bitsize, int y_bitsize);
void ulWriteBbm(void *data, int size, int xwidth, int ywidth, int dut);
void ulReadBbm(void *data, int size, int xwidth, int ywidth, int dut);
void ulPresetBbm(void);
void ulDisableBbm(void);
void ulWriteUbmExInit(char *pinlist, unsigned int *data, int size,int dut);
void ulWriteUbmExTransferByDut(int group,int dut);
void ulWriteUbmExTransferAllDut(int group);
void ulUbmExProcess(FctHandle h);
void ulConfigUbm(char *pinlist, RadioButton fs, int func_select_cbit, int jump_select_cbit,int jmpaddr); //fs = UT_UBM_UNIT_PM / UT_UBM_UNIT_SCRESULTMEMORY
void ulConfigUbm_PwUp(char *pinlist, RadioButton fs, int func_select_cbit, int jump_select_cbit, int jmpaddr);
void ulDisableUbm(void);
void ulConfigUbmDrPat(char *pinlist, int func_select_cbit, int jump_select_cbit);
void ulConfigUbmCpExp(char *pinlist, int func_select_cbit, int jump_select_cbit);
void ulConfigUbmCpExpJmp(char *pinlist, int func_select_cbit, int jump_select_cbit, int jmp_addr);
void ulWriteUbm(char *pinlist, unsigned int *data, int size,int dut);
void ulWriteUbm2(char *pinlist, unsigned int *data, int size,int dut);
void ulReadUbm(char *pinlist, unsigned int *data, int size,int dut);
void ulPresetUbm(USlider data);
void ulWriteUbm_AllDut(char *pinlist, USlider *data, int size);
void ulWriteUbm2_AllDut(char *pinlist, USlider *data, int size);

void ulOpenPin(char *pinlist);
void ulOpenPin2(char *pinlist, int onoff);

int ulGetFailCount(int dut, int x_start, int x_end, int y_start, int y_end, int io_num);
void ulGetFailCountPfc(int x_start, int x_end, int y_start, int y_end, int io_num, USlider *count); //171211

int ulRefreshMeasResult(int dut, int x_start, int x_end, int y_start, int y_end);

int ReadFKStatus(int fknum);
#endif
double ReadLapTimer(int id);
void   StartLapTimer(int id);
double ReadAccumulatedLapTimer(int id);


void Disable_Debug_Print ();
void Enable_Debug_Print ();
void ErrorPrintf_(const char *func, int line, const char *fmt, ...);
void WarnPrintf(const char *fmt, ...);
void BBPrintf(const char *fmt, ...);
void TimerPrintf(const char *fmt, ...);
void DebugPrintf_(const char *func, int line, const char *fmt, ...);
void LogPrintf(const char *fmt, ...);
void TcmPrintf(const char *buf, const char *fmt, ...);
#if 0
void PMU_Measure_Delay(double time);

int ReadFk(int *array);
void Pause2(char *fmt, ...);
void Pause(char *fmt, ...);
int ulAppendUbmSerialData(unsigned int* ubmdata, int orgdata, int size, int bitdata);

void ulFlashConfig(int limit, RadioButton control_bit, RadioButton cbit);
int ulReadFlashCounter(int dut);
void ulFlashDisable();
void JudgePollingFail(int blk); //0219
#endif
void SetDutsExclusion (DUT_MASK dut_mask);
#if 0
void ResetDutsExclusion (DUT_MASK dut_mask);

void ulSetAccessFcm(FcmAccessHandle h, int x_st, int x_sp, int y_st, int y_sp);
void ulOnlyReadFcm(FcmAccessHandle h,void *data, int size, int x_st, int x_sp, int y_st, int y_sp, int dut);

extern int FK[20];
extern unsigned int BIX_TABLE[];



extern double ReadDctLatestPinData();
extern double ReadDctPinData(int pin);
extern double ReadDctVsData();
extern void MeasDct(int h);
extern void MeasFct(int h);
extern void StartFct(int h);
extern void OnPowerSeq();
extern void OffPowerSeq();
extern void WaitTime(double t);
extern void PrintTcmPin();
extern void PrintTcmPinPds();
extern void PrintTcmTg();
extern void PrintTcmDc();
extern void PrintTcmMeasDct();
extern void PrintTcmMeasFct();
extern void VioCond(void (*func)(), double vcc);
extern void VsCond(void (*func)(), double vcc);
extern void TgCond(void (*func)());
extern void PinCond(void (*func)());

extern char *DoubleVarToStr(double var);
extern void GetDcCond(char *buf, int num);
extern void GetVsCond(char *buf, char *pinlist);
extern char *WaveformToStr(int i);
extern int GetDrClockType(int i);
extern void GetPinPdsCond(char *buf, char *pinlist);
extern void GetPinCond(char *buf, char *pinlist);
extern int GetUsedClock(char *pinlist);
extern void GetTgCond(char *buf, char *pinlist, int tsstart, int tsstop);
extern void GetRegCond();

extern void ResetAccumulatedLapTimer(int id);
#endif

#endif	/* ifndef _USERLIB_H */
