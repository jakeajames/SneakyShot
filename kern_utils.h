#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <mach/mach.h>

kern_return_t mach_vm_allocate(vm_map_t target, mach_vm_address_t *address, mach_vm_size_t size, int flags);
kern_return_t mach_vm_deallocate(vm_map_t target, mach_vm_address_t address, mach_vm_size_t size);
kern_return_t mach_vm_read_overwrite(vm_map_t target_task, mach_vm_address_t address, mach_vm_size_t size, mach_vm_address_t data, mach_vm_size_t *outsize);
kern_return_t mach_vm_write(vm_map_t target_task, mach_vm_address_t address, vm_offset_t data, mach_msg_type_number_t dataCnt);

void init_kernel_utils(mach_port_t tfp0);

uint64_t kalloc(vm_size_t size);
void kfree(mach_vm_address_t address, vm_size_t size);

size_t kread(uint64_t where, void *p, size_t size);
uint32_t kread32(uint64_t where);
uint64_t kread64(uint64_t where);

size_t kwrite(uint64_t where, const void *p, size_t size);
void kwrite32(uint64_t where, uint32_t what);
void kwrite64(uint64_t where, uint64_t what);