#include <stdio.h>
#include <stddef.h>



struct Snodo {
	int inf;
	int level;
	struct Snodo *alb_sin;
	struct Snodo *alb_des;
};
typedef struct Snodo nodo;

#define SIZE 20

nodo * crea_vet(nodo *,int);
void livello(nodo *);
int *max_level(nodo *);
void visualizza (nodo *, int);


void main(){

nodo *albero = NULL;
int i, *max, valore;

//Inserimento dati vettore
for(i=0; i<SIZE; i++){
	printf("\nInserisci il %d valore ",i);
	scanf(" %d ",&valore);
	albero = crea_vet( albero, valore);

}

//Indetificazione dei livelli
livello(albero);
//Calcolo e stampa il livello massimo
max = max_level(albero);
printf("\nIl livello massimo e %d", *max);
//Visualizza per livelli
for(i=0;i<=*max ;i++){
visualizza(albero, i);
}

}


/*Creazione albero binario*/

nodo * crea_vet( nodo *p, int val){

if(p == NULL){
	p = (nodo *) malloc(sizeof(nodo));
	p->inf = val;
	p->level = 0;
	p->alb_sin = NULL;
	p->alb_des = NULL;
	return p;

}

if(val < p->inf){
	p->alb_sin = crea_vet(p->alb_sin,val);
}
else if(val >= p->inf){

	p->alb_des = crea_vet(p->alb_des,val);
}
return p;

}




void livello( nodo *p){

nodo *paus;
paus = p;
if(paus == NULL){
printf("Vettore vuoto");
return;
}
else{
	if(paus->alb_sin != NULL){
		paus->alb_sin->level = paus->level + 1;
		paus = paus->alb_sin;
		livello(paus);

	}
	if( paus->alb_des != NULL){
		paus->alb_des->level = paus->level + 1;
		paus = paus->alb_sin;
		livello(paus);
	}
}

}


int *max_level(nodo *p){

int *max;

if(*max < p->level) *max = p->level;
if(p->alb_sin != NULL) max=max_level(p->alb_sin);
if(p->alb_des != NULL) max=max_level(p->alb_des);

return max;

}



//funzione per visualizzare rispetto ai livelli

void visualizza(nodo *p, int val){

if(p->level == val) printf(" %d -> ", p->inf);
visualizza(p->alb_sin,val);
visualizza(p->alb_des,val);

}
