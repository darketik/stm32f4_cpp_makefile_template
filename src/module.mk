PROJECTCSRC 	:=  $(wildcard $(LOCPATH)/*.c)
PROJECTCCSRC	:=  $(wildcard $(LOCPATH)/*.cc)
PROJECTASMSRC 	:=  $(wildcard $(LOCPATH)/*.S)

CSRC 			+= $(PROJECTCSRC)
CCSRC 		+= $(PROJECTCCSRC)
ASMSRC 		+= $(PROJECTASMSRC)
