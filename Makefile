# Copyright 2014 Florent Rotenberg.
#
# Author: Florent Rotenberg (florent.rotenberg@gmail.com)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 
# See http://creativecommons.org/licenses/MIT/ for more information.

#TODO compile *.o|d into build folder
#TODO change Makefile structure to recursive makefile calls, use of VPATH, ...

# -----------------------------------------------------------------------------
#  Project configuration
# -----------------------------------------------------------------------------
# System specifications
F_CRYSTAL      			= 8000000L
#+ F_CPU          			= 72000000L
#+ SYSCLOCK       			= SYSCLK_FREQ_72MHz
FLASH_BASE_ADDRESS	= 0x08000000

#+ APPLICATION    			= FALSE

# Packages to build
TARGET         			= stm32f4_cpp_makefile_template

# -----------------------------------------------------------------------------
# toolchain definitions
# -----------------------------------------------------------------------------
TOOLCHAIN_PATH 	= $(HOME)/work/bin/gcc-arm-none-eabi-4_6-2012q4
TOOLCHAIN_BIN 	= $(TOOLCHAIN_PATH)/bin
TOOLCHAIN_TYPE	= $(TOOLCHAIN_BIN)/arm-none-eabi

BUILD_ROOT     	= build
BUILD_DIR      	= $(BUILD_ROOT)/$(TARGET)

LIBDIR					= lib

CC 							= $(TOOLCHAIN_TYPE)-gcc
CXX           	= $(TOOLCHAIN_TYPE)-g++
AS             	= $(TOOLCHAIN_TYPE)-as
OBJCOPY        	= $(TOOLCHAIN_TYPE)-objcopy
DB             	= $(TOOLCHAIN_TYPE)-gdb
OBJDUMP       	= $(TOOLCHAIN_TYPE)-objdump
AR             	= $(TOOLCHAIN_TYPE)-ar
RANLIB					= $(TOOLCHAIN_TYPE)-ranlib
SIZE           	= $(TOOLCHAIN_TYPE)-size
STRIP          	= $(TOOLCHAIN_TYPE)-strip
NM             	= $(TOOLCHAIN_TYPE)-nm
HEXDUMP					= hexdump

REMOVE         	= rm -rf
CAT            	= cat

FORMAT_SIZE    	= | xargs -I {} echo -ne "Flash:\n {} bytes" | figlet | cowsay -e o~ -n -f moose
FORMAT_RAMSIZE 	= | xargs -I {} echo -ne "Ram:\n {} bytes" | figlet | cowsay -e ~o -n -f koala

OPENOCD_SCRIPTS_PATH = stm32f4_scripts/openocd

# ------------------------------------------------------------------------------
# Flags for gcc/binutils
# ------------------------------------------------------------------------------
MODEL_DEFINE 	= STM32F40_41xxx

ARCHFLAGS		 	= -mcpu=cortex-m4 \
								-mthumb \
								-mfloat-abi=hard \
								-mfpu=fpv4-sp-d16 \
								-mlittle-endian

DEFS					= -D$(MODEL_DEFINE) \
								-DUSE_STDPERIPH_DRIVER \
								-DUSE_STM32F4_DISCOVERY \
								-D__VFP_FP__ \
								-D__FPU_PRESENT=1 \
								-DARM_MATH_CM4 \
								-DHSE_VALUE=$(F_CRYSTAL) \
								-DUSE_OTG_MODE \
								-DUSE_HOST_MODE \
								-DUSE_USB_OTG_FS

WARNINGS			= -Wall \
								-Wextra \
								-Wfloat-equal \
								-Wshadow \
								-Wpointer-arith \
								-Wbad-function-cast \
								-Wcast-align \
								-Wsign-compare \
								-Waggregate-return \
								-Wstrict-prototypes \
								-Wmissing-prototypes \
								-Wmissing-declarations \
								-Wunused

INCFLAGS 			=  
							
CFLAGS				= $(ARCHFLAGS) \
								$(DEFS) \
								$(WARNINGS) \
								-O0 \
								-g3 \
								-fdata-sections \
								-ffunction-sections \
								-finline-functions \
								-finline-functions-called-once \
								-fmessage-length=0 \
								-fshort-enums 

CCFLAGS				= $(CFLAGS) \
								-fno-exceptions \
								-fno-rtti

ASFLAGS				= $(ARCHFLAGS)

LINKER_SCRIPT =	stm32f4_scripts/linker/stm32f4xx_default.ld
LDFLAGS				= $(ARCHFLAGS) \
								-L$(LIBDIR) \
								-O0 -g3 \
								-Wl,-gc-section \
								-Wl,--relax \
								-Wl,-Map=$(BUILD_DIR)/$(TARGET).map \
								-T $(LINKER_SCRIPT)

# ------------------------------------------------------------------------------
# libraries definition
# ------------------------------------------------------------------------------
# stm32f4 discovery board lib
LIBSTM32F4DISCOVERY	:= $(LIBDIR)/libstm32f4discovery.a
LIBS								+= $(LIBSTM32F4DISCOVERY)
LDLIBS							+= -lstm32f4discovery

# usb device class hid lib
LIBUSBCLASSHID 	:= $(LIBDIR)/libusbclasshid.a
LIBS						+= $(LIBUSBCLASSHID)
LDLIBS					+= -lusbclasshid

# usb device core lib
LIBUSBCORE 			:= $(LIBDIR)/libusbcore.a
LIBS						+= $(LIBUSBCORE)
LDLIBS					+= -lusbcore

# usb otg core lib
LIBUSBOTGCORE 	:= $(LIBDIR)/libusbotgcore.a
LIBS						+= $(LIBUSBOTGCORE)
LDLIBS					+= -lusbotgcore

# standard peripheral lib
LIBSTDPERIPH 		:= $(LIBDIR)/libstdperiph.a
LIBS						+= $(LIBSTDPERIPH)
LDLIBS					+= -lstdperiph

# cmsis DSP_Lib
LIBCMSISDSP 		:= $(LIBDIR)/libcmsisdsp.a
LIBS						+= $(LIBCMSISDSP)
LDLIBS					+= -lcmsisdsp

# cmsis stm32f4
LIBCMSISSTM32F4	:= $(LIBDIR)/libcmsisstm32f4.a
LIBS						+= $(LIBCMSISSTM32F4)
LDLIBS					+= -lcmsisstm32f4

# ------------------------------------------------------------------------------
# Files and directories for the user code
# ------------------------------------------------------------------------------
TARGET_BIN     	= $(BUILD_DIR)/$(TARGET).bin
TARGET_ELF     	= $(BUILD_DIR)/$(TARGET).elf
TARGET_IHEX     = $(BUILD_DIR)/$(TARGET).ihex
TARGET_HEX     	= $(BUILD_DIR)/$(TARGET).hex
TARGET_DIS     	= $(BUILD_DIR)/$(TARGET).dis
TARGET_SIZE    	= $(BUILD_DIR)/$(TARGET).size
TARGET_SYM    	= $(BUILD_DIR)/$(TARGET).sym
TARGET_LSS    	= $(BUILD_DIR)/$(TARGET).lss
TARGETS        	= $(BUILD_DIR)/$(TARGET).*

INCFLAGS 				+= -Iinc

MAKE_MODULES 		= module.mk
LOCPATH 				= $(patsubst %/, %, $(dir $(lastword $(MAKEFILE_LIST))))

include $(MAKE_MODULES)

# ------------------------------------------------------------------------------
# What to build
# ------------------------------------------------------------------------------
OBJS			= 	$(patsubst %.cc, %.o, $(CCSRC)) \
							$(patsubst %.c, %.o, $(CSRC)) \
							$(patsubst %.S, %.o, $(ASMSRC)) 

#+ OBJS		=	$(patsubst %,$(BUILD_DIR)/%,$(OBJ_FILES))

DEPS			= 	$(patsubst %.o, %.d, $(OBJS))

all: | $(BUILD_DIR) $(LIBS) $(TARGET_IHEX) $(TARGET_HEX) $(TARGET_BIN) $(TARGET_DIS) $(TARGET_SYM) $(TARGET_LSS) size ramsize

# ------------------------------------------------------------------------------
# Files and directories for the system firmware
# ------------------------------------------------------------------------------
FW_STM32F4_DIR				= stm32f40_41xxx_lib
FW_CMSIS_CM4_DIR			= stm32f40_41xxx_lib/CMSIS/CM4
FW_CMSIS_STM32F4_DIR	= stm32f40_41xxx_lib/CMSIS/STM32F40_41xxx
FW_CMSIS_RTOS_DIR			= stm32f40_41xxx_lib/CMSIS/RTOS
FW_STDDRIVER_DIR			= stm32f40_41xxx_lib/STM32F4xx_StdPeriph_Driver
FW_USBOTG_DIR					= stm32f4_usb_lib/STM32_USB_OTG_Driver
FW_USBDEVCORE_DIR			= stm32f4_usb_lib/STM32_USB_Device_Library/Core
FW_USBDEVCLASSHID_DIR = stm32f4_usb_lib/STM32_USB_Device_Library/Class/hid
FW_DISCOVERY_DIR			=	stm32f4_discovery_lib

FW_STM32F4_INCDIR 			= $(FW_STM32F4_DIR)
FW_CMSIS_CM4_INCDIR 		= $(FW_CMSIS_CM4_DIR)/inc
FW_CMSIS_STM32F4_INCDIR = $(FW_CMSIS_STM32F4_DIR)/inc
FW_CMSIS_RTOS_INCDIR 		= $(FW_CMSIS_RTOS_DIR)/inc
FW_STDDRIVER_INCDIR			= $(FW_STDDRIVER_DIR)/inc
FW_USBOTG_INCDIR 				= $(FW_USBOTG_DIR)/inc
FW_USBDEVCORE_INCDIR 		= $(FW_USBDEVCORE_DIR)/inc
FW_USBDEVCLASSHID_INCDIR = $(FW_USBDEVCLASSHID_DIR)/inc
FW_DISCOVERY_INCDIR 		= $(FW_DISCOVERY_DIR)/inc

INCFLAGS += -I$(FW_STM32F4_INCDIR) \
						-I$(FW_CMSIS_CM4_INCDIR) \
						-I$(FW_CMSIS_STM32F4_INCDIR) \
						-I$(FW_CMSIS_RTOS_INCDIR) \
						-I$(FW_STDDRIVER_INCDIR) \
						-I$(FW_USBOTG_INCDIR) \
						-I$(FW_USBDEVCORE_INCDIR) \
						-I$(FW_USBDEVCLASSHID_INCDIR) \
						-I$(FW_DISCOVERY_INCDIR) 

# ------------------------------------------------------------------------------
# Source compiling and dependency analysis
# ------------------------------------------------------------------------------
#+ $(CSRC:%.c=%.d): %.d: %.c
#+    @$(CC) $(INCFLAGS) $(CFLAGS) -std=c99 -MT $(@:.d=.o) -MM $< -MF $@

#+ $(CCSRC:%.cc=%.d): %.d: %.cc
#+    @$(CC) $(INCFLAGS) $(CCFLAGS) -MT $(patsubst %.d, %.o, $@) -M $< -o $@

#+ $(ASMSRC:%.S=%.d): %.d: %.S
#+    @$(CC) $(INCFLAGS) $(ASFLAGS) -M $< -o $@
	
%.o: %.S
	$(CC) -c -x assembler-with-cpp $(ASFLAGS) $(INCFLAGS) $< -o $@

%.o: %.c
	$(CC) -c $(CFLAGS) $(INCFLAGS) -std=c99 $< -o $@

%.o: %.cc
	$(CXX) -c $(CCFLAGS) $(INCFLAGS) $< -o $@

%.d: %.S
	$(CC) -c -x assembler-with-cpp -MM $(ASFLAGS) $(INCFLAGS) $< -MF $@ -MT $(@:.d=.o)

%.d: %.c
	$(CC) -MM $(CFLAGS) $(INCFLAGS) $< -MF $@ -MT $(@:.d=.o)

%.d: %.cc
	$(CXX) -MM $(CCFLAGS) $(INCFLAGS) $< -MF $@ -MT $(@:.d=.o)

# ------------------------------------------------------------------------------
# elf generator / linker
# ------------------------------------------------------------------------------
$(BUILD_DIR)/%.elf: $(OBJS)
	$(CC) $(LDFLAGS) $(INCFLAGS) $^ $(LDLIBS) -o $@

$(BUILD_DIR)/%.map: $(BUILD_DIR)/%.elf

# ------------------------------------------------------------------------------
# Object file conversion
# ------------------------------------------------------------------------------
$(BUILD_DIR)/%.ihex: $(BUILD_DIR)/%.elf
	$(OBJCOPY) -O ihex $< $@

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf 
	$(OBJCOPY) -O binary $< $@

$(BUILD_DIR)/%.lss: $(BUILD_DIR)/%.elf
	$(OBJDUMP) -d -h -S $< > $@

$(BUILD_DIR)/%.sym: $(BUILD_DIR)/%.elf
	$(NM) -n $< > $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.bin
	$(HEXDUMP) -e '1/2 "%04x" "\n"' $< -v > $@

#+ $(BUILD_DIR)/$(TARGET).top_symbols: $(TARGET_ELF)
#+    $(NM) $< --size-sort -C -f bsd -r > $@

$(BUILD_DIR)/%.dis: $(BUILD_DIR)/%.elf
	$(OBJDUMP) -h -d $^ > $@

$(TARGET_SIZE):  $(TARGET_ELF)
	$(SIZE) $(TARGET_ELF) > $(TARGET_SIZE)

# ------------------------------------------------------------------------------
# Main rules
# ------------------------------------------------------------------------------
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

clean:
	$(REMOVE) $(OBJS) $(TARGETS) $(DEPS) $(BUILD_DIR) $(LIBS) $(LIBSRC_CLEAN)

size: $(TARGET_SIZE)
	@cat $(TARGET_SIZE) | awk '{ print $$1+$$2 }' | tail -n1 $(FORMAT_SIZE)

ramsize: $(TARGET_SIZE)
	@cat $(TARGET_SIZE) | awk '{ print $$2+$$3 }' | tail -n1 $(FORMAT_RAMSIZE)

.PHONY: all clean size ramsize

-include $(DEPS)

# ------------------------------------------------------------------------------
# Firmware flashing
# ------------------------------------------------------------------------------
ERASE_JTAG_CMD = openocd \
			-f $(OPENOCD_SCRIPTS_PATH)/stm32f4discovery.cfg \
			-f $(OPENOCD_SCRIPTS_PATH)/stm32f4xx_prelude.cfg \
			-f $(OPENOCD_SCRIPTS_PATH)/stm32f4xx_erase.cfg \
			-f $(OPENOCD_SCRIPTS_PATH)/stm32f4xx_postlude.cfg

UPLOAD_JTAG_CMD = openocd \
			-f $(OPENOCD_SCRIPTS_PATH)/stm32f4discovery.cfg \
			-f $(OPENOCD_SCRIPTS_PATH)/stm32f4xx_prelude.cfg \
			-f $(OPENOCD_SCRIPTS_PATH)/stm32f4xx_erase.cfg \
			-c "flash write_bank 0 $(TARGET_BIN) 0x0" \
			-c "verify_image $(TARGET_BIN)" \
			-f $(OPENOCD_SCRIPTS_PATH)/stm32f4xx_postlude.cfg

UPLOAD_JTAG_NO_ERASE_CMD = openocd \
			-f $(OPENOCD_SCRIPTS_PATH)/stm32f4discovery.cfg \
			-f $(OPENOCD_SCRIPTS_PATH)/stm32f4xx_prelude.cfg \
			-c "flash write_image erase $(TARGET_BIN) $(FLASH_BASE_ADDRESS)" \
			-c "verify_image $(TARGET_BIN)" \
			-f $(OPENOCD_SCRIPTS_PATH)/stm32f4xx_postlude.cfg

DEBUG_SERVER	=	openocd \
		-f $(OPENOCD_SCRIPTS_PATH)/stm32f4discovery.cfg

DEBUG_CLIENT	=	$(DB) \
				--eval-command="set tdesc filename stm32f4_scripts/gdb/workaround.xml" \
				--eval-command="set remote hardware-breakpoint-limit 6" \
				--eval-command="set remote hardware-watchpoint-limit 4" \
				--eval-command="target remote localhost:3333" \
				--eval-command="monitor reset init" \
				--eval-command="hbreak src/main.c:main" \
				--eval-command="info break" \
				--eval-command="monitor reg" \
				--eval-command="bt" \
				$(TARGET_ELF)

erase_jtag:
	$(ERASE_JTAG_CMD)

upload_jtag: $(TARGET_BIN)
	$(UPLOAD_JTAG_CMD) 

upload_jtag_no_erase: $(TARGET_BIN)
	$(UPLOAD_JTAG_NO_ERASE_CMD)

debug_server: $(TARGET_BIN)
	$(DEBUG_SERVER)

debug_client:
	$(DEBUG_CLIENT)

.PHONY: debug_server debug_client erase_jtag upload_jtag upload_jtag_no_erase
