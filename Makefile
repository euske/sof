# Makefile

RSYNC=rsync -av
ZIP=zip
RM=rm -f
CP=cp -f
SSHON=sshon

TARGET=main.swf
JAVA=java -Duser.country=US
FLEX_HOME=../flex_sdk4
AS3COMPILE=$(JAVA) -jar $(FLEX_HOME)/lib/mxmlc.jar +flexlib=$(FLEX_HOME)/frameworks -static-rsls
WEBDIR=www

all: $(TARGET)

clean:
	-$(RM) $(TARGET)
	-$(RM) -r $(WEBDIR)

$(TARGET): src/Main.as
	$(AS3COMPILE) -o $@ src/Main.as

push: $(TARGET)
	$(SSHON)
	$(RSYNC) $(TARGET) tabesugi.net:/cgi/host/live.tabesugi.net/live.swf

pushwww: $(WEBDIR)
	$(SSHON)
	$(CP) $(TARGET) $(WEBDIR)/
	$(CP) src/Main.as $(WEBDIR)/
	$(RM) $(WEBDIR)/src.zip
	$(ZIP) -r $(WEBDIR)/src.zip src tools assets Makefile *.bat *.txt *.html
	$(RSYNC) $(WEBDIR)/ tabesugi.net:/public/file/live.tabesugi.net/
