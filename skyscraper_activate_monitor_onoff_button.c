#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/io.h>

#define base 0x378

void main(){
    if (ioperm(base,1,1)){
        fprintf(stderr, "ERROR: Access denied to %x \n",base);
        exit(1);
    }
    char hostname[11];
    if (gethostname( hostname,11)!=0){
        fprintf( stderr, "ERROR: Could not get hostname.\n");
        exit(2);
    }
    if ( *hostname != *"skyscraper" ){
        fprintf(stderr, "ERROR: Wrong hostname: %s\n",hostname);
        exit(3);
    }
    outb(0b10000000,base);
    //printf("port state=%X\n",inb(base));
    sleep(1);
    outb(0b00000000,base);
    //printf("port state=%X\n",inb(base));
    exit(0);
}
