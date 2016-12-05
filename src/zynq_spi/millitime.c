#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include <time.h>

int main (void) {
    struct timeval now;
    struct tm *parsed;

    if (gettimeofday(&now, NULL) == -1) {
        fprintf (
            stderr,
            "gettimeofday() failed: %s\n",
            strerror(errno)
        );
        return 1;
    }

    parsed = localtime((const time_t*)&now.tv_sec);
    if (!parsed) {
        fprintf (
            stderr,
            "localtime() failed: %s\n",
            strerror(errno)
        );
        return 1;
    }

    printf (
        "%d_%d_%d-%d:%02d:%02d:%03d\n",
        parsed->tm_mday,
        parsed->tm_mon + 1,
        parsed->tm_year + 1900,
        parsed->tm_hour,
        parsed->tm_min,
        parsed->tm_sec,
        now.tv_usec / 1000
    );

    return 0;
}
