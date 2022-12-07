#include <stdio.h>
#include <stdlib.h>

#define MAXBUFSIZE 65536
typedef unsigned char byte;

void printHeader(char *filename){
  printf("-------------------------------------------------------------------------------\n");
  printf("-- obj_code_pkg.vhdl -- Application object code in vhdl constant string format.\n");
  printf("-------------------------------------------------------------------------------\n");
  printf("-- Generated from \"%s\"\n", filename);
  printf("-------------------------------------------------------------------------------\n");
  printf("library ieee;\n");
  printf("use ieee.std_logic_1164.all;\n");
  printf("use ieee.numeric_std.all;\n");
  printf("\n");
  printf("-- Package with utility functions for handling SoC object code.\n");
  printf("use work.mcu80_pkg.all;\n");
  printf("\n");
  printf("package obj_code_pkg is\n");
  printf("\n");
  printf("-- Object code initialization constant.\n");
}

void printTrailer(){
  printf("  );\n");
  printf("\n");
  printf("end package obj_code_pkg;\n");
}

int main(int argc, char *argv[]){
  FILE *fp = stdin;
  byte *filename = NULL;

  byte *buf;
  int bufsize = MAXBUFSIZE;
  int filesize;

  int i;
  
  if(argc == 2){
    filename = argv[1];
  } else {
    fprintf(stderr, "usage: bin2vhdl(.exe) binfile\n");
    exit(1);
  }

  if( filename == NULL){
    fp = stdin;
  } else {
    if((fp = fopen(filename, "r")) == NULL){
      fprintf(stderr, "%s: Cannot open file '%s'\n", argv[0], filename);
      exit(1);
    }
  }

  if((buf = (byte *)malloc(bufsize)) == NULL){
    fprintf(stderr, "malloc() failed.\n");
    exit(1);
  }
  filesize = fread(buf, sizeof(byte), bufsize, fp);

  printHeader(filename);
  printf("constant object_code : obj_code_t(0 to %d) := (\n", filesize-1);
  for(i = 0; i < filesize; i++){
    if(i % 8 == 0){
      printf("  ");
    }
    printf("X\"%02x\"", buf[i]);
    if(i != filesize-1){
      printf(",");
    } else {
      printf(" ");
    }
    if(i % 8 == 7){
      printf(" -- %04x\n", i-7);
    }
  }
  printTrailer();
}

