//######## sml_tpl.h #############################################################
//2011/06/02	新規

#ifndef __SML_TPL_H__
#define __SML_TPL_H__

//**********************************
//****  トランスレータ共通定義  ****
//**********************************
// トランスレータでのCソース生成時に使用している為、
// 変更する時はトランスレータも確認必要

// パート関数情報
typedef struct __tpl_tag_PART_FUNC
{
	int		nNumber;			// パート番号
	void	(*pFunction)(void);	// パート関数
}__tpl_PART_FUNC;

// ブレークポイント情報
typedef struct __tpl_tag_BREAK_POINT
{
	int	nNumber;			// ブレークポイント番号
//	BOOL	bBreakON;			// ブレークポイント ONフラグ
}__tpl_BREAK_POINT;

//********************
//****  定数定義  ****
//********************
#define __tpl_PART_FUNC_TBL			__tpl_PartFuncTable				// パート関数情報テーブル
#define __tpl_BREAK_POINT_TBL		__tpl_BreakPointTable			// ブレークポイント情報テーブル

//**********************
//****  構造体定義  ****
//**********************
/***
typedef struct __tpl_tag_SETUP_INFO
{
	int				nRunMode;
	unsigned int	nCheckSum;
	int				bStep;
}__tpl_SETUP_INFO;
****/

typedef struct __tpl_tag_PART_INFO
{
	int		nMaxCount;
	char*	pSkipFlag;
}__tpl_PART_INFO;


#endif
