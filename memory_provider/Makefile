TARGET=memory_provider

# [1302] : RAM Bank warning
# [220]  : BADROM warning
# [212]  : __CONFIG deprecated warning
$(TARGET).hex: $(TARGET).asm
	gpasm $^ | grep -F -v "[1302]" | grep -F -v "[220]" | grep -F -v "[212]" | cat
	test -e $@

.PHONY: clean
clean:
	rm -f $(TARGET).cod $(TARGET).lst $(TARGET).hex
