# Makefile

RM=rm -f
CP=cp -f
RSYNC=rsync -av
JAVA=java
FLEX_HOME=../flex_sdk4
MXMLC=$(JAVA) -jar $(FLEX_HOME)/lib/mxmlc.jar +flexlib=$(FLEX_HOME)/frameworks
FDB=$(JAVA) -jar $(FLEX_HOME)/lib/fdb.jar

# Project settings
CFLAGS=-static-rsls -debug=true
TARGET=main.swf
LIVE_URL=live.tabesugi.net:public/cgi/root/host/live.tabesugi.net/live.swf

all: $(TARGET)

clean:
	-$(RM) $(TARGET)

update: $(TARGET)
	$(RSYNC) main.html $(TARGET) $(LIVE_URL)

debug: $(TARGET)
	$(FDB) $(TARGET)

$(TARGET): ./src/*.as ./assets/*.png ./assets/*.mp3
	$(MXMLC) $(CFLAGS) -compiler.source-path=./src/ -o $@ ./src/Main.as
