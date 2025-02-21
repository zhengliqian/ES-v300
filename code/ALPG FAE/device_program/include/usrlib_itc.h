#ifndef _USERLIB_ITC_H
#define _USERLIB_ITC_H

#include "sml.h"


// DEFINE.ins

#define DUT_SIZE 1152

#define UT_ON  1
#define UT_OFF 0

#define g_Send_Mpat_Mode 1

////#define FBIN_TABLE_LENGTH 1000


// Add ITC, global variable for flow
extern int g_Bin;
extern int g_Rej;

extern int dut;
extern int TD;
extern int STP;

extern SM_DUTINFO *dutinfo;

extern SM_FBC fbc;
extern SM_DUM dum[20000];
extern char   pm[20000];
extern SM_DC  dc[DUT_SIZE];
extern SM_VS  vs[DUT_SIZE];
extern SM_FCN fcn[DUT_SIZE];

extern char item[100];
extern char start_date[20];
extern char mpa[100];
extern char startPc[100];

extern float grand_start_time;
extern float grand_end_time;
extern float start_time;
extern float end_time;
extern float UNIT;

void PIN_SET(void);
void PIN_FIXH(int sel);
void PIN_FIXL(int sel);
void PIN_OPEN(void);
void StdTim(void);
void ADDR_1(void);

void START_MPAT(void);
void START_MPAT(int md);
void MEAS_MPAT(int use_new_match);
void NEW_MATCH_MEAS_MPAT(int use_new_match);
void Read_Timer_End(int flg);
void Show_Reg_Mpat(void);
void GET_DUM(int sta, int sto);
void SET_DUM(int sta, int sto);

void TEST_INIT(void);
void TEST_END(void);

// Unit Convertion x1000(Write), /1000(Read)
#define ITC_UNIT_CONV 1000.0

void         UL_SML_WAIT_TIME( float t ) ;

void         UL_SML_VSIM( float vs , int vr , int ir , float c1 , float c2 ) ;
void         UL_SML_ISVM( float is , int ir , int vr , float c1 , float c2 ) ;
void         UL_SML_VS( int onoff , float vs , int vr , int ir , float ip , float im ) ;
#define      UL_SML_MVM SML_MVM
void         UL_SML_LIMIT( int unit , float u , float l ) ;

void         UL_SML_IN( int n , float vih , float vil ) ;
void         UL_SML_OUT( int n , float voh , float vol ) ;

void         UL_SML_TIME( int n, float t , int unit ) ;
#define      UL_SML_SRON SML_SRON
void         UL_SML_SROF( float t=0.003 ) ;
void         UL_SML_ROF( float t , int unit ) ;
void         UL_SML_RON( float t , int unit ) ;

void         UL_SML_READ_DC( SM_DC *dc ) ;
void         UL_SML_READ_VS( SM_VS *vs ) ;

void         UL_SML_MVM_WAIT(float t1, float t2);
void         UL_SML_VSIM_WAIT(float t1, float t2);
void         UL_SML_ISVM_WAIT(float t1, float t2);
void         UL_SML_VS_WAIT(float t1);

void         UL_SML_RATE(double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8);
void         UL_SML_ACLK(int id, double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8);
void         UL_SML_BCLK(int id, double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8);
void         UL_SML_CCLK(int id, double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8);
void         UL_SML_DREL(double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8);
void         UL_SML_DRET(double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8);
void         UL_SML_STRB(double ts1, double ts2, double ts3, double ts4, double ts5, double ts6, double ts7, double ts8);

void         UL_SML_RATE(int ts, double t);
void         UL_SML_ACLK(int n, int ts, double t);
void         UL_SML_BCLK(int n, int ts, double t);
void         UL_SML_CCLK(int n, int ts, double t);
void         UL_SML_DREL(int ts, double t);
void         UL_SML_DRET(int ts, double t);
void         UL_SML_STRB(int ts, double t);

#endif /* ifndef _USERLIB_ITC_H */
