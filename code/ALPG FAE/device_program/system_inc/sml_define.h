//######## sml_define.h #############################################################
//2010/11/22	新規

#ifndef __SML_DEFINE_H__
#define __SML_DEFINE_H__

#define	OFF		0
#define	ON		1
#define	ON_PIN	2

#define	ALL		0
#define	SINGLE	1

#define	DISABLE	0
#define	ENABLE	1

#define NOMORE	-1
#define	NEGLECT	99999

#define DDUT	0
#define SDUT	1
#define MDUT	2
#define EDUT	3
#define CDUT	4
#define PDUT	5
#define FDUT	6
#define GFDUT	7
#define XDUT	8
#define MFDUT	9	//New Match

#define RUN			0x10
#define WAIT		0x20

#define _VS		0
#define MVM		1
#define ISVM	2
#define VSIM	3

#define AS1		1
#define AS2		2
#define AS3		3
#define AS4		4
#define AS5		5
#define AS6		6
// for AS16
#define AS7		7
#define AS8		8
#define AS9		9
#define AS10	10
#define AS11	11
#define AS12	12
#define AS13	13
#define AS14	14
#define AS15	15
#define AS16	16

#define X0		1
#define X1		2
#define X2		3
#define X3		4
#define X4		5
#define X5		6
#define X6		7
#define X7		8
#define X8		9
#define X9		10
#define X10		11
#define X11		12
#define X12		13
#define X13		14
#define X14		15
#define X15		16
#define X16		17
#define X17		18
#define Y0		19
#define Y1		20
#define Y2		21
#define Y3		22
#define Y4		23
#define Y5		24
#define Y6		25
#define Y7		26
#define Y8		27
#define Y9		28
#define Y10		29
#define Y11		30
#define Y12		31
#define Y13		32
#define Y14		33
#define Y15		34
#define Y16		35
#define Y17		36
#define Z0		37
#define Z1		38
#define Z2		39
#define Z3		40
#define Z4		41
#define Z5		42
#define Z6		43
#define Z7		44
#define Z8		45
#define Z9		46
#define Z10		47
#define Z11		48
#define Z12		49
#define Z13		50
#define Z14		51
#define Z15		52
#define Z16		53
#define Z17		54
#define H		55
#define L		56

//for Address32bit
#define X18		57
#define X19		58
#define X20		59
#define X21		60
#define X22		61
#define X23		62
#define X24		63
#define X25		64
#define X26		65
#define X27		66
#define X28		67
#define X29		68
#define X30		69
#define X31		70

#define Y18		71
#define Y19		72
#define Y20		73
#define Y21		74
#define Y22		75
#define Y23		76
#define Y24		77
#define Y25		78
#define Y26		79
#define Y27		80
#define Y28		81
#define Y29		82
#define Y30		83
#define Y31		84

#define Z18		85
#define Z19		86
#define Z20		87
#define Z21		88
#define Z22		89
#define Z23		90
#define Z24		91
#define Z25		92
#define Z26		93
#define Z27		94
#define Z28		95
#define Z29		96
#define Z30		97
#define Z31		98

#define	AFM_C0		99
#define	AFM_C1		100
#define	AFM_C2		101
#define	AFM_C3		102
#define	AFM_C4		103
#define	AFM_C5		104
#define	AFM_C6		105
#define	AFM_C7		106
#define	AFM_C8		107
#define	AFM_C9		108
#define	AFM_C10	    109
#define	AFM_C11	    110

// 57-122は他機種(QUEST-FC)で使用している為、
// 被り防止の為、FPGA上で未使用にしたいとの事
#define MC0		123

//OR setあり(IN1 - VS2)
#define	_IN		0x100
#define	IN1		0x100
#define	IN2		0x200
#define	IN3		0x400
#define	DAC		0x800
#define	DC		0x1000
#define _DC_PE	0x2000
#define	VS		0x10000
#define	_CAL		0x20000
#define	_FCN		0x40000

#define	FIXL	0
#define	FIXH	1
#define	NRZA	2
#define	NRZB	3
#define	NRZC	4
#define	RZO		5
#define	I_NRZA	10
#define	I_NRZB	11
#define	I_NRZC	12
#define	I_RZO	13

#define	ACLK0		0x0		// 省略時の番号
#define	ACLK1		0x1
#define	ACLK2		0x2
#define	ACLK3		0x3

#define	BCLK0		0x0		// 省略時の番号
#define	BCLK1		0x1
#define	BCLK2		0x2
#define	BCLK3		0x3

#define	CCLK0		0x0		// 省略時の番号
#define	CCLK1		0x1
#define	CCLK2		0x2
#define	CCLK3		0x3

#define	DRENRZ		0x3
#define	DRERZ		0x5

#define	RATE		0x3A

#define STRB		0x4A
#define	D0			0x4B

//HINIT/LINIT/OFF
#define	LINIT		-1
#define	HINIT		1

#define	C0			2
#define	C1			3
#define	C2			4
#define	C3			5
#define	C4			6
#define	C5			7
#define	C6			8
#define	C7			9
#define	C8			10
#define	C9			11
#define	C10			12
#define	C11			13


#define	OUT1		0x7C
#define	OUT2		0x7D
#define	OUT3		0x7E

//register
#define	X		10	//0xD040
#define	Y		11	//0xD044
#define	Z		12	//0xD048
#define	D1		20	//0xD200
#define	D2		21	//0xD204
#define	D3		22	//0xD208
#define	D4		23	//0xD20C
#define	D5		24	//0xD210
#define	D6		25	//0xD214
#define	D7		26	//0xD218
#define	D8		27	//0xD21C
#define	D9		40	//0xD220
#define	D10		41	//0xD224
#define	D11		42	//0xD228
#define	D12		43	//0xD22C
#define	D13		44	//0xD230
#define	D14		45	//0xD234
#define	D15		46	//0xD238
#define	D16		47	//0xD23C
#define	TIMER1	30	//0xD300
#define	TIMER2	31	//0xD304
#define	TIMER3	32	//0xD308
#define	TIMER4	33	//0xD30C
#define	TIMER5	34	//0xD310
#define	TIMER6	35	//0xD314
#define	TIMER7	36	//0xD318
#define	TIMER8	37	//0xD31C
#define	XMAX	50	//0xD050
#define	YMAX	51	//0xD054
#define	ZMAX	52	//0xD058
#define	IDX1	61	//0xD400
#define	IDX2	62	//0xD404
#define	IDX3	63	//0xD408
#define	IDX4	64	//0xD40C
#define	IDX5	65	//0xD410
#define	IDX6	66	//0xD414
#define	IDX7	67	//0xD418
#define	IDX8	68	//0xD41C
#define	IDX9	69	//0xD420
#define	IDX10	70	//0xD424
#define	IDX11	71	//0xD428
#define	IDX12	72	//0xD42C
#define	IDX13	73	//0xD430
#define	IDX14	74	//0xD434
#define	IDX15	75	//0xD438
#define	IDX16	76	//0xD43C
#define	TP		79	//0xD030
#define	TPH		81	//0xD100
#define	TPH1	81	//0xD100
#define	TPH2	82	//0xD104
#define	TPH3	83	//0xD108
#define	TPH4	84	//0xD10C
#define	TPH5	85	//0xD110
#define	TPH6	86	//0xD114
#define	TPH7	87	//0xD118
#define	TPH8	88	//0xD11C
#define	CFLG	90	//0xD010
#define	CFLG1	91	//0xD010
#define	CFLG2	92	//0xD010
#define	CFLG3	93	//0xD010
#define	CFLG4	94	//0xD010
#define	CFLG5	95	//0xD010
#define	CFLG6	96	//0xD010
#define	CFLG7	97	//0xD010
#define	CFLG8	98	//0xD010
#define	CFLG9	99	//0xD010
#define	CFLG10	100	//0xD010
#define	CFLG11	101	//0xD010
#define	CFLG12	102	//0xD010
#define	CFLG13	103	//0xD010
#define	CFLG14	104	//0xD010
#define	CFLG15	105	//0xD010
#define	CFLG16	106	//0xD010
#define	CFLG17	107	//0xD010
#define	CFLG18	108	//0xD010
#define	CFLG19	109	//0xD010
#define	CFLG20	110	//0xD010
#define	CFLG21	111	//0xD010
#define	CFLG22	112	//0xD010
#define	CFLG23	113	//0xD010
#define	CFLG24	114	//0xD010
#define	CFLG25	115	//0xD010
#define	CFLG26	116	//0xD010
#define	CFLG27	117	//0xD010
#define	CFLG28	118	//0xD010
#define	CFLG29	119	//0xD010
#define	CFLG30	120	//0xD010
#define	CFLG31	121	//0xD010
#define	CFLG32	122	//0xD010
#define	MSKSTB	123	//0xD018
#define	MFLG	124	//			read only NG
#define	PC		160	//0xC038	read only
#define	BAR		161	//0xD014
#define	MSTA	162	//0xD020
#define	PSTA	163	//0xD024
#define	RDM		164	//0xD028
#define MC      165 //0xD060
#define	Q1		166	//0xD600
#define	Q2		167	//0xD604
#define	Q3		168	//0xD608
#define	Q4		169	//0xD60C
#define	Q5		170	//0xD610
#define	Q6		171	//0xD614
#define	Q7		172	//0xD618
#define	Q8		173	//0xD61C
#define	P1		174	//0xD620
#define	P2		175	//0xD624
#define	P3		176	//0xD628
#define	P4		177	//0xD62C
#define	P5		178	//0xD630
#define	P6		179	//0xD634
#define	P7		180	//0xD638
#define	P8		181	//0xD63C


/*----------------------------------------------------------
----------------------------------------------------------*/
#define	R1MS		3
#define	R10MS		4
#define	R100MS		5
#define	R1S			6
#define	R10S		7

// AD5522 - 5uA Range
#define	M5UA		1
#define	R5UA		1
#define	M10UA		1	// 5uAレンジを10uAとして使う
#define	R10UA		1

// AD5522 - 5uA Range
//#define	M10UA		2
//#define	R10UA		2
#define	M20UA		2
#define	R20UA		2

// AD5522 - 200uA Range
#define	M100UA		3
#define	R100UA		3
#define	M200UA		3
#define	R200UA		3

// AD5522 - 2mA Range
#define	M1MA		4
#define	R1MA		4
#define	M2MA		4
#define	R2MA		4

// AD5522 - 25mA Range
#define	M25MA		5
#define	R25MA		5
#define	M50MA		5
#define	M100MA		5

// DPS 200mA Range
#define	M200MA		6

// ADC-Direct Range
#define	R5V			8
#define	M5V			8

// PMU-VF/VM Range
#define	R10V		9
#define	M10V		9
#define R8V			9
#define M8V			9
#define	M30V		9

// DPS Range
#define R4V         10

/*----------------------------------------------------------
----------------------------------------------------------*/
// Part Info
#define _INN_ITEM		1
#define _INN_COMMENT	2
#define _INN_INIT		3
#define _INN_SEQUENCE	4
#define _INN_TIMING		5
#define _INN_ITEM_END	10

#define	ITEM		1
#define	COMMENT		2
#define	INIT		3
#define	SEQUENCE	4
#define	TIMING		5

/*----------------------------------------------------------
----------------------------------------------------------*/
// Timing
#define TS1         0
#define TS2         1
#define TS3         2
#define TS4         3
#define TS5         4
#define TS6         5
#define TS7         6

/*----------------------------------------------------------
----------------------------------------------------------*/
#define _MAX_DUT		2304

/*----------------------------------------------------------
----------------------------------------------------------*/
#define PIN1		1
#define PIN2		2
#define PIN3		4
#define PIN_VS		8

#define	_LOG_OFF	0x0
#define	_LOG_ON		0x1
#define	_LOG_RON	0x2
#define	_LOG_WON	0x3

#define _RESET_SYSTEM		0x01
//#define _RESET_DC			0x02
//#define _RESET_FUNC		0x04
//#define _RESET_EMG		0x08
#define _RESET_ALL			0x0F

#define DUM		0
#define AFM		1


/***********************************************************
	構造体
***********************************************************/
/*- Structure SM_DC ---------------------------------------------------*/
typedef struct {
             int             dut ;
             int             ch1_pf ;
             int             ch2_pf ;
             int             ch3_pf ;
             int             vs_pf ;
             int             iv ;
             float           ch1_value ;
             float           ch2_value ;
             float           ch3_value ;
             float           vs_value ;
}                               SM_DC ;
/*- Structure SM_VS ---------------------------------------------------*/
typedef struct {
             int             dut ;
             int             pf ;
             float           value ;
}                               SM_VS ;
/*- Structure SM_FCN --------------------------------------------------*/
typedef struct {
             int             dut ;
             int             pf ;
             int             value ;
}                               SM_FCN ;
/*- Structure SM_DUT --------------------------------------------------*/
typedef struct {
             int             A[ 72 ] ;
}                               SM_DUT ;
/*- Structure SM_DUTINFO ----------------------------------------------*/
typedef struct {
             int             A[ 72 ] ;
}                               SM_DUTINFO ;
/*- Structure SM_DUTINFO ----------------------------------------------*/

typedef struct {
             unsigned char value[ _MAX_DUT ] ;
} SM_DUM_2304 ;

typedef struct {
             unsigned int value[ _MAX_DUT ] ;
} SM_FBC_2304 ;

typedef struct {
             unsigned char value[ _MAX_DUT/2 ] ;
} SM_DUM_1152 ;

typedef struct {
             unsigned int value[ _MAX_DUT/2 ] ;
} SM_FBC_1152 ;


#ifdef USE_SHARE

	#define SM_DUM SM_DUM_2304
	#define SM_FBC SM_FBC_2304

#else

	#define SM_DUM SM_DUM_1152
	#define SM_FBC SM_FBC_1152

#endif

/****
class SM_DUM{
public:
	unsigned char *value;
	SM_DUM(){
		value = new unsigned char [ _MAX_DUT ];
	}
	~SM_DUM(){
		delete [] value;
	}
};
****/

/*- Structure SM_DUTINFO ----------------------------------------------*/
typedef struct {
             int             dut ;
             int             pf ;
}                               SM_RESULT ;

#endif
