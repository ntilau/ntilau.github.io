#include <stdio.h>
#include <stdlib.h>

/* Struttura per contenere i dati richiesti */

struct SNodo{
  int weight;
  int inf;
  struct SNodo * destro;
  struct SNodo * sinistro;
};

/* Prototipi di funzioni */

typedef struct SNodo TNodo;

TNodo * Costruisci(TNodo * albero,int valore);
void CalcolaSomma(TNodo *,int precedente);
int CalcolaMaxWeight(TNodo * albero);
int StampaPercorso(TNodo * albero, int max);
void Ordina(TNodo * albero, int * vettore);

// Dimensione del vettore da acquisre (dato del testo) */
#define SIZE 20

/* Programma principale */

int main()
{
  int i;
  int v[SIZE];
  int value;
  TNodo * albero = NULL;

  /* Leggiamo 20 elementi e inseriamoli nell'albero */
  for (i=0;i<SIZE;i++){
    printf("\nInserire l'elemento N. %d: ",i);
    scanf("%d",&value);
    albero = Costruisci(albero,value);
  }

  // calcolo la somma dei nodi (valore 'weight')
  CalcolaSomma(albero,0);

  // calcolo il max weight
  max = CalcolaMaxWeight(albero);

  // ora che so il max, stampo il percorso che contiene il nodo
  printf("Stampo il percorso che colelga la radice al nodo\n");
  StampaPercorso(albero, max);

  //ordino i nodi
  Ordina(albero, v);

  // li stampo
  for (i=0;i<SIZE;i++){
    printf("Elemento N. %d: %d\n",i, v[i]);
  }
  
  getchar(); getchar();
  return 0;

}

/* Funzione per creare l'albero */

TNodo * Costruisci(TNodo * albero,int valore)
{

  if (albero == NULL){
    albero = (TNodo *)malloc(sizeof(TNodo));
    albero->inf = valore;
    albero->destro = NULL;
    albero->sinistro = NULL;
    albero->weight = 0;
    return albero;
  }

  if (valore >= albero->inf)
    albero->destro = Costruisci(albero->destro,valore);
  else if (valore < albero->inf)
    albero->sinistro = costruisci(albero->sinistro,valore);

  return albero;
}


/* Funzione per calcolare albero->weight. Il valore 'precedente'
   rapresenta il valore di weight calcolato nel nodo padre rispetto al
   nodo 'albero'
*/

void CalcolaSomma(TNodo * albero,int precedente);
{
  if (albero == NULL)
    return;

  // il weight nel nodo corrente 'e quello del nodo sopra + inf
  albero->weight = precedente + albero->inf;

  // ripeto ricorsivamente per i nodi sottostanti
  CalcolaSomma(albero->sinistro,albero->weight);
  CalcolaSomma(albero->destro,albero->weight);
}


/* Funzione per calcolare il valore di weight MAX*/
int CalcolaMaxWeight(TNodo * albero)
{
  /* il max e' il piu' grande tra il valore di weight nel nodo
     corrente, quello del sottoalbero di destra, e quello del
     sottoalbero di sinistra */
  int max = albero->weight;
  int tmp;
  if (albero->sinistro) {
    tmp = CalcolaMaxWeight(albero->sinistro);
    if (tmp > max) max = tmp;
  }
  if (albero->destro) {
    tmp = CalcolaMaxWeight(albero->destro);
    if (tmp > max) max = tmp;
  }

  return max;
}

/* Funzione per stampare il percorso tra radice e nodo con max weight.
 La funzione restituisce 1 se il max sta nel sottoalbero esaminato,
 altrimenti restituisce zero. max e' il valore del max weight (cioe'
 quello da cui inizia il mio percorso) */
int StampaPercorso(TNodo * albero, int max)
{
  // variabile che e' != zero se ho trovato il max 
  int trovato = 0;

  /* Primo passo: torno a cercare il nodo con il valore di weight max
     (calcolato prima) */
  if (albero->weight == max) {
    // sono sul nodo corrispondente al max
    trovato = 1;
  }
  // guardo se il max e' in uno dei sottonodi
  if (StampaPercorso(albero->destro, max) > 0) trovato = 1;
  if (StampaPercorso(albero->sinistro, max) > 0) trovato = 1;

  /* se il max e' stato trovato (o nel nodo corrente, o in uno dei
     sottonodi), vuol dire che il nodo in esame sta sul percorso che
     congiunge la radice con il max. Quindi stampo il nodo */
  if (trovato)
    printf("percorso: inf=%d, weight=%d\n", alnero->inf, albero->weight);
  return trovato;
}

/* Funzione per immettere in un vettore crescente i valori dei nodi */
void Ordina(TNodo * albero, int * vettore);
{
  /* La variabile deve essere o statica (cioe' non variare tra una
     chiamata e l'altra), o globale (altra soluzione per ottenere lo
     stesso effetto) */
  static int inseriti = 0;

  if (albero == NULL) return;

  // faccio una visita simmetrica dell'albero
  Ordina(albero->sinistro, vettore);

  // inserisco il nodo corrente nel vettore
  vettore[inseriti] = abero->inf;
  inseriti++;

  // Ora l'altro nodo
  Ordina(albero->destro, vettore);
}






