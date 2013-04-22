# Makefile

RSYNC=rsync -av
ZIP=zip
RM=rm -f
CP=cp -f
MKDIR=mkdir -p
SSHON=sshon

TARGET=main.swf
JAVA=java
FLEX_HOME=../flex_sdk4
AS3COMPILE=$(JAVA) -jar $(FLEX_HOME)/lib/mxmlc.jar +flexlib=$(FLEX_HOME)/frameworks -static-rsls
WEBDIR=www

all: $(TARGET)

clean:
	-$(RM) $(TARGET)
	-$(RM) -r $(WEBDIR)

$(TARGET): src/*.as
	$(AS3COMPILE) -compiler.source-path=./src -o $@ src/Main.as

live: $(TARGET)
	$(SSHON)
	$(RSYNC) $(TARGET) live.tabesugi.net:public/cgi/root/host/live.tabesugi.net/live.swf

$(WEBDIR):
	$(SSHON)
	-$(MKDIR) $(WEBDIR)
	$(CP) $(TARGET) $(WEBDIR)/
	$(CP) src/Main.as $(WEBDIR)/
	$(RM) $(WEBDIR)/src.zip
	$(ZIP) -r $(WEBDIR)/src.zip src tools assets Makefile *.bat *.txt *.html
	$(RSYNC) $(WEBDIR)/ tabesugi.net:/public/file/live.tabesugi.net/
