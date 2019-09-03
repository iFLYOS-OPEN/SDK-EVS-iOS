#include <memory>
#include <string>
namespace iflytek{
  class IFlytekWakeUp{
  public:
    IFlytekWakeUp(const char* resourcePath);
    ~IFlytekWakeUp();
    bool start();
    int detect(const int16_t* audio, int wordsCount);

  private:
    void* handle;
    void* insHandle;
    const std::string resPath;
    char RSLT[1025];
  };
}
