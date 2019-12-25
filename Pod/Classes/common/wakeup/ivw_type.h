#ifndef __IVW_TYPE_H__
#define __IVW_TYPE_H__
#include "ivw_defines.h"


struct IVW_RES_SET
{
	ivInt		nResID;
	ivChar		szType[16];
};
enum IVW_RES_LOCATION
{
	IVW_RES_LOCATION_FILE	= 0,
	IVW_RES_LOCATION_MEM	= 1,
	IVW_RES_LOCATION_NONE
};
enum{
	IVW_WRITE_CONTINUE = 0,
	IVW_WRITE_STOP,
};

typedef ivInt (*PIVWCallBack)(ivVoid* pUserParam, const ivChar* pIvwParam); 

class IvwInstBase
{
public:
	IvwInstBase(){}
	virtual ~IvwInstBase(){}
	virtual ivInt wIvwSetParameter(const ivChar* pParam, const ivChar* pParamValue)	= 0;
	virtual ivInt wIvwGetParameter(const ivChar* pParam, ivChar* pParamValue, ivInt nLen)	= 0;
    virtual ivInt wIvwGetResult(const ivChar* pParam, ivChar* pParamValue, ivInt nLen, ivInt& nRltLen)	= 0;
	virtual ivInt wIvwRegisterCallBacks(const ivChar* pFuncType, const PIVWCallBack pFunc, ivVoid* pUserParam)	= 0;
	virtual ivInt wIvwUnRegisterCallBacks(const ivChar* pFuncType)	= 0;
	virtual ivInt wIvwStart(const IVW_RES_SET* pResSet, ivInt nRes)	= 0;
	virtual ivInt wIvwStop() = 0;
	virtual ivInt wIvwWrite(const ivChar* pSamples, ivInt nLen, ivInt writeStatus=IVW_WRITE_CONTINUE) = 0;
};
typedef	IvwInstBase*	PIvwInstBase;

class IvwInterface
{
public:
	virtual ivInt wIvwCreate(PIvwInstBase* pWIvwInst)	= 0;
	virtual ivInt wIvwDestroy(PIvwInstBase wIvwInst)	= 0;
	virtual ivInt wIvwSetParam(const ivChar* pParam, const ivChar*pValue) = 0;
	virtual ivInt wIvwGetParam(const ivChar* pParam, ivChar* pValue, ivInt nLen) = 0;
	virtual ivInt wIvwResourceAdd(const IVW_RES_SET& resSet, const ivChar* pRes, IVW_RES_LOCATION eResLocation, ivUInt nResSize = 0,const IVW_RES_SET* pDependentRes = NULL, ivUInt resCount = 0) = 0;
	virtual ivInt wIvwResourceUpdate(const IVW_RES_SET& resSet, const ivChar* pRes, ivUInt nResSize,const IVW_RES_SET* pDependentRes = NULL, ivUInt resCount = 0)=0;
	virtual ivInt wIvwResourceSave(const IVW_RES_SET& resSet, ivChar* pRes, ivUInt maxLength, ivUInt& useLength)= 0;
	virtual ivInt wIvwResourceDelete(const IVW_RES_SET& resSet)																	= 0;
	virtual ivInt wIvwResourceSetParameter(const IVW_RES_SET& resSet, const ivChar* pParam, const ivChar* pValue)				= 0;
	virtual ivInt wIvwResourceGetParameter(const IVW_RES_SET& resSet, const ivChar* pParam, ivChar* pParamValue, ivInt nLen)	= 0;
	IvwInterface(){}
	virtual ~IvwInterface(){}
private:
	IvwInterface(IvwInterface const&){}           // copy ctor hidden
	IvwInterface& operator=(IvwInterface const&){return *this;}// assign op. hidden	
};
#endif