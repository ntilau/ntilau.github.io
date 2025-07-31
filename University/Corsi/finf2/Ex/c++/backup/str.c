#include <string.h>
#include <stdio.h>

int main(void){
int i , s;
char Stringa[] = "Ntibarikure Lorenzo Laurent";
s = strlen(Stringa);
printf("\nLa stringa e lunga %d\n", s );
for( i = 0 ; i < s ; i++) printf("\nIl carattere %d e \"%c\"", i+1 , Stringa[i] );
printf("\nIl carattere %d invece e : %c", i+2 , Stringa[i+1]);

return 0;
}