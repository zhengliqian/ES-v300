//######## sml.h #############################################################
//2010/11/22	新規

#ifndef __SML_H__
#define __SML_H__

//#include <stdio.h>
#include "sml_tpl.h"
#include "sml_define.h"

//-----------------------------------------------------------
//   Tester Setting / Others
//-----------------------------------------------------------
void         SML_TEST( int n ) ;
void         INN_TEST( int n ) ;
void         SML_READ_TEST_NO( int *tno ) ;
void         SML_SET_CATEGORY( int wdut, int cat ) ;
void         SML_RESET_TESTER( int type ) ;

void         SML_GDAY( char* data , int mode ) ;
void         SML_WAIT_TIME( float t ) ;
// SMLは廃止(WETで固定) INN化
//void         SML_SET_WET( void ) ;
//void         SML_RESET_WET( void ) ;
void         INN_SET_WET( void ) ;
void         INN_RESET_WET( void ) ;
void         Sleep(int n );

void         SML_STOP( void ) ;

bool         INN_RESET_HW( unsigned long type );
void         INN_CATEGORY( unsigned long cat );

void         SML_PAUSE( void ) ;
void         SML_SET_NANDADDRESSNAME( char *naddr ) ;
void         SML_GET_NANDADDRESSNAME( char *naddr ) ;

int          INN_INIT_TESTER( int dat1, int dat2 );
void         INN_SET_TIMMINGNAME( char *Timm ) ;
int          INN_CHK_TIMMINGNAME( char *Timm ) ;
void         INN_SET_NANDADDRESSNAME2( char *naddr ) ;
int          INN_CHK_NANDADDRESSNAME2( char *naddr ) ;

void         INN_SET_CURRENT_TD(int total, int count);
void         SML_GET_CURRENT_TD(int *n);

int          INN_GET_STAGE_MAX();
void         SML_GET_MACHINE(char *mc);
void         INN_SET_PART_NO( int part );
void         INN_READ_PART_NO( int* part );
void         INN_SET_PART( int md, char* part_name );
void         INN_GET_PART( int md, char* part_name );
void         INN_GET_OPTION( char* opt );
void         INN_SET_OPTION( char* opt );
void         INN_PRINT_PART(int md1=-1, int md2=-1, int md3=-1, int md4=-1, int md5=-1);

// SMLも用意したが、INNと同様の動作
void         SML_GET_PART( int md, char* part_name );
void         SML_GET_OPTION( char* opt );
void         SML_READ_PART_NO( int* part );


int          INN_SCANF(const char* fmt, ... );
FILE *       INN_FOPEN(const char *filename, const char *mode);
int          INN_FTELL(FILE *fp);
int          INN_GET_REPEAT_COUNT();

void         INN_SET_DEFINE_OPTION(char *cmd, int data);
bool         INN_GET_DEFINE_OPTION(char *cmd, int *data);

bool         INN_INIT_LOADING();

int INN_FLOW_TEST_MAIN(__tpl_PART_FUNC __tpl_PART_FUNC_TBL[], int __tpl_PART_SIZE,
						int __tpl_nRunEndPart);

/*----------------------------------------------------------
	LOG
----------------------------------------------------------*/
void         INN_LOG_WRITE(const char *msg);
void         LogFileOpen( char *dir ) ;
//void         PrintLog( FILE *fp , const char *fmt , ... ) ;
void         PrintLog( const char *fmt , ... ) ;
void         LogFileRemove( char *dir ) ;
void         INN_LogFileClose( void );


//-----------------------------------------------------------
//   DC(PMU/DPS/VIH/VOL/REF)
//-----------------------------------------------------------
void         SML_VSIM( float vs , int vr , int ir , float c1 , float c2 ) ;
void         SML_ISVM( float is , int ir , int vr , float c1 , float c2 ) ;
void         SML_VS( int onoff , float vs , int vr , int ir , float ip , float im ) ;
void         SML_MVM( int vr );
void         SML_LIMIT( int unit , float u , float l ) ;

void         INN_VSIM( float vs , int vr , int ir , float c1 , float c2 ) ;
void         INN_ISVM( float is , int ir , int vr , float c1 , float c2 ) ;
void         INN_VSVM(float vs, int vr, int ir, float c1, float c2 );
void         INN_ISIM(float is, int ir, int vr, float c1, float c2 );
void         INN_SET_LIMIT( int unit , float u , float l, int range ) ;
int          INN_GET_LIMIT( int unit, float *u, float *l );
void         INN_MEAS_DC(int pin_relay_flag, int n, float t,int PIN);
void         INN_MEAS_VS(int n, float t);

void         SML_MEAS_DC( int PIN ) ;
void         SML_MEAS_DC2( int n , float t , int PIN ) ;
//void         SML_MEAS_DC3( int n , float t , int PIN ) ;
void         SML_MEAS_OVER_LEAK(float upper, float lower);
void         SML_DIAG_DC( int wd , int PIN , int n=1 , float t=0.01 ) ; // wd=0:PinRelay-Off, 1:PinRelay-On, 2:Nothing

void         SML_MEAS_VS( void ) ;
void         SML_DIAG_VS( void ) ;
void         SML_MEAS_VS2( int n , float t ) ;

void         _SET_DUT_PF( int dut, float value );		//use check program

void         SML_IN( int n , float vih , float vil ) ;
void         SML_OUT( int n , float voh , float vol ) ;

// SML_TIME引数変更(既存引数関数はINN化する)
void         SML_TIME( int n, float t , int unit ) ;
//void         INN_TIME( float t , int unit1 , int unit2 = -1 , int unit3 = -1 ) ;
void         SML_SRON( void ) ;
void         SML_SROF( float t=3.0 ) ;
void         SML_ROF( float t , int unit ) ;
void         SML_RON( float t , int unit ) ;

//void         SML_READ_DC( int mode , int wdut , SM_DC *dc ) ;
void         SML_READ_DC( SM_DC *dc ) ;
//void         SML_READ_VS( int mode , int wdut , SM_VS *vs ) ;
void         SML_READ_VS( SM_VS *vs ) ;

void         SML_MVM_WAIT(float t1, float t2);
void         SML_VSIM_WAIT(float t1, float t2);
void         SML_ISVM_WAIT(float t1, float t2);
void         SML_VS_WAIT(float t1);
void         INN_DC_WAIT(int mode, float t1, float t2, float t3=-1.0);
void         INN_VS_WAIT(float t1, float t2, float t3=-1.0);

void         INN_SET_ADC_SWITCH(float time);
float        INN_GET_ADC_SWITCH(void);
void         INN_MEAS_ADC(int type, int target, float t_switch, int count, float t_meas, int range, double* ptr_result);

//-----------------------------------------------------------
//   SML_PD/PC
//-----------------------------------------------------------
#define      SML_PD( n, onoff, in_dc, fmt, aclk  , bclk  , cclk  , name, init ) \
             _SML_PD( n, onoff, in_dc, fmt, aclk-0, bclk-0, cclk-0, name, init )
        
#define      SML_PC( onoff, in_dc, fmt, dre, out, strb, aclk  , bclk  , cclk  , name, init ) \
             _SML_PC( onoff, in_dc, fmt, dre, out, strb, aclk-0, bclk-0, cclk-0, name, init )

void         _SML_PD( int n , int onoff , int in_dc , int fmt , int aclk , int bclk , int cclk , int name , int init ) ;
void         _SML_PC( int onoff , int in_dc , int fmt , int dre , int out , int strb , int aclk , int bclk , int cclk , int name , int init ) ;
void         INN_PD( int n , int onoff , int in_dc , int fmt , int aclk , int bclk , int cclk , int name , int init ) ;
void         INN_PC( int onoff , int in_dc , int fmt , int dre , int out , int strb , int aclk , int bclk , int cclk , int name , int init ) ;

//-----------------------------------------------------------
//   DUT
//-----------------------------------------------------------
void         SML_SET_SDUT( int wdut ) ;

SM_DUTINFO * SML_GET_DUTINFO( int mode ) ;
int          SML_NEXT_DUT( SM_DUTINFO *dutinfo ) ;
void         SML_READ_DDUT( SM_DUTINFO *dutinfo ) ;
void         SML_READ_SDUT( SM_DUTINFO *dutinfo ) ;
void         SML_READ_MDUT( SM_DUTINFO *dutinfo ) ;
void         SML_READ_EDUT( SM_DUTINFO *dutinfo ) ;
void         SML_READ_CDUT( SM_DUTINFO *dutinfo ) ;
void         SML_READ_PDUT( SM_DUTINFO *dutinfo ) ;
void         SML_READ_FDUT( SM_DUTINFO *dutinfo ) ;
void         SML_READ_GFDUT( SM_DUTINFO *dutinfo ) ;
void         SML_READ_XDUT( SM_DUTINFO* dutinfo );
void         SML_SET_RESULT( int wdut , int n ) ;
//void         SML_RESET_RESULT( int wdut , int n ) ;
void         SML_RESET_RESULT( int wdut ) ;
void         SML_SET_REJECTION( int wdut ) ;
void         SML_SET_EXCLUSION( int onoff , int wdut ) ;
void         SML_RESET_EXCLUSION( int onoff , int wdut ) ;

//void         SML_READ_CATEGORY( int mode , int wdut , int* cat ) ;
void         SML_READ_CATEGORY( int wdut , int* cat ) ;
void         SML_RESET_CATEGORY( int mode , int wdut , int cat ) ;

void         SML_SET_DC( int wdut ) ;
void         SML_RESET_DC( int wdut ) ;
void         SML_SET_VS( int wdut ) ;
void         SML_RESET_VS( int wdut ) ;
void         SML_SET_FUNC( int wdut ) ;
void         SML_RESET_FUNC( int wdut ) ;
//void         SML_READ_RESULT( int mode , int wdut , int n , SM_RESULT* rst ) ;
void         SML_READ_RESULT( int n , SM_RESULT* rst ) ;

//-----------------------------------------------------------
//   Pattern
//-----------------------------------------------------------
void         SML_SEND_MPAT( char *pat_file ) ;
void         SML_SEND_MPAT( char *pat_file , int mode ) ;

void         SML_REG_MPAT( int target , unsigned int data ) ;
int          SML_GET_REG_MPAT( int target , unsigned int *data ) ;
void         SML_REG_MPATPC( char *pc ) ;
void         SML_READ_REGISTER( int target , unsigned int *data ) ;

void         SML_MEAS_MPAT( void ) ;
void         SML_START_MPAT( void ) ;
void         SML_START_MPAT( int md ) ;
void         SML_STOP_MPAT( void ) ;

//void         SML_READ_FUNC( int mode , int wdut , SM_FCN *fcn ) ;
void         SML_READ_FUNC( SM_FCN *fcn ) ;

void         SML_SET_IDX_MODE(int mode) ;

//-----------------------------------------------------------
//   PFB/PC
//-----------------------------------------------------------
//void         SML_PCON( int mode , int wdut , int onoff ) ;
void         SML_PCON( int onoff ) ;
void         SML_SEND_CW( int cw_data ) ;
void         SML_READ_CW( int *cd_data ) ;
//void         SML_READ_PCID( int *pcid_data ) ;
void         SML_READ_PBID( int *pbid_data ) ;
void         SML_READ_PBRINF( int *x , int *y , char *lot , int *waf , float *temp ) ;
void         SML_READ_XYLOC( int wdut , int *x , int *y ) ;
void         SML_READ_WID( char *wid ) ;

//-----------------------------------------------------------
//   Timer
//-----------------------------------------------------------
void         SML_START_TIMER( int tr ) ;
void         SML_STOP_TIMER( void ) ;
void         SML_READ_TIMER( float *tim_data ) ;

//-----------------------------------------------------------
//  DUM/PM
//-----------------------------------------------------------
#ifdef USE_SHARE
     #define SML_SAVE_DUM _SML_SAVE_DUM_2304
     #define SML_LOAD_DUM _SML_LOAD_DUM_2304
     #define SML_GET_DUM  _SML_GET_DUM_2304
     #define SML_SET_DUM  _SML_SET_DUM_2304
     #define SML_GET_FBC  _SML_GET_FBC_2304
     #define SML_SET_DUM_S _SML_SET_DUM_2304_S

#else
     #define SML_SAVE_DUM _SML_SAVE_DUM_1152
     #define SML_LOAD_DUM _SML_LOAD_DUM_1152
     #define SML_GET_DUM  _SML_GET_DUM_1152
     #define SML_SET_DUM  _SML_SET_DUM_1152
     #define SML_GET_FBC  _SML_GET_FBC_1152
#endif

void         _SML_SAVE_DUM_2304( FILE* file , int n , SM_DUM_2304 *dum ) ;
void         _SML_SAVE_DUM_1152( FILE* file , int n , SM_DUM_1152 *dum ) ;
void         _SML_LOAD_DUM_2304( FILE* file , int n , SM_DUM_2304 *dum ) ;
void         _SML_LOAD_DUM_1152( FILE* file , int n , SM_DUM_1152 *dum ) ;
//void         _SML_SET_DUM_2304( int mode , int wdut , int addr , int n , SM_DUM_2304 *dum ) ;
//void         _SML_SET_DUM_1152( int mode , int wdut , int addr , int n , SM_DUM_1152 *dum ) ;
//void         _SML_GET_DUM_2304( int mode , int dut  , int addr , int n , SM_DUM_2304 *dum ) ;
//void         _SML_GET_DUM_1152( int mode , int dut  , int addr , int n , SM_DUM_1152 *dum ) ;
//void         _SML_SET_DUM_2304_S( int mode , int wdut , int addr , int n , SM_DUM_2304 *dum ) ;
void         _SML_SET_DUM_2304( int addr , int n , SM_DUM_2304 *dum ) ;
void         _SML_SET_DUM_1152( int addr , int n , SM_DUM_1152 *dum ) ;
void         _SML_GET_DUM_2304( int addr , int n , SM_DUM_2304 *dum ) ;
void         _SML_GET_DUM_1152( int addr , int n , SM_DUM_1152 *dum ) ;
void         _SML_SET_DUM_2304_S( int addr , int n , SM_DUM_2304 *dum ) ;



void         SML_FILE_PM( int sta, int size, char *filename);
void         SML_FILE_DUM(int sta, int size, char *filename);
void         SML_SET_PM(  int sta, int size, char *data);
void         SML_GET_PM(  int sta, int size, char *data);
void         SML_DUM2PM(int sta_dum,int sta_pm, int size, int wdut);
void         SML_PM2DUM(int sta_dum,int sta_pm, int size);
void         SML_OR_COPY_DUM(int sta_dum,int sta_copy, int size);
//void         SML_RESET_DUM( int mode , int wdut ) ;
void         SML_RESET_DUM( ) ;
void         SML_RESET_DUM_AREA(int sta, int size);
//void         SML_COPY_DUM( int mode , int wdut , int start_addr , int n , int copy_addr ) ;
void         SML_COPY_DUM( int start_addr , int n , int copy_addr ) ;
//void         _SML_GET_FBC_2304( int mode , int wdut , int addr , int n , SM_FBC_2304 *fbc ) ;
//void         _SML_GET_FBC_1152( int mode , int wdut , int addr , int n , SM_FBC_1152 *fbc ) ;
void         _SML_GET_FBC_2304( int addr , int n , SM_FBC_2304 *fbc ) ;
void         _SML_GET_FBC_1152( int addr , int n , SM_FBC_1152 *fbc ) ;
//void         SML_CLEAR_FBC( int mode , int wdut ) ;
void         SML_CLEAR_FBC( ) ;
void         SML_ENABLE_FBC( void ) ;
void         SML_ENABLE_FRM( void ) ;
void         SML_DISABLE_FBC( void ) ;
void         SML_DISABLE_FRM( void ) ;

void         SML_SELECT_DUM_ACTION( int mode );
void         SML_SET_AFM_ADDR ( int bit, int sel );
bool         INN_SET_AFM_ADDR (void);
void         SML_GET_AFM (SM_FBC* fbc, SM_DUM* dum, int x_st, int x_sp, int y_st, int y_sp, int z_st, int z_sp, int io_mask, int mut_c=0);

void         INN_GET_PM( int site_addr, int sta, int size, char *data);

//-----------------------------------------------------------
//   PCI
//-----------------------------------------------------------
int          INN_GET_STAGE_NO( void );
void         INN_READ          ( unsigned long reg, unsigned long* data );
void         INN_READ_SITE     ( unsigned long reg, unsigned long* data );
void         INN_READ_MASK     ( unsigned long reg, unsigned long mask, unsigned long* data );
void         INN_READ_BUF      ( unsigned long reg, unsigned long* data, unsigned long size );
void         INN_READ_MEM      ( unsigned long reg, unsigned long* data, unsigned long size );
void         INN_WRITE_ALL     ( unsigned long reg, unsigned long data );
void         INN_WRITE         ( unsigned long reg, unsigned long data );
void         INN_WRITE_MASK    ( unsigned long reg, unsigned long mask, unsigned long data );
void         INN_WRITE_MASK_ALL( unsigned long reg, unsigned long mask, unsigned long data );
void         INN_WRITE_BUF     ( unsigned long reg, unsigned long* data, unsigned long size );
void         INN_WRITE_BUF_ALL ( unsigned long reg, unsigned long* data, unsigned long size );
void         INN_WRITE_MEM     ( unsigned long reg, unsigned long* data, unsigned long size );
void         INN_LOG_MODE      (int mode);

void         _INN_WAIT(unsigned long adr,unsigned long mask_bit, float time_out, char *file=__FILE__, int lineNo=__LINE__ );
void         _INN_WAIT_ALL(unsigned long adr,unsigned long mask_bit, float time_out, char *file=__FILE__, int lineNo=__LINE__ );

//-----------------------------------------------------------
//    CIM
//-----------------------------------------------------------
// SML_CIM_MAKE*を削除
// SML_CIM_READ_SKIP_DATA / SML_CIM_WRITE_SKIP_DATAを削除
bool         INN_MAKE_CIM();		//CIM処理
void         SML_CIM_CHARACTER_INT_DATA( int wdut , char *symbol , int data , char *unit ) ;
void         SML_CIM_CHARACTER_INT_DATA2( int wdut , char *symbol , int data , char *unit , int character_number , int test_number , char *go_nogo , float lower , float upper , char *comment ) ;
void         SML_CIM_CHARACTER_FLOAT_DATA( int wdut , char *symbol , float data , char *unit ) ;
void         SML_CIM_CHARACTER_FLOAT_DATA2( int wdut , char *symbol , float data , char *unit , int character_number , int test_number , char *go_nogo , float lower , float upper , char *comment ) ;
void         SML_CIM_READ_CHARACTER_INT_DATA( int wdut , char *symbol , int* data , char *unit ) ;
void         SML_CIM_READ_CHARACTER_FLOAT_DATA( int wdut , char *symbol , float* data , char *unit ) ;
//void         SML_CIM_MAKE_CHARACTER_DATA( int n , char **symbol ) ;
//void         SML_CIM_DATALOG_INT_DATA( int wdut , char *symbol , int data , char *unit ) ;
//void         SML_CIM_DATALOG_FLOAT_DATA( int wdut , char *symbol , float data , char *unit ) ;
//void         SML_CIM_READ_DATALOG_INT_DATA( int wdut , char *symbol , int* data , char *unit ) ;
//void         SML_CIM_READ_DATALOG_FLOAT_DATA( int wdut , char *symbol , float* data , char *unit ) ;
//void         SML_CIM_MAKE_DATALOG_DATA( int n , char **symbol ) ;
void         SML_CIM_FUSE_DATA( int wdut , char *data ) ;
//void         SML_CIM_WRITE_SKIP_DATA( int wdut , int data ) ;
//void         SML_CIM_READ_SKIP_DATA( int wdut , int *data ) ;
//void         SML_CIM_MAKE_FUSE_DATA( void ) ;
//void         SML_CIM_MAKE_SKIP_DATA( void ) ;
//void         SML_CIM_MAKE_INK_DATA( void ) ;
//void         SML_CIM_MAKE_CATEGORY_DATA( void ) ;
void         INN_CIM_WRITE_INK_DATA( int wdut , int data ) ;

//-----------------------------------------------------------
//   INN Function for System
//-----------------------------------------------------------
void         INN_ADD_NANDADDRESS(char *moji, void (*func)());
bool         INN_SYS_DATA_INIT();
void         INN_SET_LOGPRINT(int onf);
void         INN_SET_LOGFILE(int onf);
void         INN_SET_USE_SHARE(int onf);
void         INN_SET_USE_BACKTRACE(int onf);
void         INN_SET_USERMODE(int onf);
void         INN_SET_DEFINE(int bPrint, int bFile, int bOpe);
bool         INN_GET_USE_SHARE();

void         INN_RESET_PART();
bool         INN_SET_SYSLOG(int sock);
void         INN_PUTLOG(int deb_type, char* fmt, ... );

void         INN_RATE(double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8);
void         INN_ACLK(int id, double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8);
void         INN_BCLK(int id, double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8);
void         INN_CCLK(int id, double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8);
void         INN_DREL(double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8);
void         INN_DRET(double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8);
void         INN_STRB(double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8);

void         SML_RATE(int ts, double t);
void         SML_ACLK(int n, int ts, double t);
void         SML_BCLK(int n, int ts, double t);
void         SML_CCLK(int n, int ts, double t);
void         SML_DREL(int ts, double t);
void         SML_DRET(int ts, double t);
void         SML_STRB(int ts, double t);

// MainCompiler用ラッパー関数
// QuestのMainCompilerを流用した為、引数を合わせた関数を用意
void         _INN_RATE(int ts, double t);
void         _INN_ACLK(int n, int ts, double t);
void         _INN_BCLK(int n, int ts, double t);
void         _INN_CCLK(int n, int ts, double t);
void         _INN_DREL(int n, int ts, double t);
void         _INN_DRET(int n, int ts, double t);
void         _INN_STRB(int n, int ts, double t);

void         INN_SET_NAND(int ASn, int data8, int data7, int data6, int data5, int data4, int data3, int data2, int data1);
void         INN_GET_NAND(int ASn, int *data8,int *data7,int *data6,int *data5,int *data4,int *data3,int *data2,int *data1 );

bool         INN_SET_ITEM();
void         _SYS_INIT_LOADING();

void         INN_EXCHANGE_T2W(SM_DUTINFO *dutinfo);
int          INN_EXCHANGE_T2W(int tdut);
int          INN_EXCHANGE_W2T(int wdut);
int          INN_EXCHANGE_T2H(int tdut, int *p_site);
int          INN_EXCHANGE_H2T(int site, int hdut);

//-----------------------------------------------------------
//  Part Item Infomation
//-----------------------------------------------------------
//void         INN_PART_NO(int no);
//void         INN_PART_NAME(const char* name);

#define INN_CALL_TIM(name) _TIM_##name ()
#define INN_CALL_NAND(name) _NAND_##name ()
#define INN_CALL_SEQ(name) _SEQ_##name ()

/*----------------------------------------------------------
  for Calibration
----------------------------------------------------------*/
void         INN_FIT_POL1(int size, double* x_meas, double* y_meas, double *ptr_a, double *ptr_b,  double *ptr_chi2);

double       INN_MATH_LOG(double x);
double       INN_MATH_EXP(double x);
double       INN_MATH_POW(double x1, double x2);
double       INN_MATH_FABS(double x);

void         INN_SET_CAL();
double       INN_CALC_CAL(int pid, int range, double v);

bool         INN_CHECK_CAL(int pmu_range, double b, double a, double offset_error = 0.05, double gain_error = 0.05);
void         INN_EEPROM_READ_CALIB(int site, int hdut, int pmu_range, double* ptr_b, double* ptr_a);
void         INN_EEPROM_WRITE_CALIB(int site, int hdut, int pmu_range, double b, double a);

void         INN_EEPROM_READ_DOUBLE(int site, int addr, double* ptr_value);
void         INN_EEPROM_WRITE_DOUBLE(int site, int addr, double value);

void         INN_DOUBLE_TO_BYTE(double d_value, unsigned char* c_value);
void         INN_BYTE_TO_DOUBLE(unsigned char* c_value, double* ptr_d_value);

void         INN_EEPROM_READ(int site, int addr, unsigned long* ptr_data);
void         INN_EEPROM_WRITE(int site, int addr, unsigned long data);
void         INN_EEPROM_WRITE_EN(int site, bool enb);

int          INN_STRTOUL(const char *nptr, char **endptr, int base);
double       INN_ATOF(const char *nptr);
int          INN_ATOI(const char *nptr);

/*----------------------------------------------------------
  template
----------------------------------------------------------*/
void          INN_GOTO_PART(int nPart);
/***
int           __tpl_func_fclose(FILE *pStream);
int           __tpl_func_EndProc(void);
unsigned int  __tpl_func_GetSetupFileInt(const char*, const char*, int, const char*);
***/

int           INN_SOCKET_OPEN(const char* szHost, int nPort);
void          INN_SOCKET_CLOSE(int nSocket);
int           INN_SOCKET_SEND(int nSocket, const char* pData, int nDataLen);
int           INN_SOCKET_RECV(int nSocket, char* pData, int nDataLen);
int           INN_CHECK_SITE(int site);

int 		INN_INIT_TESTER( int dat1, int dat2 );
void 		INN_SET_DDUT( int wdut );
/*----------------------------------------------------------
----------------------------------------------------------*/
void  INN_SET_DEBUG_PRINT( int para1, int para2 );

class _progExit
{
public:
	_progExit(){};
	virtual ~_progExit(){};

	int 	_m_nCode;
	char	_m_msg[256];
};

/*----------------------------------------------------------
 New Match + etc
----------------------------------------------------------*/
//void         SML_MEAS_VS3( int n , float t ) ;
void         SML_REG_MPAT_PARA( int target, unsigned int data, int ALPG=-1 ) ;
void         SML_SET_REG_MPAT_PARA( int target, unsigned int data, int ALPG ) ;
unsigned int INN_READ_REGISTER( int site, int target ) ;
void         SML_READ_REGISTER_PARA( int target , unsigned int *data ) ;
void         SML_MEAS_MPAT_PARA( char *label ) ;
void         SML_MEAS_MPAT_PARA_RETURN( char *label ) ;
SM_DUTINFO * SML_GET_DUTINFO_PARA( int mode ) ;
void         SML_READ_PARA_SDUT( SM_DUTINFO *dutinfo );
void         SML_READ_PARA_MDUT( SM_DUTINFO *dutinfo );
void         SML_READ_PARA_EDUT( SM_DUTINFO *dutinfo );
void         SML_READ_PARA_CDUT( SM_DUTINFO *dutinfo );
void         SML_READ_PARA_MFDUT( SM_DUTINFO *dutinfo );
void         SML_GET_MAX_ALPG(int *n);
void         SML_GET_ALPG_NO(int wdut, int *alpg_no);		//2014-0226 追加要求

#endif
