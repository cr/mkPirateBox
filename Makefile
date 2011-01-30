NAME = piratebox
VERSION = 0.2-1
ARCH = all
IPK = $(NAME)_$(VERSION)_$(ARCH).ipk
IPKDIR = src

.DEFAULT_GOAL = all

$(IPKDIR)/control.tar.gz: $(IPKDIR)/control
	tar czf $@ -C $(IPKDIR)/control .
control: $(IPKDIR)/control.tar.gz

$(IPKDIR)/data.tar.gz: $(IPKDIR)/data
	tar czf $@ -C $(IPKDIR)/data .
data: $(IPKDIR)/data.tar.gz

$(IPK): $(IPKDIR)/control.tar.gz $(IPKDIR)/data.tar.gz $(IPKDIR)/control $(IPKDIR)/data
	tar czf $@ -C $(IPKDIR) control.tar.gz data.tar.gz debian-binary

all: $(IPK)

cleanbuild:
	-rm -f $(IPKDIR)/control.tar.gz
	-rm -f $(IPKDIR)/data.tar.gz

clean: cleanbuild
	-rm -f $(IPK)

.PHONY: all clean

