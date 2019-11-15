################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_SRCS += \
../Src/delay.s \
../Src/lcd.s \
../Src/main.s 

OBJS += \
./Src/delay.o \
./Src/lcd.o \
./Src/main.o 


# Each subdirectory must supply rules for building sources it contributes
Src/%.o: ../Src/%.s
	arm-none-eabi-gcc -mcpu=cortex-m4 -g3 -c -x assembler-with-cpp --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@" "$<"

