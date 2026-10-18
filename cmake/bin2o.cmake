# TODO: should be a configure-time custom command
# takes an input like splash.image.bin, converts it, then saves as spash_image_bin.h

# #---------------------------------------------------------------------------------
# # canned command sequence for binary data
# #---------------------------------------------------------------------------------
# define bin2o
#         $(eval _tmpasm := $(shell mktemp))
#         $(SILENTCMD)bin2s -a 4 -H `(echo $(<F) | tr . _)`.h $< > $(_tmpasm)
#         $(SILENTCMD)$(CC) -x assembler-with-cpp $(CPPFLAGS) $(ASFLAGS) -c $(_tmpasm) -o $(<F).o
#         @rm $(_tmpasm)
# endef