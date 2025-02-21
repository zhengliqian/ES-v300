#include "global.h"

int g_pin_open = 1;
char* g_tname = NULL;

void Dummy(char* Label, char* Test_Name)
{}

void pre_exec(char* Label, char* Test_Name)
{
	PrintLog("\n%s %s\n", Label, Test_Name);
	g_tname = Test_Name;
	
	char	t_str[128];
	time_t	t_time;
	t_time = time(0);
	strftime(t_str,127,"%H:%M:%S",localtime(&t_time));
	PrintLog("Item Start: %s\n",t_str);
}

void post_exec(char* Label, char* Test_Name)
{
	char	t_str[128];
	time_t	t_time;
	t_time = time(0);
	strftime(t_str,127,"%H:%M:%S",localtime(&t_time));
	PrintLog("Item End: %s\n\n",t_str);
	
	if(g_pin_open == 1)
	{
		SML_VS(OFF, 0 DC_V, R4V, M2MA, 2 DC_MA, -2 DC_MA); 
		PIN_OPEN();

		g_por = 0;
	}
	SML_WAIT_TIME(100 MS);
}
//**************************************
//   Flow definition
//**************************************
#ifdef RUN_TEST
#undef RUN_TEST
#endif
//                Label , Function            , Rej ,  pre_exec     , post_exec    , P Branch, F Branch, Bin , Test Name
#define RUN_TEST( Label , Function            , Rej ,  pre_exec     , post_exec    , P_Branch, F_Branch, Bin , Test_Name) \
void _PART_BIN_##Bin( void ) { \
	INN_SET_PART_NO(Bin); \
	INN_SET_PART(_INN_ITEM, Test_Name); INN_PRINT_PART(_INN_ITEM); \
	INN_SET_PART(_INN_COMMENT, "Label=" Label ", TestName=" Test_Name); \
	INN_CATEGORY(Bin); \
	SML_TEST(Bin); \
	g_Rej = Rej; \
	g_Bin = Bin; \
	pre_exec(Label,Test_Name); \
	Function(); \
	post_exec(Label,Test_Name); \
}
//	REJ  = valueREJ;
#include "flow_demo.txt"

#ifdef RUN_TEST
#undef RUN_TEST
#endif
//                Label , Function            , Rej ,  pre_exec     , post_exec    , P Branch, F Branch, Bin , Test Name
#define RUN_TEST( Label , Function            , Rej ,  pre_exec     , post_exec    , P_Branch, F_Branch, Bin , Test_Name) \
  {Bin, &_PART_BIN_##Bin},

static __tpl_PART_FUNC __tpl_PART_FUNC_TBL[] =
{
#include "flow_demo.txt"
};

static int __tpl_nRunEndPart = -1;



//**************************************
//   Flow definition
//**************************************
#define __tpl_PART_FUNC_MAX			((int)(sizeof(__tpl_PART_FUNC_TBL) / sizeof(__tpl_PART_FUNC_TBL[0])))
int main(int argc, char* argv[])
{

//	TestStart ();

// Parameters for SML Lib
#ifdef  OPEMODE
	INN_SET_DEFINE(0,0,1);
#else
	INN_SET_DEFINE(0,0,0);
#endif

#ifdef	LOGPRINT
	INN_SET_LOGPRINT(1);
#else
	INN_SET_LOGPRINT(0);
#endif

#ifdef	LOGFILE
	INN_SET_LOGFILE(1);
#else
	INN_SET_LOGFILE(0);
#endif

#ifdef	USE_SHARE
	INN_SET_USE_SHARE(1);
#else
	INN_SET_USE_SHARE(0);
#endif

#ifndef __SKIP_CAL_LOAD
	INN_SET_DEFINE_OPTION("__SKIP_CAL_LOAD", 1);
#else
	INN_SET_DEFINE_OPTION("__SKIP_CAL_LOAD", 0);
#endif

#ifdef	USE_BACKTRACE
	INN_SET_USE_BACKTRACE(1);
#endif

    PrintLog("\n\n==========Test Start==========\n");
	
// Start Main flow
	int r = INN_FLOW_TEST_MAIN(__tpl_PART_FUNC_TBL, __tpl_PART_FUNC_MAX,
							__tpl_nRunEndPart);

    PrintLog("==========Test End==========\n");
	
	return r;
}
