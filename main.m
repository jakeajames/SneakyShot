#include <stdio.h>
#include <mach/mach.h>
#include <err.h>
#include <string.h>

#include "kern_utils.h"
#include "bitmap.h"

#define MEMORYSTATUS_CMD_SET_JETSAM_TASK_LIMIT 6
int memorystatus_control(uint32_t command, int32_t pid, uint32_t flags, void *buffer, size_t buffersize);

int main(int argc, char *argv[], char *envp[]) {
	if (getuid()) {
		printf("[-] please run as root\n");
		return 1;
	}

	if (argc != 2) {
		printf("[-] usage: %s /image/save/path.bmp\n", argv[0]);
		return 2;
	}

	memorystatus_control(MEMORYSTATUS_CMD_SET_JETSAM_TASK_LIMIT, getpid(), 0, NULL, 0);

	char *save_path = argv[1];
	if (!access(save_path, F_OK)) {
		printf("[-] file exists\n");
		return 3;
	}

	mach_port_t tfp0 = MACH_PORT_NULL;
	kern_return_t ret = task_for_pid(mach_task_self(), 0, &tfp0);
	if (ret) {
		ret = host_get_special_port(mach_host_self(), HOST_LOCAL_NODE, 4, &tfp0);
		if (ret) {
			printf("[-] both tfp0 and hsp4 failed. what jailbreak is this?\n");
			return 4;
		}
	}
	printf("[i] tfp0: 0x%x\n", tfp0);

	init_kernel_utils(tfp0);
	struct task_dyld_info info;
	mach_msg_type_number_t count = 5;
	task_info(tfp0, 17, (task_info_t)&info, &count);
	uint32_t slide = info.all_image_info_size;
	printf("[i] kaslr: 0x%x\n", slide);

	uint64_t vinfo = 0xFFFFFFF00764A0F0 + slide;
	uint32_t height = kread32(vinfo);
	uint32_t width = kread32(vinfo + 4);
	uint32_t depth = kread32(vinfo + 8);
	uint64_t baseaddr = kread64(vinfo + 16);
	printf("[i] framebuffer: 0x%llx\n", baseaddr);

	size_t buffer_size = width * height * depth/8;

	char *pixelbuffer = malloc(buffer_size);
	kread(baseaddr, pixelbuffer, buffer_size);
	
	FILE *f = fopen(save_path, "wb");
	if (!f) {
		printf("[-] fopen failed: %d (%s)\n", errno, strerror(errno));
		return 5;
	}

	bitmap *pbitmap = calloc(1, sizeof(bitmap));
	pbitmap->fileheader.signature[0] = 'B';
	pbitmap->fileheader.signature[1] = 'M';
	pbitmap->fileheader.filesize = sizeof(bitmap) + buffer_size;
	pbitmap->fileheader.fileoffset_to_pixelarray = sizeof(bitmap);
	pbitmap->bitmapinfoheader.dibheadersize = sizeof(bitmapinfoheader);
	pbitmap->bitmapinfoheader.width = width;
	pbitmap->bitmapinfoheader.height = -height;
	pbitmap->bitmapinfoheader.planes = 1;
	pbitmap->bitmapinfoheader.bitsperpixel = depth;
	pbitmap->bitmapinfoheader.imagesize = buffer_size;

	fwrite(pbitmap, 1, sizeof(bitmap), f);
	fwrite(pixelbuffer, 1, buffer_size, f);
	fclose(f);
	free(pbitmap);
	free(pixelbuffer);
	
	return 0;
}
