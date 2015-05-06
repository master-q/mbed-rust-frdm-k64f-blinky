#include "gpio_api.h"

void gpio_write_stub(gpio_t *obj, int value) {
	gpio_write(obj, value);
}

int  gpio_read_stub(gpio_t *obj) {
	return gpio_read(obj);
}
