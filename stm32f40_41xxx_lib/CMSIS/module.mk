MODULES = \
			$(LOCPATH)/DSP_Lib/src \
			$(LOCPATH)/STM32F40_41xxx

-include $(patsubst %, %/module.mk, $(MODULES))
