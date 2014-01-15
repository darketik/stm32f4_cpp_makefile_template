MODULES = \
			$(LOCPATH)/src \
			$(LOCPATH)/stm32f40_41xxx_lib \
			$(LOCPATH)/stm32f4_discovery_lib \
			$(LOCPATH)/stm32f4_usb_lib

-include $(patsubst %, %/module.mk, $(MODULES))
