#ifndef __IVW_H__
#define __IVW_H__

#include "ivw_type.h"
#include "ivw_defines.h"

#if defined(_MSC_VER)                 /* Microsoft Visual C++ */
#	if !defined(IVWAPI) || !defined(IVWAPITYPE)
#		define IVWAPI __stdcall
#		define IVWAPITYPE __stdcall
#	endif
#	pragma pack(push, 8)
#else                                          /* Any other including Unix */
#	if !defined(IVWAPI) || !defined(IVWAPITYPE)
#		define IVWAPI  __attribute__ ((visibility("default")))
#		define IVWAPITYPE 
#	endif
#endif


#define API_LIST_IVW(func)\
	func(wIvwInitialize)\
	func(wIvwUninitialize)

#ifdef __cplusplus
extern "C" {
#endif
	ivInt IVWAPI wIvwInitialize(IvwInterface** ppIvwMgr,const ivChar *pWorkDir = NULL);
	typedef ivInt (IVWAPITYPE*Proc_wIvwInitialize)(IvwInterface** ppvwMgr,const ivChar* pWorkDir);

	ivInt IVWAPI  wIvwUninitialize(IvwInterface* pIvwMgr);
	typedef ivInt  (IVWAPITYPE*Proc_wIvwUninitialize)(IvwInterface* pIvwMgr);

#ifdef __cplusplus
};
#endif

#if defined(_MSC_VER)                /* Microsoft Visual C++ */
#	pragma pack(pop)
#endif

#endif /* __SAD_H__ */
