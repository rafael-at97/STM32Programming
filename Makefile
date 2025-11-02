################################################################
# Project Name
# Binaries will be generated with this name (.elf, .bin, .hex) #
################################################################
PROJ_NAME=template

################
# DEBUG on/off #
################
DEBUG = 0

###############
# Directories #
###############
TOOLCHAIN_DIR=/opt/arm/toolchain/arm-gnu-toolchain-14.3.rel1-x86_64-arm-none-eabi

SRC_DIR=./src
INC_DIR=./inc
OUT_DIR=./out
OBJ_DIR=$(OUT_DIR)/obj
BIN_DIR=$(OUT_DIR)/bin

##################
# Binaries Setup #
##################
PREFIX=arm-none-eabi-

CC=$(TOOLCHAIN_DIR)/bin/$(PREFIX)gcc
AS=$(TOOLCHAIN_DIR)/bin/$(PREFIX)gcc -x assembler-with-cpp
OBJCOPY=$(TOOLCHAIN_DIR)/bin/$(PREFIX)objcopy

#####################
# CPU configuration #
#####################
CPU=-mcpu=cortex-m3
CPU_FLAGS=$(CPU) -mthumb

CPU_DEFS=-DUSE_HAL_DRIVER -DSTM32F103xB

################
# Source files #
################

## Project specific Source files
C_SRCS  = main.c
C_SRCS += system_stm32f1xx.c 
C_SRCS += stm32f1xx_it.c 
C_SRCS += stm32f1xx_hal_msp.c

## Libraries source files, placed in $(STM_HAL)/Drivers/STM32F1xx_HAL_Driver/src
C_SRCS += stm32f1xx_hal.c
C_SRCS += stm32f1xx_hal_cortex.c
C_SRCS += stm32f1xx_hal_pwr.c
C_SRCS += stm32f1xx_hal_rcc.c
C_SRCS += stm32f1xx_hal_rcc_ex.c
C_SRCS += stm32f1xx_hal_flash.c
C_SRCS += stm32f1xx_hal_flash_ex.c
C_SRCS += stm32f1xx_hal_gpio.c
C_SRCS += stm32f1xx_hal_gpio_ex.c
C_SRCS += stm32f1xx_hal_tim.c
C_SRCS += stm32f1xx_hal_tim_ex.c
C_SRCS += stm32f1xx_hal_dma.c
C_SRCS += stm32f1xx_hal_exti.c

# Startup file
AS_SRCS = startup_stm32f103x8.s

# Linker script file
LDSCRIPT = STM32F103x8_FLASH.ld

#################
# Includes path #
#################

## Project specific includes
INCLUDES = -I. -I$(INC_DIR)

## STM32Cube includes
STM_HAL=STM32CubeF1
### HAL Drivers
INCLUDES += -I$(STM_HAL)/Drivers/STM32F1xx_HAL_Driver/Inc

## CMSIS (Common Microcontroller Software Interface Standard)
INCLUDES += -I$(STM_HAL)/Drivers/CMSIS/Core/Include
INCLUDES += -I$(STM_HAL)/Drivers/CMSIS/Device/ST/STM32F1xx/Include

##################
# Binaries flags #
##################
ifeq ($(DEBUG), 1)
DBG_FLAGS = -g -gdwarf-2
OPT = -Og
else
OPT = -Os
endif

ASFLAGS = $(CPU_FLAGS) -Wall -std=gnu11 $(OPT) $(DBG_FLAGS) -fdata-sections -ffunction-sections
CFLAGS  = $(CPU_FLAGS) -Wall -std=gnu11 $(OPT) $(DBG_FLAGS) -fdata-sections -ffunction-sections $(CPU_DEFS) $(INCLUDES)

LDLIBS = -lc -lm -lnosys
LDFLAGS = $(CPU_FLAGS) -specs=nano.specs -T$(LDSCRIPT) $(LDLIBS) -Wl,--gc-sections

###############
# Build steps #
###############
OBJS  = $(addprefix $(OBJ_DIR)/,$(notdir $(C_SRCS:.c=.o)))
OBJS += $(addprefix $(OBJ_DIR)/,$(notdir $(AS_SRCS:.s=.o)))

vpath %.c $(SRC_DIR)
vpath %.c $(STM_HAL)/Drivers/STM32F1xx_HAL_Driver/Src

.PHONY: all clean

all: $(PROJ_NAME).elf $(PROJ_NAME).hex $(PROJ_NAME).bin

$(PROJ_NAME).elf: $(OBJS) | $(BIN_DIR)
	$(CC) $(OBJS) $(LDFLAGS) -o $(BIN_DIR)/$@

$(PROJ_NAME).hex: $(BIN_DIR)/$(PROJ_NAME).elf
	$(OBJCOPY) -O ihex $< $(BIN_DIR)/$@

$(PROJ_NAME).bin: $(BIN_DIR)/$(PROJ_NAME).elf
	$(OBJCOPY) -O binary $< $(BIN_DIR)/$@

$(OBJ_DIR)/%.o: %.c | $(OBJ_DIR) 
	$(CC) -c $(CFLAGS) $< -o $@

$(OBJ_DIR)/%.o: %.s | $(OBJ_DIR)
	$(AS) -c $(ASFLAGS) $< -o $@

$(BIN_DIR):
	mkdir -p $@

$(OBJ_DIR):
	mkdir -p $@

############
# Clean-Up #
############
clean:
	rm -fR $(BIN_DIR) $(OBJ_DIR)