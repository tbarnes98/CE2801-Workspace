################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_SRCS += \
../Src/buzzer.s \
../Src/delay.s \
../Src/keypad.s \
../Src/lcd.s \
../Src/led.s \
../Src/main.s 

OBJS += \
./Src/buzzer.o \
./Src/delay.o \
./Src/keypad.o \
./Src/lcd.o \
./Src/led.o \
./Src/main.o 


# Each subdirectory must supply rules for building sources it contributes
Src/%.o: ../Src/%.s
	arm-none-eabi-gcc -mcpu=cortex-m4 -g3 -c -x assembler-with-cpp --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@" "$<"

