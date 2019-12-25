#ifndef __IVW_DEMO_H__
#define __IVW_DEMO_H__

#include <stdio.h>
#include <string>
#include <sys/stat.h>
#include <errno.h>
#include <stdlib.h>

enum {
	WIVW_SUCCESS = 0,
};

#define CHECK_API_NOT_NULL(func) if(func == NULL)\
{\
	printf("%s is NULL\n",#func);\
	return -1;\
}

#define CHECK_FUNC_IF_SUCCESS(exp,func) if(!exp)\
{\
	printf("%s Failed!\n",#func);\
	return -1;\
}

#if WIN32
#include <Windows.h>
#else
#include <dlfcn.h>
#define HANDLE 				void*
#define HMODULE	            void*
static HMODULE LoadLibraryA(const char* file)
{
	std::string normalized_file = file;
	int pos = -1;
	pos = normalized_file.rfind('.', -1);
	if( normalized_file.substr(pos, -1) != ".so")
	{
		normalized_file = normalized_file.substr(0, pos) + ".so";
	}
	HMODULE handle = dlopen(normalized_file.c_str(), RTLD_LAZY);
	if(char* err = dlerror())
	{
		if(err)
		{
			printf("load dll %s with err %s\n", normalized_file.c_str(), err);
		}
		//assert(0 && "dll open err");
		return 0;
	}
	return handle;
}

static void* GetProcAddress(HMODULE handle, const char* procAddress)
{
	void* p = dlsym(handle, procAddress);
	char *errp =dlerror();
	if(errp)
	{
		return 0;
	}
	return p;
}

static void FreeLibrary(HMODULE handle)
{
	dlclose(handle);
}

#endif //WIN32

int last_error(void)
{
#if defined(WIN32)
	return ::GetLastError();
#else	// nonwin
	return errno;
#endif	// nonwin
}
int read_bin_file (const char * file, void * data, size_t bytes, size_t * readed  = 0)
{
	FILE * fp = fopen(file, "rb");
	if ( fp != 0 )
	{
		size_t rs = fread(data, 1, bytes, fp);
		if ( readed )
			*readed = rs;
		fclose(fp);
		return 0;
	}

	return last_error();
}
size_t get_file_size(const char* file)
{
	size_t size = 0;
#ifdef _WIN64
	struct __stat64 si;
#endif
	if ( file != 0 )
	{
#ifdef _WIN64
		int ret = ::_stat64(file, &si);
		if ( ret == 0 )
			size = si.st_size;
#else
		FILE * pTest = fopen(file,"r");
		if(pTest != NULL)
		{
			fseek(pTest, 0, SEEK_END);
			size = ftell(pTest);
			fclose(pTest);
		}
		else
		{	
			size = 0;
		}
#endif

	}
	return size;
}

#endif //__IVW_DEMO_H__
