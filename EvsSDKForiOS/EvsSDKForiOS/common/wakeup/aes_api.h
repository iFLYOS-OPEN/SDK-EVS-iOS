#ifndef __AES_API_H__
#define __AES_API_H__
#include "ivw_defines.h"
#if defined(_MSC_VER)                 /* Microsoft Visual C++ */
#	if !defined(WAESAPI) || !defined(WAESAPITYPE)
#		define WAESAPI __stdcall
#		define WAESAPITYPE __stdcall
#	endif
#	pragma pack(push, 8)
#else                                          /* Any other including Unix */
#	if !defined(WAESAPI) || !defined(WAESAPITYPE)
#		define WAESAPI  __attribute__ ((visibility("default")))
#		define WAESAPITYPE
#	endif
#endif


class  AesEncDecInst
{
public:
	AesEncDecInst(ivInt, ivInt){};
	AesEncDecInst(){};
	virtual ~AesEncDecInst(){};
	virtual ivInt aes_encode(const ivChar* srcString, ivInt srcLen, ivChar* pEncode, ivInt* pDesSize) =0;
	virtual ivInt aes_decode(const ivChar* srcString, ivChar* pDecode, ivInt* pDesSize) =0;
	virtual ivVoid xor_encode(ivChar *pSrc, ivInt nSrcSize) = 0;
};
typedef AesEncDecInst* pAesEncDecInst;

#ifdef __cplusplus
extern "C" {
#endif
	ivInt WAESAPI wAesCreateInst(pAesEncDecInst* pAesInst);
	typedef ivInt (WAESAPITYPE* Proc_wAesCreateInst)(pAesEncDecInst pAesInst);

	ivInt WAESAPI wAesDestroyInst(pAesEncDecInst pAesInst);
	typedef ivInt (WAESAPITYPE* Proc_wAesDestroyInst)(pAesEncDecInst pAesInst);

#ifdef __cplusplus
};
#endif

/* Reset the structure packing alignments for different compilers. */
#if defined(_MSC_VER)                /* Microsoft Visual C++ */
#	pragma pack(pop)
#endif

// ½âÂëÆ÷w_dec½Ó¿Ú
#define API_LIST_AES(func)\
	func(wAesCreateInst)\
	func(wAesDestroyInst)

#endif /* __AES_API_H__ */
