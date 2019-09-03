#ifndef __IVW_DEFINES_H__
#define __IVW_DEFINES_H__
#include <stddef.h>

#define IV_TYPE_INT64		long long	/* 64位数据类型 */

typedef	int					ivBool;		
typedef	signed char			ivInt8;		/* 8-bit */
typedef	unsigned char		ivUInt8;	/* 8-bit */
typedef	char				ivChar;		/* 8-bit */
typedef	unsigned char		ivUChar;	/* 8-bit */
typedef signed char*		ivPInt8;	/* 8-bit */
typedef void *				ivPointer;

typedef	signed short		ivInt16;	/* 16-bit */
typedef	unsigned short		ivUInt16;	/* 16-bit */
typedef	signed short		ivShort;	/* 16-bit */
typedef	unsigned short		ivUShort;	/* 16-bit */

typedef	signed int			ivInt32;	/* 32-bit */
typedef	unsigned int		ivUInt32;	/* 32-bit */
typedef	signed int			ivInt;		/* 32-bit */
typedef	unsigned int		ivUInt;		/* 32-bit */
typedef void				ivVoid;
typedef float				ivFloat;
typedef ivUInt16*			ivPUInt16;

typedef	 size_t				ivAddress; /* 地址数据类型 */
typedef size_t				ivSize;
#ifdef IV_TYPE_INT64
typedef	signed long long		ivInt64;	/* 64-bit */
typedef	unsigned long long 		ivUInt64;	/* 64-bit */
#endif

#endif