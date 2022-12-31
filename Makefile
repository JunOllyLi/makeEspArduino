
CHIP ?= esp32
BOARD ?= adafruit_feather_esp32_v2
UPLOAD_PORT_MATCH ?= /dev/ttyACM*
ARDUINO_LIBS = $(HOME)/Arduino/libraries
SKETCH ?= $(HOME)/.arduino15/packages/esp32/hardware/esp32/2.0.5/libraries/ESP32/examples/FreeRTOS/FreeRTOS.ino
BUILD_THREADS = 1
TOOLCHAIN_FILE ?= ${BUILD_DIR}/../toolchain.cmake
LIBS += ${ARDUINO_LIBS}/Adafruit_SH110X
LIBS += $(HOME)/.arduino15/packages/esp32/hardware/esp32/2.0.5/libraries/SPIFFS
LIBS += $(HOME)/.arduino15/packages/esp32/hardware/esp32/2.0.5/libraries/SD
LIBS += ${ARDUINO_LIBS}/Adafruit_MCP23017_Arduino_Library
EXPAND_LIBS = 1

include makeEspArduino.mk

generate_toolchain_file:
	echo -n "set (CMAKE_C_COMPILER " > ${TOOLCHAIN_FILE}
	echo -n $(shell echo $(C_COM) | cut -d' ' -f2) >> ${TOOLCHAIN_FILE}
	echo ")" >> ${TOOLCHAIN_FILE}

	echo -n "set (CMAKE_CXX_COMPILER " >> ${TOOLCHAIN_FILE}
	echo -n $(shell echo $(CPP_COM) | cut -d' ' -f2) >> ${TOOLCHAIN_FILE}
	echo ")" >> ${TOOLCHAIN_FILE}

	echo -n "set (CMAKE_C_FLAGS \"" >> ${TOOLCHAIN_FILE}
	echo -n $(shell echo $(C_COM) | cut -d' ' -f3-) >> ${TOOLCHAIN_FILE}
	echo " -DRTOS_FREERTOS -DPCB_ARDUINO\")" >> ${TOOLCHAIN_FILE}

	echo -n "set (CMAKE_CXX_FLAGS \"" >> ${TOOLCHAIN_FILE}
	echo -n $(shell echo $(CPP_COM) | cut -d' ' -f3-) >> ${TOOLCHAIN_FILE}
	echo " -DRTOS_FREERTOS -DPCB_ARDUINO\")" >> ${TOOLCHAIN_FILE}

	echo "set (PCB ARDUINO)" >> ${TOOLCHAIN_FILE}
	echo "set (ARDUINO_PCB FEATHER_ESP32V2)" >> ${TOOLCHAIN_FILE}

	echo "set (CMAKE_TRY_COMPILE_TARGET_TYPE \"STATIC_LIBRARY\")" >> ${TOOLCHAIN_FILE}
	echo "set (CUSTOM_TOOLCHAIN_OUTPUT_LIB ON)" >> ${TOOLCHAIN_FILE}

LD_COM1 = $(subst FreeRTOS.,opentx.,${LD_COM})
UOBJ = $(subst ${BUILD_DIR}/FreeRTOS.ino.cpp.o ,,$(USER_OBJ))
FW_LD_COM = $(subst arduino.ar",arduino.ar" ${UOBJ} -L${BUILD_DIR}/../opentx/arduino/radio/src/ -ltx_firmware,${LD_COM1})
FW_OBJCOPY = $(subst FreeRTOS.,opentx.,${OBJCOPY})
FW_UPLOAD = $(subst FreeRTOS.bin,opentx.bin,${UPLOAD_COM})

firmware:
	$(FW_LD_COM) $(LD_EXTRA)
	$(FW_OBJCOPY)

flash_firmware:
	$(CHECK_PORT)
	$(FW_UPLOAD)