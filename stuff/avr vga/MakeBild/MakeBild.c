// "Wegwerfprogramm", wandelt .BMP in Flash-Daten für VgaGen
#include <windows.h>

HANDLE hStdIn, hStdOut, hStdErr;

void _cdecl fprintf(HANDLE h, const char*t,...) {
 TCHAR buf[256];
 DWORD len;
 len=wvsprintf(buf,t,(va_list)(&t+1));
 if (h==hStdErr) {
  CharToOemBuff(buf,buf,len);
  WriteConsole(h,buf,len,&len,NULL);
 }else{
  WriteFile(h,buf,len,&len,NULL);
 }
}

struct{	// Grobstruktur der erwarteten .BMP-Datei
 BYTE header[54];
 BYTE palette[64];
 BYTE data[120][64];	// so herum!! (Zumindest für VisualC.)
 BYTE checker;		// ... um auf Dateiende zu prüfen
}BitmapData;

void _cdecl mainCRTStartup(){
 int x,y;
 DWORD br;
 hStdIn =GetStdHandle(STD_INPUT_HANDLE);
 hStdOut=GetStdHandle(STD_OUTPUT_HANDLE);
 hStdErr=GetStdHandle(STD_ERROR_HANDLE);
 if (!ReadFile(hStdIn,&BitmapData,sizeof(BitmapData),&br,NULL)) {
  fprintf(hStdErr,"Kann Eingabedaten nicht lesen!\n");
  ExitProcess(1);
 }
 if (br!=54+64+7680) {
  fprintf(hStdErr,"Eingabe-Bitmap zu %s (muss %d Bytes groß sein, 128x120x4)!\n",
    br<54+64+7680?"klein":"groß",54+64+7680);
  ExitProcess(1);
 }
 for (y=120; --y>=0;) {				// Y ist gestürzt
  for (x=0; x<64; x+=4) {
   DWORD v=*(DWORD*)&BitmapData.data[y][x];
   v=v>>4&0x0F0F0F0FUL|v<<4&0xF0F0F0F0UL;	// Nibbles tauschen
   fprintf(hStdOut,"%s0x%08X%s",x?"":".dd ",v,x<60?",":"\r\n");
  }
 }
 ExitProcess(0);
}
