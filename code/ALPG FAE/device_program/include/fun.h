#ifndef _FUNCTION_H
#define _FUNCTION_H

#include "sml.h"

void	FUN_POR				(void);
void	FUN_SLC_ERS			(void);
void	FUN_SLC_PGM			(void);
void	FUN_SLC_RD_ONEPAGE 	(void);

void	RUN_PATTERN			(char* pattern);
void	LOAD_REGISTER		(int mode, int addr, int data);
void	PATTERN_END_PRINT	(void);
#endif

