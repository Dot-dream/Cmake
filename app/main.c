#include "main.h"
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <ctype.h>
#include <limits.h>
#include <stdint.h>
#include <stdbool.h>

static volatile uint32_t test_passed = 0;
static volatile uint32_t test_failed = 0;

static int test_string(void)
{
    char buf[64];
    const char *src = "Hello STM32F103!";

    size_t len = strlen(src);                  // strlen
    if (len != 15) return -1;

    memcpy(buf, src, len + 1);                 // memcpy
    if (buf[0] != 'H' || buf[14] != '!') return -2;

    memset(buf + len, '.', 4);                 // memset
    if (buf[15] != '.' || buf[16] != '.') return -3;

    if (strcmp(src, "Hello STM32F103!") != 0) return -4;  // strcmp

    char *ch = strchr(src, 'S');               // strchr
    if (ch == NULL) return -5;

    ch = strstr(src, "STM32");                 // strstr
    if (ch == NULL) return -6;

    return 0;
}

static int test_stdlib(void)
{
    int val = atoi("1234");                     // atoi
    if (val != 1234) return -1;

    if (abs(-42) != 42) return -2;             // abs

    div_t d = div(100, 7);                     // div
    if (d.quot != 14 || d.rem != 2) return -3;

    if (labs(-123456L) != 123456L) return -4;  // labs

    long lval = atol("654321");                // atol
    if (lval != 654321) return -5;

    int r = rand() % 100;                      // rand
    if (r < 0 || r >= 100) return -6;

    return 0;
}

static int test_math(void)
{
    /* sqrt */
    double s = sqrt(144.0);
    if (fabs(s - 12.0) > 0.0001) return -1;

    /* sin / cos ? Pythagorean identity */
    double rad = 3.1415926535 / 4.0;
    double sv = sin(rad);
    double cv = cos(rad);
    double ident = sv * sv + cv * cv;
    if (fabs(ident - 1.0) > 0.001) return -2;

    if (fabs(-3.14) > 3.15) return -3;          // fabs

    double fm = fmod(10.5, 3.0);                // fmod
    if (fabs(fm - 1.5) > 0.0001) return -4;

    double val = 3.7;
    if (ceil(val) != 4.0) return -5;            // ceil
    if (floor(val) != 3.0) return -6;           // floor

    /* pow */
    double p = pow(2.0, 10.0);
    if (fabs(p - 1024.0) > 0.001) return -7;

    /* log */
    double lg = log(1024.0);
    if (fabs(lg - 6.9315) > 0.01) return -8;

    return 0;
}

static int test_ctypes(void)
{
    if (!isdigit('5'))  return -1;
    if (!isalpha('A'))  return -2;
    if (!isalnum('Z'))  return -3;
    if (!isxdigit('F')) return -4;
    if (toupper('a') != 'A')  return -5;
    if (tolower('Z') != 'z')  return -6;
    if (!isspace(' '))  return -7;
    if (!ispunct('!'))  return -8;
    if (!isprint('~'))  return -9;
    return 0;
}

static int test_limits(void)
{
    if (INT_MAX   !=  2147483647) return -1;
    if (INT_MIN   != -2147483648) return -2;
    if (UINT32_MAX != 4294967295U) return -3;
    if (CHAR_BIT  != 8) return -4;
    if (sizeof(int) != 4) return -5;
    if (sizeof(void*) != 4) return -6;   /* 32-bit ARM */
    return 0;
}

int main(void)
{
    volatile int result = 0;
    volatile uint32_t magic __attribute__((unused)) = 0xDEADBEEF;

    result = test_string();      if (result == 0) test_passed++; else test_failed++;
    result = test_stdlib();      if (result == 0) test_passed++; else test_failed++;
    result = test_math();        if (result == 0) test_passed++; else test_failed++;
    result = test_ctypes();      if (result == 0) test_passed++; else test_failed++;
    result = test_limits();      if (result == 0) test_passed++; else test_failed++;

    /* Keep compiler from optimizing away our tests */
    if (test_passed == 5) magic = 0x600DF00D;

    while (1) {
        __asm__("nop");
    }
}

