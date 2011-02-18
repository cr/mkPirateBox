NAME = piratebox
VERSION = 0.2-4
VERSIONPS = 0.1-1
ARCH = all
IPK = $(NAME)_$(VERSION)_$(ARCH).ipk
IPKDIR = src
IPKPS = $(NAME)-preseed_$(VERSIONPS)_$(ARCH).ipk
IPKPSDIR = src-preseed

.DEFAULT_GOAL = all

$(IPKDIR)/control.tar.gz: $(IPKDIR)/control
	tar czf $@ -C $(IPKDIR)/control .
$(IPKPSDIR)/control.tar.gz: $(IPKPSDIR)/control
	tar czf $@ -C $(IPKPSDIR)/control .
control: $(IPKDIR)/control.tar.gz $(IPKPSDIR)/control.tar.gz

$(IPKDIR)/data.tar.gz: $(IPKDIR)/data
	tar czf $@ -C $(IPKDIR)/data .
$(IPKPSDIR)/data.tar.gz: $(IPKPSDIR)/data
	tar czf $@ -C $(IPKPSDIR)/data .
data: $(IPKDIR)/data.tar.gz $(IPKPSDIR)/data.tar.gz

$(IPK): $(IPKDIR)/control.tar.gz $(IPKDIR)/data.tar.gz $(IPKDIR)/control $(IPKDIR)/data
	tar czf $@ -C $(IPKDIR) control.tar.gz data.tar.gz debian-binary
$(IPKPS): $(IPKPSDIR)/control.tar.gz $(IPKPSDIR)/data.tar.gz $(IPKPSDIR)/control $(IPKPSDIR)/data
	tar czf $@ -C $(IPKPSDIR) control.tar.gz data.tar.gz debian-binary
all: $(IPK) $(IPKPS)

cleanbuild:
	-rm -f $(IPKDIR)/control.tar.gz
	-rm -f $(IPKDIR)/data.tar.gz
	-rm -f $(IPKPSDIR)/control.tar.gz
	-rm -f $(IPKPSDIR)/data.tar.gz

clean: cleanbuild
	-rm -f $(IPK)
	-rm -f $(IPKPS)

.PHONY: all clean

