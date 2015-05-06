#include <string.h>
#include "gpio_api.h"

void gpio_write_stub(gpio_t *obj, int value) {
	gpio_write(obj, value);
}

int  gpio_read_stub(gpio_t *obj) {
	return gpio_read(obj);
}

void *__aeabi_memcpy(void *dest, const void *src, size_t n) {
	return memcpy(dest, src, n);
}
