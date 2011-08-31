#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFSIZE 1024

int main(int argc, char *argv[]) {
	char *key;
	size_t buflen;
	unsigned char buf[BUFSIZE];
	int keylen;
	int i, k = 0;

	if (argc != 2) {
		fprintf(stderr, "usage: xor <key>\n");
		return 2;
	}

	if (!strncmp(argv[1], "0x", 2)) {
		if (strlen(argv[1]) % 2) {
			fprintf(stderr, "error: truncated key\n");
			return 1;
		}
		unsigned int u;
		char *src = argv[1] + 2;
		keylen = strlen(src) / 2;
		key = malloc(keylen);
		char *dst = key;
		char *end = key + keylen;
		while (dst < end && sscanf(src, "%2x", &u) == 1) {
			*dst++ = u;
			src += 2;
		}
		keylen = dst-key;
	} else {
		key = argv[1];
		keylen = strlen(key);
	}

	while ((buflen = read(0, buf, BUFSIZE))) {
		for (i = 0; i < buflen; i++) {
			k %= keylen;
			buf[i] ^= key[k++];
		}
		write(1, buf, buflen);
	}
	return 0;
}
