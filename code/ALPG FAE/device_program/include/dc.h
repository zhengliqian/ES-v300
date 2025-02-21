#ifndef _DC_H
#define _DC_H

#include "sml.h"

void	DC_OPEN_SHORT(void);
void	DC_LEAKAGE(void);
void	DC_ICC_GROSS(void);
void	DC_ICC_STANDBY(void);

void	PowerUp(float vcc, float vccq);
#endif

