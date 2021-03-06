STM32F4STDPERIPHCSRC 	:=  $(wildcard $(LOCPATH)/src/*.c)
STM32F4STDPERIPHCCSRC 	:=  $(wildcard $(LOCPATH)/src/*.cc)
STM32F4STDPERIPHASMSRC	:=  $(wildcard $(LOCPATH)/src/*.S)

#+ CSRC 			+= $(STM32F4STDPERIPHCSRC)
#+ CCSRC 		+=  $(STM32F4STDPERIPHCCSRC)
#+ ASMSRC 		+=  $(STM32F4STDPERIPHASMSRC)
LIBSRC_CLEAN +=  $(STM32F4STDPERIPHCSRC:%.c=%.o) $(STM32F4STDPERIPHCCSRC:%.cc=%.o) $(STM32F4STDPERIPHASMSRC:%.S=%.o)

$(LIBSTDPERIPH): $(STM32F4STDPERIPHCSRC:%.c=%.o) $(STM32F4STDPERIPHCCSRC:%.cc=%.o) $(STM32F4STDPERIPHASMSRC:%.S=%.o)
	$(AR) -cru $@ $^
	$(RANLIB) $@
