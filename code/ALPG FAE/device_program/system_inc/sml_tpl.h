//######## sml_tpl.h #############################################################
//2011/06/02	�V�K

#ifndef __SML_TPL_H__
#define __SML_TPL_H__

//**********************************
//****  �g�����X���[�^���ʒ�`  ****
//**********************************
// �g�����X���[�^�ł�C�\�[�X�������Ɏg�p���Ă���ׁA
// �ύX���鎞�̓g�����X���[�^���m�F�K�v

// �p�[�g�֐����
typedef struct __tpl_tag_PART_FUNC
{
	int		nNumber;			// �p�[�g�ԍ�
	void	(*pFunction)(void);	// �p�[�g�֐�
}__tpl_PART_FUNC;

// �u���[�N�|�C���g���
typedef struct __tpl_tag_BREAK_POINT
{
	int	nNumber;			// �u���[�N�|�C���g�ԍ�
//	BOOL	bBreakON;			// �u���[�N�|�C���g ON�t���O
}__tpl_BREAK_POINT;

//********************
//****  �萔��`  ****
//********************
#define __tpl_PART_FUNC_TBL			__tpl_PartFuncTable				// �p�[�g�֐����e�[�u��
#define __tpl_BREAK_POINT_TBL		__tpl_BreakPointTable			// �u���[�N�|�C���g���e�[�u��

//**********************
//****  �\���̒�`  ****
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
