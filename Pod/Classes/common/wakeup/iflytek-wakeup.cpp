#include <fstream>
#include <iostream>
#include <chrono>

#include "wivw_api.h"
#include "aes_api.h"
#include "iflytek-wakeup.h"

static const     IVW_RES_SET	resSet[4]={
  {100,"IVW_MLP"},
  {200,"IVW_FILLER"},
  {300,"IVW_KEYWORD"},
  {301,"IVW_KEYWORD"}
};


namespace iflytek{
  IFlytekWakeUp::IFlytekWakeUp(const char* resourcePath):
      handle{NULL},
      insHandle{NULL},
      resPath{std::string(resourcePath)} {
    IvwInterface* pMgr = NULL;
    auto ret = wIvwInitialize(&pMgr, NULL);
    if(ret != 0) {
      std::cout << "wIvwInitialize failed" << ret << std::endl;
    }
    handle = (void*)pMgr;
  }

  bool IFlytekWakeUp::start(){
    auto pMgr = (IvwInterface*)handle;

    std::string pathes[] = {
      "mlp.19.mid_nocmn.bin",
      "state_filler_3000s_kladi_1179.txt",
      "hotword1.irf",
      "hotword2.irf"
    };    

    for(auto i = 0; i < 4; i++){
      auto path = resPath + "/" + pathes[i];
      std::ifstream file(path, std::ios::binary | std::ios::ate);
      std::streamsize size = file.tellg();
      file.seekg(0, std::ios::beg);

      char* buf = new char[size];
      if (file.read(buf, size)){
	auto ret = pMgr->wIvwResourceAdd(resSet[i], buf, IVW_RES_LOCATION_MEM, size);
	if(ret != 0){
	  std::cout << "add " << path << "failed" << std::endl;
	  delete buf;
	  return false;
	}
      }else{
	std::cout << "read " << path << " failed" <<std::endl;
	delete buf;
	return false;
      }
      delete buf;
    }

//    auto ret = pMgr->wIvwResourceSetParameter(resSet[3], "wres_keyword_ncm", "0:100,1:200");
//    if(ret != 0){
//      std::cout << "set parameter failed:" << ret << std::endl;
//      return false;
//    }
    PIvwInstBase hIns = NULL;
    auto ret = pMgr->wIvwCreate(&hIns);
    if(ret != 0){
      std::cout << "wIvwCreate failed:" << ret << std::endl;
      return false;
    }
    insHandle = (void*)hIns;
    ret = hIns->wIvwSetParameter("wivw_param_sid", "./heixf.wav");
    if(ret != 0){
      std::cout << "wivw_param_sid failed:" << ret << std::endl;
      return false;
    }
    //returns 10006, WIVW_ERROR_INVALID_PARA, not known why. anyhow it running ok by comment it out
    //ret = hIns->wIvwSetParameter("wdec_param_nCMLevel", "-1");
    //if(ret != 0){
    //  std::cout << "wdec_param_nCMLevel failed:" << ret << std::endl;
    //  return false;
    //}

    ret = hIns->wIvwStart(resSet, 4);
    if(ret != 0){
      std::cout << "wIvwStart failed:" << ret << std::endl;
      return false;
    }    

    return true;
  }

  int IFlytekWakeUp::detect(const int16_t* audio, int wordsCount){
    if(insHandle == NULL){
      return -1;
    }    

    auto hIns = (PIvwInstBase)insHandle;
    auto ret = hIns->wIvwWrite((char*)audio, wordsCount * 2);
    if(ret != 0){
      std::cout << "wIvwWrite failed:" << ret << std::endl;
      return -1;
    }

    ivInt ivIntRet = 0;
    auto rsltRet = hIns->wIvwGetResult("rlt_wake_up", &RSLT[0], sizeof(RSLT), ivIntRet);
    if(ivIntRet){
      //"iresIndex":0,
      auto json = std::string(&RSLT[0]);
      
      if(json.find("\"iresIndex\":0") != std::string::npos){
	return 0;
      }

      if(json.find("\"iresIndex\":1") != std::string::npos){
	return 1;
      }
    }

    return -1;
  }

  IFlytekWakeUp::~IFlytekWakeUp(){
    if(insHandle != NULL){
      auto hIns = (PIvwInstBase)insHandle;
      auto pMgr = (IvwInterface*)handle;
      hIns->wIvwStop();
      pMgr->wIvwDestroy(hIns);
      pMgr->wIvwResourceDelete(resSet[0]);
      pMgr->wIvwResourceDelete(resSet[1]);
      pMgr->wIvwResourceDelete(resSet[2]);
      pMgr->wIvwResourceDelete(resSet[3]);
    }

    if(handle != NULL){
      auto pMgr = (IvwInterface*)handle;
      wIvwUninitialize(pMgr);
    }
  }
}


#if defined(TEST_PROG)
int main(int argc, char* argv[]){
  iflytek::IFlytekWakeUp ins(argv[1]);

  if(ins.start()){
    std::ifstream file(argv[2], std::ios::binary | std::ios::ate);
    std::streamsize size = file.tellg();
    file.seekg(0, std::ios::beg);

    char* buf = new char[size];
    if (file.read(buf, size)){
      for(int i = 0; i < size; i+=320){
	auto ret = ins.detect((int16_t*)&buf[i], 160);
	if(ret >= 0){
	  std::cout << "detected " << ret << std::endl;
	}
      }
    }else{
      std::cout << "can not open " << argv[2] << std::endl;
    }
    delete buf;
  }else{
    std::cout << "can not start engine" << std::endl;
  }

  return 0;
}
#endif
