# Binaries will be generated with this name (.elf, .bin, .hex)
PROJ_NAME=template

# Directories
SRC_DIR=./Src
BIN_DIR=./Bin
LIB_DIR=./Inc

## STM HAL SubProject folder
STM_HAL=STM32CubeF1

# Source files (*.c)
SRCS=$(SRC_DIR)/main.c $(SRC_DIR)/system_stm32f1xx.c

## Libraries source files, placed in $(STM_HAL)/Drivers/STM32F1xx_HAL_Driver/src
SRCS += stm32f1xx_hal.c
SRCS += stm32f1xx_hal_cortex.c
SRCS += stm32f1xx_hal_rcc.c
SRCS += stm32f1xx_hal_gpio.c

# Compiler settings. Only edit CFLAGS to include other header files.
CC=arm-none-eabi-gcc
OBJCOPY=arm-none-eabi-objcopy

# Compiler flags
CFLAGS  = -g -O2 -Wall --specs=nosys.specs -TSTM32F103x8_FLASH.ld
CFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m3 -mthumb-interwork
CFLAGS += -I. -I$(LIB_DIR)

## Select the correct chip, look in the header stm32f1xx.h for a list of values
CFLAGS += -DSTM32F103xB ## Use the xB, but we are actually compiling for the x8

# Include files from STM libraries
## HAL Drivers
CFLAGS += -I$(STM_HAL)/Drivers/STM32F1xx_HAL_Driver/Inc

## CMSIS (Common Microcontroller Software Interface Standard)
CFLAGS += -I$(STM_HAL)/Drivers/CMSIS/Core/Include
CFLAGS += -I$(STM_HAL)/Drivers/CMSIS/Device/ST/STM32F1xx/Include

# Add startup file to build
SRCS += startup_stm32f103x8.s

vpath %.c $(STM_HAL)/Drivers/STM32F1xx_HAL_Driver/Src \

.PHONY: proj

all: proj

proj: $(PROJ_NAME).elf

$(PROJ_NAME).elf: $(SRCS) | $(BIN_DIR)
	$(CC) $(CFLAGS) $^ -o $(BIN_DIR)/$@
	$(OBJCOPY) -O ihex $(BIN_DIR)/$(PROJ_NAME).elf $(BIN_DIR)/$(PROJ_NAME).hex
	$(OBJCOPY) -O binary $(BIN_DIR)/$(PROJ_NAME).elf $(BIN_DIR)/$(PROJ_NAME).bin

$(BIN_DIR):
	mkdir -p $@

clean:
	rm -f *.o $(BIN_DIR)/$(PROJ_NAME).elf $(BIN_DIR)/$(PROJ_NAME).hex $(BIN_DIR)/$(PROJ_NAME).bin