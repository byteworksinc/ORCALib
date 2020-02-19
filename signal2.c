#ifdef __ORCAC__
segment "libc_sys__";
#endif

#include <gno/kerntool.h>
#include <errno.h>

int raise(int sig) {
	return Kkill(Kgetpid(), sig, &errno);
}
