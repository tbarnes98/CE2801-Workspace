################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include Startup/subdir.mk
-include Src/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
EXECUTABLES += \
lab5keypad.elf \

SIZE_OUTPUT += \
default.size.stdout \

OBJDUMP_LIST += \
lab5keypad.list \


# All Target
all: lab5keypad.elf secondary-outputs

# Tool invocations
lab5keypad.elf: $(OBJS) $(USER_OBJS) C:\Users\barnestr\Documents\CE2801\workspace\lab5keypad\STM32F446RETX_FLASH.ld
	arm-none-eabi-gcc -o "lab5keypad.elf" @"objects.list" $(USER_OBJS) $(LIBS) -mcpu=cortex-m4 -T"C:\Users\barnestr\Documents\CE2801\workspace\lab5keypad\STM32F446RETX_FLASH.ld" --specs=nosys.specs -Wl,-Map="lab5keypad.map" -Wl,--gc-sections -static --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -Wl,--start-group -lc -lm -Wl,--end-group
	@echo 'Finished building target: $@'
	@echo ' '

default.size.stdout: $(EXECUTABLES)
	arm-none-eabi-size  $(EXECUTABLES)
	@echo 'Finished building: $@'
	@echo ' '

lab5keypad.list: $(EXECUTABLES)
	arm-none-eabi-objdump -h -S $(EXECUTABLES) > "lab5keypad.list"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) *
	-@echo ' '

secondary-outputs: $(SIZE_OUTPUT) $(OBJDUMP_LIST)

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets
