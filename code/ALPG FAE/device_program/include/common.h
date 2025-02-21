/**********************************************************************
Copyright (C), 2016-2017, YMTC Co., Ltd.                               
File name:      common.h                                                   
Date:			2017.6.29                                             
Description:	common function declarations              
Device:			Nu1                                                    
**********************************************************************/

#ifndef _COMMON_H
#define _COMMON_H

#include "public.h"


#define SR_ABNORMAL_BIN			998
#define POLLING_TIMEOUT_BIN		999


/////////////////////////////////////////////////////////////////



#define VCCMAX 3.6
#define VCCNOM 3.0
#define VCCMIN 2.7



#define CLK	  *1
#define LOOP  *1


enum POWER_FLAG{
	POWER_FLAG_NULL = 0x0,
	POWER_FLAG_RESET = 0x1,
	POWER_FLAG_REGLOAD = 0x2,
};


enum TIM_LABEL  {
T_ITEM = 101, T_COND, T_MDCT, T_MFCT, T_SFCT,
T_WAIT, T_ONPW, T_OFPW, T_UBMW, T_UBMR, T_FCMW,
T_FCMR, T_FCMC, T_FCMP, T_USER,
};       


typedef struct List
{
	void  *val;
	struct List *next;
} List;


#define MAX_STR_LEN 64
typedef struct
{
	int	fail_bin;		// test number
	int	(*func)();	// function name
	void (*voltage)(),(*pre_exec)(), (*post_exec)();
	int	    tno;		   	// test number
	int	    dtype;		 	// ex. value of tph register
	int     pc;        		// start pc
	double	hlimit;		 	// high limit
	double	llimit;		 	// low limit
//	double  vcc;		   	// vcc
	char	*vol_set;		//voltage setting table name
	char	patfile[MAX_STR_LEN];	// pattern file name
	char    *tname;		 	// test name
	int 	flag_option_fun;
	char    *tnum;
}TestArg;


int InitREFData();
int ReLoadREFTrimRegister();
int ReLoadOptimizedTrimRegister();
extern bool g_SR_Exclusion[DDUTCNT];
extern int g_slc_entry;
extern int g_flag_log;
extern int g_bb_chk;
extern int gPAD_LV_BYPASS_FUNCTPIN_flag;
extern int gPAD_UV_BYPASS_FUNCTPIN_flag;
void SetCflgNo(int cflag_no);

extern int g_flashlimit;
extern int g_timeout[DDUTCNT];
extern int g_timeout_cnt[DDUTCNT];
extern int g_median_of_arraydata[DDUTCNT];

extern PIN_STRUCT g_pinlist[];
extern DUT_MASK g_fail_mask;
extern int g_tempco_vrdvfy;
extern int g_tempco_vtsg;
extern char g_PartID[6];
extern  char g_WaferID[10];
extern  char g_LotID[20];
extern int g_die_X[] ;
extern int g_die_Y[] ;
extern int g_BinNo[] ;
extern double g_tRjectTitemTime[];
extern int g_Vt_Dist_Enable;
extern int g_DataBin;
extern int g_maj_rev;
extern int g_dot_rev;
extern int g_sort_flow;
extern int g_si_check;
extern int g_trimblk_flag;
extern bool bFlowDutActive[DDUTCNT];
extern int g_failflow[DDUTCNT];
extern int g_bin_flag[DDUTCNT];

extern void RUN_TEST(char * label, int (*func)(), int fail_rej,void (*pre_exec)(), void (*post_exec)(), char *pass_branch, char * fail_branch , int fail_bin, char *tname );
extern void Dummy();
extern void ConditionCheck();
extern void TEND();
extern void PinListDefine();

extern void TestGroupStart();
extern void TestGroupEnd(char *testname);

extern void PrintHeader();

extern int g_DataBin;

extern unsigned int g_uid_value[DDUTCNT][32];
extern int g_wafer_num;
extern int g_die_X[DDUTCNT];
extern int g_die_Y[DDUTCNT];
extern int g_temperature;

// Add ITC
#define UT_DDUT DDUT
#define UT_SDUT SDUT
#define UT_MDUT MDUT
#define UT_EDUT EDUT
#define UT_CDUT CDUT
#define UT_NOMORE NOMORE
#define UT_DUT int

#define DUT_LOOP(dutgroup)                                  \
{                                                           \
	SM_DUTINFO* dutinfo;                                    \
	int    dut;                                             \
	dutinfo = SML_GET_DUTINFO(dutgroup);                    \
	while ( (dut=SML_NEXT_DUT(dutinfo)) != NOMORE )         \
	{

#define DUT_LOOP_END                                        \
	}                                                       \
}

#define START_SERIAL_TEST_CDUT_ONLY							\
{															\
	ulSerialTestStart();									\
	PinCursor pc;											\
	UT_PIN pin;												\
	int dutlist[DDUTCNT+1],dutcnt=0,dut,i;					\
	pc = UTL_GetPinCursor ((char *)"CEB" );					\
	pin=UTL_NextPin(pc);									\
	LevelFixHandle level_fix_handle = UTL_GetLevelFixHandle( );	\
   	START_DUT_LOOP(UT_CDUT)									\
		UTL_SetExclusion(dut,UT_OFF,UT_OFF);				\
		UTL_SetLevelFixOutputLevel( level_fix_handle, UT_PIN_DR, UT_PIN_FIXH);  \
		UTL_SendLevelFix( level_fix_handle, pin, dut);		\
		dutlist[dutcnt++] = dut;							\
		dutlist[dutcnt]   = UT_NOMORE;						\
    END_DUT_LOOP											\
	for(i=0;i<dutcnt;i++)			\
	{														\
		dut=dutlist[i];										\
		UTL_ResetExclusion(dut);							\
		UTL_SetLevelFixOutputLevel( level_fix_handle, UT_PIN_DR, UT_PIN_NONE);  \
		UTL_SendLevelFix( level_fix_handle, pin, dut);		\
		do{
		
#define END_SERIAL_TEST_CDUT_ONLY							\
		}while(0);											\
    	UTL_SetExclusion(dut,UT_OFF,UT_OFF);				\
		UTL_SetLevelFixOutputLevel( level_fix_handle, UT_PIN_DR, UT_PIN_FIXH);  \
		UTL_SendLevelFix( level_fix_handle, pin, dut);      \
	}														\
	for(i=0;i<dutcnt;i++)			\
	{														\
		dut=dutlist[i];										\
		UTL_ResetExclusion(dut);							\
		UTL_SetLevelFixOutputLevel( level_fix_handle, UT_PIN_DR, UT_PIN_NONE);  \
		UTL_SendLevelFix( level_fix_handle, pin, dut);      \
	}														\
	UTL_DeleteHandle(level_fix_handle);						\
	ulSerialTestEnd();										\
}

#define START_SERIAL_TEST_ONE_DUT(input_dut_number)							\
{															\
	ulSerialTestStart();									\
	PinCursor pc;											\
	UT_PIN pin;												\
	int dutlist[DDUTCNT+1],dutcnt=0,dut,i;					\
	pc = UTL_GetPinCursor ((char *)"CEB" );					\
	pin=UTL_NextPin(pc);									\
	LevelFixHandle level_fix_handle = UTL_GetLevelFixHandle( );	\
   	START_DUT_LOOP(UT_CDUT)									\
		UTL_SetExclusion(dut,UT_OFF,UT_OFF);				\
		UTL_SetLevelFixOutputLevel( level_fix_handle, UT_PIN_DR, UT_PIN_FIXH);  \
		UTL_SendLevelFix( level_fix_handle, pin, dut);		\
		dutlist[dutcnt++] = dut;							\
		dutlist[dutcnt]   = UT_NOMORE;						\
    END_DUT_LOOP											\
	for(i=0;i<dutcnt;i++)									\
	{														\
		dut=dutlist[i];										\
		if(dut != (input_dut_number))						\
		{													\
			continue;										\
		}													\
		UTL_ResetExclusion(dut);							\
		UTL_SetLevelFixOutputLevel( level_fix_handle, UT_PIN_DR, UT_PIN_NONE);  \
		UTL_SendLevelFix( level_fix_handle, pin, dut);
		
#define END_SERIAL_TEST_ONE_DUT(input_dut_number)						\
    	UTL_SetExclusion(dut,UT_OFF,UT_OFF);				\
		UTL_SetLevelFixOutputLevel( level_fix_handle, UT_PIN_DR, UT_PIN_FIXH);  \
		UTL_SendLevelFix( level_fix_handle, pin, dut);      \
	}														\
	for(i=0;i<dutcnt;i++)			\
	{														\
		dut=dutlist[i];										\
		if(dut != (input_dut_number))						\
		{													\
			continue;										\
		}													\
		UTL_ResetExclusion(dut);							\
		UTL_SetLevelFixOutputLevel( level_fix_handle, UT_PIN_DR, UT_PIN_NONE);  \
		UTL_SendLevelFix( level_fix_handle, pin, dut);      \
	}														\
	UTL_DeleteHandle(level_fix_handle);						\
	ulSerialTestEnd();										\
}



//START_SERIAL_TEST2  only active DUT power on 
#define START_SERIAL_TEST2									\
{															\
   	START_DUT_LOOP(UT_MDUT)									\
		if(bFlowDutActive[dut-1]==false) continue;          \
		if(g_SR_Exclusion[dut-1]==true) continue;						\
		UTL_SetExclusion(dut,UT_OFF,UT_OFF);					\
    END_DUT_LOOP											\
	START_DUT_LOOP(UT_MDUT)									\
		if(bFlowDutActive[dut-1]==false) continue;          \
		if(g_SR_Exclusion[dut-1]==true) continue;						\
		UTL_ResetExclusion(dut);							\

#define END_SERIAL_TEST2									\
    	UTL_SetExclusion(dut,UT_OFF,UT_OFF);					\
	END_DUT_LOOP											\
	START_DUT_LOOP(UT_MDUT)									\
		if(bFlowDutActive[dut-1]==false) continue;          \
		if(g_SR_Exclusion[dut-1]==true) continue;						\
	    UTL_ResetExclusion(dut);							\
	END_DUT_LOOP											\
}

/* Duts were divided to serveral group by specified pin based on the socket file define*/
#define START_GROUP_TEST_BY_VS(vspinno)									\
{																		\
	DutCursor dutcsr;                                                   \
	UT_DUT    dut;                                                      \
	int maxdg,dg;                                                       \
	maxdg=UTL_GetDctVsDutGroupMaxNumber(vspinno);                       \
	ExclusionHandle hex = UTL_GetExclusionHandle();                     \
	UTL_SetExclusionIgnoreWet  (hex,UT_OFF);                            \
	UTL_SetExclusionMask           (hex,UT_ON);                         \
	START_DUT_LOOP(UT_MDUT)                                             \
		if(bFlowDutActive[dut-1]==false) continue;                      \
		if(g_SR_Exclusion[dut-1]==true) continue; 						\
		UTL_AddExclusionDut(hex,dut);                                   \
	END_DUT_LOOP                                                        \
	UTL_SetExclusionSetOrReset (hex,UT_ON);                             \
	UTL_SendExclusion(hex);                                             \
	for(dg=0;dg<=maxdg;dg++)                                            \
	{                                                                   \
		UTL_ClearExclusionDut(hex);                                     \
		dutcsr=UTL_GetDctVsDutGroupCursor(vspinno,dg);                  \
		while ( (dut=UTL_NextDut(dutcsr)) != UT_NOMORE )                \
		{                                                               \
			if(bFlowDutActive[dut-1]==false) continue;                  \
			if(g_SR_Exclusion[dut-1]==true) continue;						\
			UTL_AddExclusionDut(hex,dut);                               \
		}                                                               \
		UTL_SetExclusionSetOrReset (hex,UT_OFF);                        \
		UTL_SendExclusion(hex);                                         \
		UTL_DeleteCursor(dutcsr);                                       


#define END_GROUP_TEST_BY_VS											\
		if(dg!=maxdg)                                                   \
		{                                                               \
			UTL_SetExclusionSetOrReset (hex,UT_ON);                     \
			UTL_SendExclusion(hex);                                     \
		}                                                               \
	}                                                                   \
	START_DUT_LOOP(UT_MDUT)                                             \
		if(bFlowDutActive[dut-1]==false) continue;                      \
		if(g_SR_Exclusion[dut-1]==true) continue;						\
		UTL_AddExclusionDut(hex,dut);                                   \
	END_DUT_LOOP                                                        \
	UTL_SetExclusionSetOrReset (hex,UT_OFF);                            \
	UTL_SendExclusion(hex);                                             \
	UTL_DeleteHandle(hex);                                              \
}


//171206
#define START_GROUP_TEST_BY_VPP(vspinno)								\
{																		\
	DutCursor dutcsr;                                                   \
	UT_DUT    dut;                                                      \
	int maxdg,dg,cdut[DDUTCNT]={0}; 		                            \
	START_DUT_LOOP(UT_CDUT)                                             \
		cdut[dut-1]=1;                                                  \
	END_DUT_LOOP                                                        \
																		\
	ExclusionHandle hex = UTL_GetExclusionHandle();                     \
	VsMaskHandle hvsmask= UTL_GetVsMaskHandle();                        \
																		\
	maxdg=UTL_GetDctVsDutGroupMaxNumber(vspinno);                       \
	UTL_SetExclusionIgnoreWet  (hex,UT_OFF);                            \
	UTL_SetExclusionMask       (hex,UT_OFF);		                    \
																		\
	for(dg=1;dg<=maxdg;dg++) {                                          \
	   dutcsr=UTL_GetDctVsDutGroupCursor(vspinno,dg);					\
	   while((dut=UTL_NextDut(dutcsr)) != UT_NOMORE) {                  \
			if(bFlowDutActive[dut-1]==false) continue;                  \
			if(g_SR_Exclusion[dut-1]==true) continue;					\
			if(cdut[dut-1]==0) continue;								\
			UTL_AddVsMaskDutVsMask(hvsmask,dut,vspinno,UT_ON);			\
			UTL_AddExclusionDut(hex,dut);                               \
	   }                                                                \
	   UTL_DeleteCursor(dutcsr);										\
	   UTL_SetExclusionSetOrReset (hex,UT_ON);                          \
	   UTL_SendExclusion(hex);											\
	}																	\
																		\
	for(dg=0;dg<=maxdg;dg++)                                            \
	{                                                                   \
		UTL_ClearExclusionDut(hex);                                     \
		dutcsr=UTL_GetDctVsDutGroupCursor(vspinno,dg);                  \
		while ( (dut=UTL_NextDut(dutcsr)) != UT_NOMORE )  {				\
			if(bFlowDutActive[dut-1]==false) continue;                  \
			if(g_SR_Exclusion[dut-1]==true) continue;					\
			if(cdut[dut-1]==0) continue;								\
			UTL_AddVsMaskDutVsMask(hvsmask,dut,vspinno,UT_OFF);			\
			UTL_AddExclusionDut(hex,dut);								\
		}                                                               \
		UTL_SendVsMask(hvsmask);                                        \
	    UTL_SetExclusionSetOrReset (hex,UT_OFF);                        \
	    UTL_SendExclusion(hex);											\
		UTL_DeleteCursor(dutcsr);

//171206
#define END_GROUP_TEST_BY_VPP(vspinno)								\
		if(dg<maxdg) {													\
			UTL_ClearVsMaskDutVsMask(hvsmask);							\
			UTL_ClearExclusionDut(hex);									\
			dutcsr=UTL_GetDctVsDutGroupCursor(vspinno,dg);              \
			while((dut=UTL_NextDut(dutcsr)) != UT_NOMORE) {             \
				if(bFlowDutActive[dut-1]==false) continue;              \
				if(g_SR_Exclusion[dut-1]==true) continue;				\
				if(cdut[dut-1]==0) continue;							\
				UTL_AddVsMaskDutVsMask(hvsmask,dut,vspinno,UT_ON);		\
				UTL_AddExclusionDut(hex,dut);							\
			}                                                           \
			UTL_DeleteCursor(dutcsr);                                   \
			UTL_SetExclusionSetOrReset (hex,UT_ON);                     \
			UTL_SendExclusion(hex);										\
		}                                                               \
		else {                                                          \
			UTL_ClearExclusionDut(hex);									\
			for(dg=0; dg<=maxdg-1; dg++) {                              \
				dutcsr=UTL_GetDctVsDutGroupCursor(vspinno,dg);          \
				while((dut=UTL_NextDut(dutcsr)) != UT_NOMORE) {         \
					if(bFlowDutActive[dut-1]==false) continue;          \
					if(g_SR_Exclusion[dut-1]==true) continue;			\
					if(cdut[dut-1]==0) continue;						\
					UTL_AddVsMaskDutVsMask(hvsmask,dut,vspinno,UT_OFF);	\
					UTL_AddExclusionDut(hex,dut);						\
				}                                                       \
				UTL_DeleteCursor(dutcsr);								\
			}                                                           \
			UTL_SendVsMask(hvsmask);									\
			UTL_SetExclusionSetOrReset (hex,UT_OFF);					\
			UTL_SendExclusion(hex);										\
		}                                                               \
	}																	\
	UTL_DeleteHandle(hvsmask);											\
	UTL_DeleteHandle(hex);												\
}

#define IS_DUT_STATUS_SET(dut_status, dut)        (((dut_status) >> (dut-1)) & 0x01)
#define IS_DUT_STATUS_NOT_SET(dut_status, dut)  (!(((dut_status) >> (dut-1)) & 0x01))
#define DUT_SET_STATUS(dut_status, dut) \
do {	\
	(dut_status) |= ((DUT_MASK)1 << (dut - 1));	\
} while(0)


void TestStart(void);
void initializ (void);
void PowerOn_Rst_Monitor(int *meastR);
int Special_blk_access();
int tm_por_pln1_only(int *data);
void CommonSetD1C_PageLoopIndex(PAGE_TYPE type);
void Hard_Reset();
double GetVariableValue(char *var_name, double var_default_value);
int GetAllMeasResult();
int GetMeasResult(int dut);
int GetAllFinalResult();
int GetFinalResult(int dut);
void PowerUp_Seq(); 
void PowerOn_Rst();
void Power_Up(double vcc, double vccq, int rst_flag, int regload_flag);
void power_up(double vcc, double vccq, unsigned int power_flag);
void PowerOn_Load_IODly(DUT_MASK* result);
void Power_down(); 
int  COND_FUNCT(double vcc, double vccq);
int SetAllFinalResult( int result);
int SetFinalResult(int dut, int result);
void runtest_pattern( char *patfile, int pc);
void runtest_pattern_by_label( char *patfile, char *startlabel);
void runtest_pattern_by_label_regld( char *patfile, char *startlabel);
void runtest_dbm_pattern_by_label( char *patfile, char *startlabel);
void start_pattern_by_label( char *patfile, char *startlabel); // For GL leakage
void start_pattern_by_label_meas_mode( char *patfile, char *startlabel); // For meas leakage
void continue_pattern();
void start_pattern( char *patfile, int pc);// For GL leakage 
void stop_pattern();// For GL leakage
void UpdateFailMask(int val);
void SetFinalResultByFailMask(int val);
void ClearFailMask();
int GetFailMask();
void runtest_pattern_exitmode(char* pat_name, int pat_index);
void RunMeasPat(char *pat_name, int pat_index, char *meas_pin, double wait_time, int Pin_No, double *meas_result);
void RunMeasPat_by_label(char *patfile, char *startlabel, char *meas_pin, double wait_time, int Pin_No, double *meas_result);
void Common_SetIDXCount_Cflg(int idxi_num, int count);

void ResetCflgNo(int cflag_no);
void ShowCflgValue(int n);
void RunSamplingPat(char *pat_name, int pat_index, char *meas_pin, int Pin_No, int sampling_count);
void RPC_hv_entry();
void CommonSetFeatures(FEATURE_STRUCT feature);
void CommonSetFeatures2(FEATURE_STRUCT feature);
void commonSetFeaturesByD1(FEATURE_STRUCT feature);
void CommonSetReg(REG_STRUCT reg);
void CommonSetMeasure(MEASURE_STRUCT meas);
void CommonSetStressBlockCount(int blockcount);
void CommonSetStressCount(int count);
void Common_SetCFLAG(int cflag_num, int cflag_data);
void CommonSetFBC(int plane_mode,int fail_bit_allowance,int fb_out_reg_data);
void CommonSetD2C(int data);
void CommonSetXT2(int data);
void CommonSetD2D_PageGroupIndex(ADDRESS_STRUCT address);
void CommonSeedRegSet(int *seed);
void common_set_d1h_block_loop_index(int block_index);
void PrintParameter(int dut, char *parameter, int value);
void MonPrintParameter(int dut, char *parameter, int value);
DUT_MASK GetBadBlockDutMask (int block);
DUT_MASK GetBadBlockDutMask (int *block);
DUT_MASK GetGoodBlockDutMask (int block);
DUT_MASK GetOtherDutsMask (int dut_num);
DUT_MASK IncludeDutIntoMask (DUT_MASK mask, int dut);
void PrintArrayData (int  dut_num, char string[],int  number_of_element,int  *array_ptr);
void MonPrintArrayData (int  dut_num, char string[],int  number_of_element, int  *array_ptr);
void Print_SingleDutArrayData (int  dut_num, char string[], int  number_of_element, int  *array_ptr, int sum_flag=0);
void AssignFbin_AllDut (int index);
void AssignFbin_1Dut (int dut_num, int index);
void InitFbin_AllDut();
void IncFbin_AllDut (int index);
void IncFbin_1Dut (int dut_num, int index);
void PrintFbin_AllDut ();
void Disable_BB_Check ();
void Enable_BB_Check();
void Add_FuncList();    
void DefinePinList();  
void DefinePinName();
//ITC void ISVM(double DCsource, double DcSrangehigh, double DcSrangelow, double DcMrangehigh, double DcMrangelow, double DcPclamp, double DcMclamp, double DcLimithigh, double DcLimitlow, int measrue_count, int compareflag);
//ITC void VSIM(double DCSource, double DcSrangehigh, double DcSrangelow, double DcMrangehigh, double DcMrangelow, double DcPclamp, double DcMclamp, double DcLimithigh, double DcLimitlow, int meausre_count, int compareflag);
//ITC int pps_vsim(char *title,double DCSource, double DcSrangehigh, double DcSrangelow,double DcMrangehigh,double DcMrangelow,double DcPclamp,double DcMclamp,double DcLimithigh,double DcLimitlow,int compareflag, int measure_count);
//ITC int hv_pps_vsim(char *title,double DCSource, double DcSrangehigh, double DcSrangelow,double DcMrangehigh,double DcMrangelow,double DcPclamp,double DcMclamp,double DcLimithigh,double DcLimitlow,int compareflag, int measure_count);
//ITC void MVM(int vsno, double VsMrangehigh, double VsMrangelow, double VsLimithigh, double VsLimitlow, int compareflag, int measure_count);
//ITC void MVM_ForceWet(int vsno, double VsMrangehigh, double VsMrangelow, double VsLimithigh, double VsLimitlow, int compareflag, int measure_count);
//ITC extern void SendVs_ForceWet(VsHandle h, long vsno);
//ITC double	MeasHVPin( char *pinlist, double wait_time, int meas_cnt, int dut);
//ITC void	MeasHVPinParallel( char *pinlist, double wait_time, int meas_cnt, double *meas_result, int multi_measure); //ATJ
void MeasPin(char *pinlist, double wait_time);
double Read_VS_Meas_Result(char *vspin, int vsno, int dut);
//ITC double HV_Pin_Leakage_Test(char *pinlist, int vs_no, char *parameter, int dut);
void Read_Meas_Result(char *pinlist, char *test_item, double hlimit, double llimit, int OS_Leakage_Flag);
void Get_Meas_Result(char *pinlist, double * data, char *label);

//Power define. power.c
void CheckSourceRange(int onoff);
void FUNCT_VS(double VDD, double VDDQ);
void VDD_SET(double vdd, double MRange, int spec_enable, double hlimit, double llimit); //Vdd power mode set 
void VDDQ_SET(double vddq, double MRange, int spec_enable, double hlimit, double llimit); //Vddq power mode set 
void VS_Set( double voltage, int vsno); 
void VS_Set(int vsno, double voltage, double MRange, int spec_enable, double hlimit, double llimit); //Vddq power mode set
void VS_SetVol( double voltage, int vsno); //Vddq power mode set

void DC_VS(double VCC, double VCCQ, double vol_PAD_VMON, double MRange, int spec_enable, double hlimit, double llimit);
void DC_VS2(double VCC, double VCCQ, double vol_PAD_VMON, int spec_enable, double hlimit, double llimit);

//Level define, level.c
void FUNCT_VIN(double vdd, double vddq);
void VIN_Set(double vihigh, double vilow, int vino);
void VOUT_Set(double vohigh, double volow, int vono);
void VT_Set(double vt, int vtno);
int Voltage_Switch(char* VccSet);
void Vihh_Set(double v_vihh, int vihh_no);
//timming define, timing.c
void FUNCT_TMG();
void Reset_SR2E0();
//pin Format define, pinfmt.c
void FUNCT_PIN();
void FUNCT_PIN_RPC();
void IO_NRZB(char *pinlist, int ViNo_io, int VoNo_io, int VtNo_io, int StrobeNo_io, int CpeNo_io, int DrePhase_io);
void IO_NRZB_ULPC(char *pinlist, int ViNo_io, int VoNo_io, int VtNo_io, int StrobeNo_io, int CpeNo_io, int DrePhase_io);
void IO_NRZB_DBM(char *pinlist, int ViNo_io, int VoNo_io, int VtNo_io, int StrobeNo_io, int CpeNo_io, int DrePhase_io);
void IO_NRZB_ULPC_DBM(char *pinlist, int ViNo_io, int VoNo_io, int VtNo_io, int StrobeNo_io, int CpeNo_io, int DrePhase_io);
void Rb_Match(char *pinlist, int VoNo_rb, int VtNo_rb, int StrobeNo_rb, int CpeNo_rb);
void Input_INRZB( char *pinlist, int sig_c_no, int ViNo_in, int DrePhase_in);
void Input_NRZB( char *pinlist, int sig_c_no, int ViNo_in, int DrePhase_in);
void Input_IRZO( char *pinlist, int sig_c_no, int ViNo_in, int DrePhase_in);
void CLK_IRZO( char *pinlist, int sig_c_no, int ViNo_in, int DrePhase_in);
void Input_FIXL( char *pinlist, int ViNo);
void Input_FIXH( char *pinlist, int ViNo);
void Input_Format_VI(char *pinlist, int format, int vino);
void Enable_default_CEB();
void FIXL_CEB();
void DriveHV_VIHH(char *pinlist, int format, int vihh_no);
void DriveHV_VIH(char *pinlist, int format, int vi_no);
void SetAllPin2OneLevel(char *pinlist, float value);
void SetAllVs2OneLevel(char *pinlist, double value);
//ITC void SET_CEB_FIXL_PartialDut( RadioButton dg); //ATJ
//ITC void RESET_CEB_FIXL_PartialDut( RadioButton dg); //ATJ


void Set_TRIM_REG(TestArg *arg, int addr, int data);
char * TrimStr(char *source);
int Enter_TM(int tm);
int Exit_TM(int tm);

int ubm_config_single_blk(ADDRESS_STRUCT address, int *SAMP_BLK);
int ubm_config_sample_blk(ADDRESS_STRUCT address, int *SAMP_BLK, int sample_cnt);
int ubm_config_single_blk_rdmrg(ADDRESS_STRUCT address, int *SAMP_BLK);
int ubm_write_sample_address(ADDRESS_LIST_UBM_STRUCT list);
int ubm_write_sample_address2(ADDRESS_UBM_STRUCT address);
int ubm_write_sample_blk(ADDRESS_UBM_STRUCT list);


int Enter_External_Timer();
int Exit_External_Timer();
int Enter_SLC_Mode();
int Exit_SLC_Mode();
void CommonSetSinglePulse(int cmd1, int cmd2);
unsigned int crc16(unsigned int *addr, int num, unsigned int crc, unsigned int poly);
int GetTemperature();

void Initial_G_Variable ();

void *RegistListData(void *val, List **table, int nelem, int (*compare)(void *,void *), void *(*dup)(void *), int (*hash)(void *));
char *get_lastpat(); //pat_ttr
int Single_Command(int cmd);
void CommonSetD1C_D1D_RegShr(int D1C_data, int D1D_data);
int Special_blk_exit();
int Check_Reg_Change();
int Special_Blk_Handle(ADDRESS_STRUCT *address, int blk_index, int slc_flag, int quad_plane_flag);
void CommonSetApgRegIdxCflag(ADDRESS_STRUCT address, int data, int cmd1, int cmd2);

/*---------------------------------- Code structure adjustment ------------------------------*/
void  print_array_data(int  dut, char *title, int  elem_num, const int *elem_array);
void DBM_CommonSetApgRegIdxCflag(ADDRESS_DBM_STRUCT address, int cmd1, int cmd2);
/*--------------------------------------------------------- ------------------------------*/
void CommonB1_DPOSC_RegSet(int data, int reg_add);
/*--------------------------------------- Code adjustment ------------------ ------------------------------*/
void CommonSetIDX6(int value);
void CommonSetD1G(int data);
void CommonSetD1E(int data);
CELL_MODE get_cell_mode();
int creat_slc_bfile(int bin_data, char *bin_fname);
int creat_tlc_bfile(int *bin_data, char *bin_fname);
int remove_bfile(char *bin_fname);

void CommonSetIDX5(int value);
void CommonSetD5(int value);
/*--------------------------------------- Code adjustment ------------------ ------------------------------*/


void ul_stop_test(char *description);
void *calloc_and_check(size_t num, size_t size);
void *malloc_and_check(size_t size);
void MeasHVPinParallel_Switch( char *meas_pin, double wait_time, int Pin_No, double *meas_result); 

#endif	/* ifndef _COMMON_H */
