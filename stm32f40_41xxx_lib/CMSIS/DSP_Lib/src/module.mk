CMSISDSPLIBFCTS :=	\
	$(LOCPATH)/BasicMathFunctions \
	$(LOCPATH)/CommonTables \
	$(LOCPATH)/ComplexMathFunctions \
	$(LOCPATH)/ControllerFunctions \
	$(LOCPATH)/FastMathFunctions \
	$(LOCPATH)/FilteringFunctions \
	$(LOCPATH)/MatrixFunctions \
	$(LOCPATH)/StatisticsFunctions \
	$(LOCPATH)/SupportFunctions \
	$(LOCPATH)/TransformFunctions

STM32F4CMSISDSPLIBCSRC = $(wildcard $(patsubst %, %/*.c, $(CMSISDSPLIBFCTS)))

#+ CSRC 			+= $(STM32F4CMSISDSPLIBCSRC)
LIBSRC_CLEAN += $(STM32F4CMSISDSPLIBCSRC:%.c=%.o)

$(LIBCMSISDSP): $(STM32F4CMSISDSPLIBCSRC:%.c=%.o)
	$(AR) -cru $@ $^
	$(RANLIB) $@
