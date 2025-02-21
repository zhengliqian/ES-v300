/**********************************************************************
Copyright (C), 2016-2019, YMTC Co., Ltd.
File name:      public.h
Date:			2018.10.25
Description:	define common handle funcions
Device:			JGS/TC5/TC6
**********************************************************************/

#ifndef __PUBLIC_H__
#define __PUBLIC_H__

//ITC #include <mem_check.h>
#include <sys/time.h>
#include <unistd.h>

#define DC_NA    *1e-6
#define DC_UA    *1e-3
#define DC_MA    *1
#define DC_A     *100

#define DC_UV    *1e-3
#define	DC_MV    *1
#define DC_V     *1000

#define PS    *1e-12
#define NS    *1e-9
#define US    *1e-6
#define MS    *1e-3
#define  S    *1.0

//TODO
//#define DDUTCNT  	1152
#define DDUTCNT  	36

								
#define TRUE  1
#define FALSE 0


#define BYTES_2K    2048
#define BYTES_16K   16384
#define BYTES_18K   18432

typedef enum
{
	PLANE_0 = 0,
	PLANE_1 = 1,
	PLANE_2 = 2,
	PLANE_3 = 3,
	PLANE_ALL,
}PL_VALUE;
#define PLANE_START					0
#define PLANE_END					3
#define PLANE_CNT					(PLANE_END - PLANE_START + 1)
#define PLANE_BITS                  2

typedef enum
{
	LOWER_HALF_BOTTOM_IDX = 0,
	LOWER_HALF_TOP_IDX,
	UPPER_HALF_BOTTOM_IDX,
	UPPER_HALF_TOP_IDX,
	TOTAL_SAMP_BLK,
} SAMP_BLK_IDX;

enum REM_TYPE {
	REM_MP, 
	REM_CORE, 
	REM_PB
};

enum PARAMETER_SRAM_TYPE {
	PARA_SRAM1, 
	PARA_SRAM2
};



typedef struct
{
	int EDC_Dct_Err[2];
	int EDC_Cnt_Err[16];
	int blk_ind;
	int msb_ind;
}STRUCT_EDC_RLT; 

typedef struct
{
	int compare_mode;
	int compare_data;
	int check_state;
	char *cmp_binfile;
} EDC_CHECK_INFO;

enum EDC_CHECK_MODE{ALL_CHUNK, CKBD_ERSTOP, CKBD_PGMBOT, ICKBD_ERSTOP, ICKBD_PGMBOT};

enum PLANE_MODE{SINGLE_PLANE_MODE, QUAD_PLANE_MODE, MODE_PL0, MODE_PL1,MODE_PL2,MODE_PL3};

enum TM_TYPE { TM1, TM2, TM3 };
//enum SOLUTION_TYPE {MP_ROM_READ, VPASSHV_FORCE_0V, DISABLE_VNEG_EN, ERASE_RESET_SUSPEND, ENHANCE_BL_VOL_BYPROGRAM};
enum SOLUTION_TYPE {MP_ROM_READ, VPASSHV_FORCE_0V, DISABLE_VNEG_EN, ERASE_RESET_SUSPEND, ENHANCE_BL_VOL_BYPROGRAM,  VFC_EVEN_ODD_CHANGE};

typedef enum {
	CFLAG_1 = 1,
	CFLAG_2,
	CFLAG_3,
	CFLAG_4,
	CFLAG_5,
	CFLAG_6,
	CFLAG_7,
	CFLAG_8,
	CFLAG_9,
	CFLAG_10,
	CFLAG_11,
	CFLAG_12,
	CFLAG_13,
	CFLAG_14,
	CFLAG_15,
	CFLAG_16
} CFLG_NUM;


typedef enum
{
	BLK8_OPTA = 0,
	BLK8_OPTB,
	BLK8_OPTC,
	BLK8_OPTD,
	BLK8_OPT_END
}BLK8_OPT_TYPE;

typedef enum
{
	BLK4_OPTA = 0,
	BLK4_OPTB,
	BLK4_OPTC,
	BLK4_OPTD,
	BLK4_OPTE,
	BLK4_OPTF,
	BLK4_OPTG,
	BLK4_OPT_END,
}BLK4_OPT_TYPE;


typedef enum 
{ 
	CLAT = 0, 
	D1, 
	D2, 
	D3, 
	LLAT, 
	SA,
}BUFFER_TYPE;

typedef enum
{
	RED_COL  = 0,
	MAIN_COL = 1,
	MAIN_RED = 2,
} COLUMN_TYPE;


typedef enum
{
	RESET  = 0,
	SET     = 1,
} OPERATION_TYPE;

typedef enum {
	NO_DPG = 0, 
	DPG_CH_CKBD, 
	DPG_CH_ICKBD, 
	DPG_BL_CKBD, 
	DPG_BL_ICKBD,
	DPG_ALL00, 
	DPG_ALLFF, 
	DPG_ALL55, 
	DPG_ALLAA,
	PB_1000,
	PB_0100, 
	PB_0010, 
	PB_0001
} DPG_PAT_TYPE;

typedef struct{
	int plane_start;
	int plane_end;	
	int byte_start;
	int byte_end;
	int page_start;
	int page_end;
	int block_start;
	int block_end;
	char bin_file[128];     //DBM file
	int data;               //APG set data
	int data_source;        //from APG or DBM bin file
	int operation_mode;     //transfer,set,reset
//	int test_mode;          //redundant column test,main cloumn test
	OPERATION_TYPE opt_type;
	COLUMN_TYPE col_type; 
	BUFFER_TYPE buf_type;			
	DPG_PAT_TYPE dpg_pat;
	char title[128]; 
}PB_STRUCT;



typedef struct
{
	int vlaue;
	int flag;
}S_WL_CONVERT;


typedef struct
{
	int phy_num;
	int plane;
	int addr_2_10;	
	int logic_num;
} STRUCT_BLK_TABLE;


extern STRUCT_BLK_TABLE BlkTable[];
/* pin name information*/
typedef struct
{
	int pinno;
	char pinname[10];
	int vsno;
	char vsname[10];
}PIN_STRUCT;

typedef struct
{
	char Name[100];
	int Cnt;
} PARAMETER_STRUCT;

typedef struct{
	int p1;
	int p2;
	int p3;
	int p4;
	int addr;
}FEATURE_STRUCT;

typedef struct{
	int mode;
	int index_start;
	int index_end;
	int group_start;
	int group_end;
	int ram_start;
	int ram_end;
	int data;
}REG_STRUCT;

typedef enum {
	WL_LKG_X1 = 0,
	WL_LKG_X4,
	WL_LKG_X8,
} WL_LKG_MEAS_TYPE;

typedef enum 
{
	SINGLE_TSG_LKG = 0,
	ALL_TSG_LKG,
	BSG_LKG,
	DUMMY_LKG,
	IDPDUMMY_LKG,
	ODD_WL_LKG,
	EVEN_WL_LKG,
	SINGLE_WL_LKG,
	TSG_BSG_LKG,
	ALL_BSG_LKG,
	EVEN_TSG_LKG,
	ODD_TSG_LKG,
	BSG_LKG_SPV,
} WL_LKG_TYPE;

typedef enum
{
	TLC_MODE = 1,
	SLC_MODE,
	QLC_MODE,
} CELL_MODE;


typedef enum
{
	P0 = 0,
	P1,
	P2,
	P3,
	P4,
	P5,
	P6,
	P7,
	CELL_LEVEL_MAX,
} CELL_LEVEL;


typedef struct{
	int cmd;
	int r3;
	int tmeas_data;
	int meas_item;
	int external_timer_mode;
	int cmd1;
	int cmd2;
	double Force_Vol;
	int Force_Current;
	char pat[100];
	int meas_limit;
	WL_LKG_TYPE lkg_type; 
	WL_LKG_MEAS_TYPE meas_type;
}MEASURE_STRUCT;

typedef struct{
	int plane;
	int cmd1;
	int cmd2;
	int Force_Vol;
	int Force_Current;
	char pat[100];
}VMON_MEASURE;


typedef struct
{
	char szData[128+1];
}string; 


typedef enum 
{
	DS_DBM = 0,
	DS_APG,
	DS_RDMZ,
}DATA_SOURCE;

typedef enum
{
	SINGLE_PL = 0, 
	DUAL_PL,
	QUAD_PL,
	SINGLE_PL_0,
	SINGLE_PL_1,	
	SINGLE_PL_2,
	SINGLE_PL_3,
}PL_TYPE;

typedef enum {
	MLC_LSB_PAGE,
	MLC_MSB_PAGE, 
	MLC_PAGE, 
	TLC_LOW_PAGE, 
	TLC_MED_PAGE, 
	TLC_UP_PAGE,
	TLC_PAGE, 
	DUAL_PAGE,
	SLC_PAGE, 
	TSG_PAGE, 
	DUMMY_PAGE,
	TRIP_PAGE,
	TLC_SINGLE_PAGE, 
	BSG_PAGE, 
	TSG_BL_LEK, 
	BSG_BL_LEK,
}PAGE_TYPE;


typedef enum 
{
	NOR_BLK = 0,
	SPECIAL_BLK,
	USER_CFG_BLK,
	CFG_BLK,
	BLK_TYPE_CNT,
}BLK_TYPE;



typedef struct
{
     int  DefData;   // default value
     int  UsrData;   // user value
     int  DutData;  // real-time update value
} STRUCT_TRIM_DATA;

typedef struct
{
	char name[40];
	int byte_size;
	int length;
	int lo_addr;
	int lo_len;
	int lo_lsb;
	int lo_mask;
	int hi_addr;
	int hi_len;
	int hi_lsb;
	int hi_mask;
	int linear;
	int min;
	int max;
	float start_val;
	float step_val;
	int def_dac;
	float def_val;
	int rd_only;
} STRUCT_REG_TABLE;

typedef struct
{
	int GroupNo;
	int Index;
	int Mask;
	int rw_flag;
	int InitVal;
} STRUCT_TRIM_TABLE;



typedef struct
{
    REM_TYPE rem_type;
    int rem_start;
    int rem_end;
}STRUCT_REM_CHECK;

typedef struct
{
    PARAMETER_SRAM_TYPE sram_type;
    int sram_start;
    int sram_end;
}STRUCT_PARAMETER_SRAM;


typedef struct{
	int addr_in_ubm;
	int plane_start;
	int plane_end;
	int block_start;
	int block_end;
	int string_start;
	int string_end;
	int wl_start;
	int wl_end;
	int page_start;
	int page_end;
	int byte_start;
	int byte_end;
	PL_TYPE  pl_type;
	BLK_TYPE blk_type;	
	PAGE_TYPE pg_type;
}ADDRESS_STRUCT;

typedef enum {
	NO_DATAIN,
	SOLID_DATAIN,
	BINFILE_DATAIN,
	DPG_DATAIN,
	RANDOM_DATAIN,
	COMPRESS_DATAIN,
}DATAIN_TYPE;

typedef struct {
	DATAIN_TYPE type;
	int solid_data[3]; // low-page data, med-page data, upper-page data
	int bin_file[128]; // pgm bin file name
	int rnd_seed[6]; // low-page seed[0] seed[1], med-page seed[2] seed[3], upper-page seed[4] seed[5]
	char compress_bin[128]; // compress key binfile name
	DPG_PAT_TYPE dpg_type;
}DATAIN_STRUCT;

typedef struct{
	int sample_blk[DDUTCNT][2000];
	int sample_blk_cnt;
	int string_start;
	int string_end;
	int wl_start;
	int wl_end;
	int page_start;
	int page_end;
	int byte_start;
	int byte_end;
	PL_TYPE  pl_type;
	BLK_TYPE blk_type;	
	PAGE_TYPE pg_type;
}ADDRESS_UBM_STRUCT;

#define ARRAY_ROW_MAX 64
#define ARRAY_COLUMN_MAX 2

typedef struct{
	int sample_blk[DDUTCNT][1980];
	int sample_blk_cnt;
	int string_list[ARRAY_ROW_MAX][ARRAY_COLUMN_MAX];
	int string_cnt;
	int wl_list[ARRAY_ROW_MAX][ARRAY_COLUMN_MAX];
	int wl_cnt;
	int page_list[ARRAY_ROW_MAX][ARRAY_COLUMN_MAX];
	int page_cnt;
	int byte_list[ARRAY_ROW_MAX][ARRAY_COLUMN_MAX];
	int byte_cnt;
	PL_TYPE  pl_type;
	BLK_TYPE blk_type;	
	PAGE_TYPE pg_type;
}ADDRESS_LIST_UBM_STRUCT;

typedef struct 
{
	int dbm_bfile_start;
	int dbm_bfile_loop;
	int dbm_addr_start; 
	int dbm_addr_loop; 
	int dbm_block_loop;
	int dbm_page_loop;
	int dbm_byte_start;
	int dbm_byte_loop;	
} ADDRESS_DBM_STRUCT;


typedef struct {
	int plane_list[ARRAY_ROW_MAX][ARRAY_COLUMN_MAX]; 
	int plane_cnt;
	int block_list[ARRAY_ROW_MAX][ARRAY_COLUMN_MAX]; 
	int block_cnt;
	int string_list[ARRAY_ROW_MAX][ARRAY_COLUMN_MAX];
	int string_cnt;
	int wl_list[ARRAY_ROW_MAX][ARRAY_COLUMN_MAX];
	int wl_cnt;
	int page_list[ARRAY_ROW_MAX][ARRAY_COLUMN_MAX];
	int page_cnt;
	int byte_list[ARRAY_ROW_MAX][ARRAY_COLUMN_MAX];
	int byte_cnt;
	int addr_in_ubm;

	PL_TYPE  pl_type;
	BLK_TYPE blk_type;	
	PAGE_TYPE pg_type;
}ADDRESS_LIST_STRUCT;

typedef enum
{
	DBM_PLANE = 0,
	DBM_BLOCK,
	DBM_STRING,
	DBM_WL,
	DBM_PAGE,
	DBM_BYTE,
	DBM_VAR_MAX,
}DBM_VAR_TYPE;

#define DBM_STR_LEN 40
typedef struct
{
	DBM_VAR_TYPE type;
	char name[DBM_STR_LEN];
	char value[DBM_STR_LEN];
	char default_value[DBM_STR_LEN];
}DBM_VAR;


typedef enum
{
	ADDR_PLANE = 0,
	ADDR_BLOCK,
	ADDR_STRING,
	ADDR_WL,
	ADDR_PAGE,
	ADDR_BYTE,
	ADDR_VAR_MAX,
}ADDRESS_VAR_TYPE;

#define ADDR_STR_LEN 40
typedef struct
{
	ADDRESS_VAR_TYPE type;
	char name[ADDR_STR_LEN];
	char value[ADDR_STR_LEN];
	char default_value[ADDR_STR_LEN];
}ADDRESS_VAR_STRUCT;


#define DBM_BFILE_MAX_NUM 16
typedef struct 
{
	char name[64];
}BFILE;

typedef struct 
{
	int total_num;
	BFILE bfile[DBM_BFILE_MAX_NUM];
}BFILE_LIST;



#define Var_check(var,min,max) \
do {\
	 if((var)<(min) || (var)>(max))\
	 	{ \
	 		printf((char *)"Please set variable \"%s\" in range (%d,%d)! Current value: %d \n",#var,min,max,var);\
			return -1;\
	 	} \
} while(0)

#define max(a,b) ( ((a)>(b)) ? (a):(b) )
#define min(a,b) ( ((a)>(b)) ? (b):(a) )
	 
#define SCANF(choice_string) fflush( stdout );\
			 fflush( stdin );\
			 scanf( (char *)"%[^\n]%*c", (choice_string) );
	 
	 
//#define MALLOC(type, size) ((type *)malloc((size) * sizeof(type)))
#define MEMSET(ptr, value, size) memset(ptr, value, size)
#define ASSERT(condition)  \
	 { \
		 if (!(condition)) \
			 printf("Assertion %s failed at %s:%d\n", __FUNCTION__, __FILE__, __LINE__); \
			 /*abort(); */ return -1;\
	 }
	 
#if 0	 
#define FREE(ptr) \
	 if((ptr) != NULL) \
	 {\
		 free(ptr);\
		 ptr = NULL;\
	 }
#endif
	 
#define zero_variable(var)	memset(&var, 0, sizeof(var))
#define declare_address_list_and_zero(addr_list)  ADDRESS_LIST_STRUCT addr_list;memset(&addr_list, 0, sizeof(addr_list));
#define address_list_copy(dst, src)  memcpy(&dst, &src, sizeof(dst));


#define BEGIN_ADDR_LOOP(list) \
	 {																 \
		 int __i = 0, __j = 0, __k = 0, __m = 0, __n = 0;			 \
		 int n_pl = 0, n_blk = 0, n_wl = 0, n_str = 0, n_byte = 0;	 \
		 int flag_blk = 1, flag_wl = 1, flag_str = 1, flag_byte = 1; \
		 int __blk_loop = 0, __wl_loop = 0, __str_loop = 0, __byte_loop = 0; \
		 if (list.plane_cnt == 0) { \
			 list.block_cnt = 0; list.wl_cnt = 0; list.string_cnt = 0; list.byte_cnt = 0; \
		 } \
		 else if (list.block_cnt == 0) { \
			 list.wl_cnt = 0; list.string_cnt = 0; list.byte_cnt = 0; \
		 } \
		 else if (list.wl_cnt == 0) { \
			 /*list.string_cnt = 0; list.byte_cnt = 0;*/\
		 } \
		 else if (list.string_cnt == 0) { \
			 list.byte_cnt = 0; \
		 } \
		 for (__i = 0; __i < list.plane_cnt; __i++) { \
			 for (n_pl = list.plane_list[__i][0]; n_pl <= list.plane_list[__i][1]; n_pl++) { \
				 for (__j = 0, flag_blk = 1; __j < ((list.block_cnt <= 0) ? 1 : list.block_cnt); __j++) { \
					 for (n_blk = list.block_list[__j][0]; (n_blk <= list.block_list[__j][1]) && (flag_blk > 0); n_blk++) { \
						 flag_blk = (list.block_cnt <= 0) ? 0 : 1; \
						 __wl_loop = 0; __str_loop = 0; __byte_loop = 0; \
						 /*printf("*** __wl_loop = %d, __str_loop = %d __byte_loop = %d***\n", __wl_loop, __str_loop, __byte_loop); */\
						 for (__k = 0, flag_wl = 1; __k < ((list.wl_cnt <= 0) ? 1 : list.wl_cnt); __k++) { \
							 for (n_wl = list.wl_list[__k][0]; (n_wl <= list.wl_list[__k][1]) && (flag_wl > 0); n_wl++) { \
								 flag_wl = (list.wl_cnt <= 0) ? 0 : 1; \
								 if ((__k == list.wl_cnt - 1) && (n_wl == list.wl_list[__k][1])) __wl_loop = 1; \
								 if (0 == list.wl_cnt) __wl_loop = 1; \
								 for (__m = 0, flag_str = 1; __m < (list.string_cnt <= 0 ? 1 : list.string_cnt); __m++) { \
									 for (n_str = list.string_list[__m][0]; (n_str <= list.string_list[__m][1]) && (flag_str > 0); n_str++) { \
										 flag_str = (list.string_cnt <= 0) ? 0 : 1; \
										 if ((__m == list.string_cnt - 1) && (n_str == list.string_list[__m][1])) __str_loop = 1; \
										 if (0 == list.string_cnt) __str_loop = 1; \
										 for (__n = 0, flag_byte = 1; __n < (list.byte_cnt <= 0 ? 1 : list.byte_cnt); __n++) { \
											 for (n_byte = list.byte_list[__n][0]; (n_byte <= list.byte_list[__n][1]) && (flag_byte > 0); n_byte++) { \
												 flag_byte = (list.byte_cnt <= 0) ? 0 : 1; \
												 if ((__n == list.byte_cnt - 1) && (n_byte == list.byte_list[__n][1])) __byte_loop = 1; \
												 if (0 == list.byte_cnt) __byte_loop = 1; \
												 __blk_loop = __wl_loop && __str_loop && __byte_loop; \
												 /*printf("__blk_loop = %d, __wl_loop = %d, __str_loop = %d, __byte_loop = %d\n", __blk_loop, __wl_loop, __str_loop, __byte_loop);*/  \
												 printf("n_pl = %d, n_blk = %d, n_wl = %d, n_str = %d, n_byte = %d\n", n_pl, n_blk, n_wl, n_str, n_byte); \
												 n_pl = n_pl; n_blk = n_blk; n_wl = n_wl; n_str = n_str; n_byte = n_byte;
	 
#define END_ADDR_LOOP										\
											 }						 \
										 }							 \
									 }								 \
								 }									 \
							 }										 \
						 }											 \
					 }												 \
				 }													 \
			 }														 \
		 }															 \
	 }			 



/*
 * Description: Calculate array lenght
 * 
 * Parameter  : array_name - array name
 *
 * Author:  William Song
 *
 * Date:    2019.2.21
 *
 * Sample: 
 * 			int a[] = {1, 2, 3, 5, 100, 34, 57};
 * 			int len = ARRAY_LEN(a);
 *
 */
#define ARRAY_LEN(array_name)  (sizeof(array_name)/sizeof(array_name[0]))


#define PAGE_MODE_TO_STRING(mode)  ((mode == SLC_PAGE) ? (char *)"SLC" : (char *)"TLC")

int array_sort(int *input_array, int input_len, int *output_array);
int get_string_variable(char *sting, int *result);
int split_str(char *source, char *delim, string *pStr);

int _print_systime(const char *func, int line, int local);
#define print_systime(local)   _print_systime(__func__, __LINE__, local)


int string_to_address_list(ADDRESS_LIST_STRUCT &list, char *plane_str, char *block_str, 
	char *string_str, char *wl_str, char *page_str, char *byte_str);
int string_to_address_list(ADDRESS_LIST_STRUCT *list, char *plane_str, char *block_str, 
	char *string_str, char *wl_str, char *page_str, char *byte_str);
char* range_str_connect(int n, ...);
char *itoa(int d);

char *int_arry_to_string(int a[], int ele_cnt);
#define arry_to_s(a) int_arry_to_string(a ,sizeof(a)/sizeof(a[0]))
char *range_to_string(int start, int end);
#define r_to_s  range_to_string
int set_addr_list(char *input, int input_len, int output[][2], int *output_len);


int bubble_rank(float* value, int count, int dut);
int bubble_rank(int* value, int count, int dut);
int bubble_rank(int* value, int count);

int get_addr_list_norblk(ADDRESS_LIST_STRUCT *input_list, ADDRESS_LIST_STRUCT *output_list);
int get_addr_norblk(ADDRESS_STRUCT *input_address, ADDRESS_STRUCT *output_address);
int get_addr_list_specialblk(ADDRESS_LIST_STRUCT *input_list, ADDRESS_LIST_STRUCT *output_list);
int get_addr_specialblk(ADDRESS_STRUCT *input_address, ADDRESS_STRUCT *output_address);
int get_addr_list_norblk_ubm(ADDRESS_LIST_UBM_STRUCT *input_list, ADDRESS_LIST_UBM_STRUCT *output_list);
int get_addr_norblk_ubm(ADDRESS_UBM_STRUCT *input_address, ADDRESS_UBM_STRUCT *output_address);
int get_fcm_xsize(ADDRESS_STRUCT address);
int get_fcm_xbit(ADDRESS_STRUCT address);

#endif	/* __PUBLIC_H__ */
