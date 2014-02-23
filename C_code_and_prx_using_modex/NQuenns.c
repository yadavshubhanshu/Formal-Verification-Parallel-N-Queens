#include<stdio.h>
#include<pthread.h>
#include<stdlib.h>
#include<string.h>
#include<errno.h>

#define QUEUE_EMPTY -1
#define OK 0
#define BLOCK_TIME 20

typedef struct queue_node{
                    int config_val;
                     struct queue_node *next;
                  }queue_node;

typedef struct queue{
              queue_node *front;
              queue_node *rear;
            }queue;


typedef struct thread_arg{
                     int **a;
                     int row;
                  }thread_arg;



unsigned int final_result = 0;
unsigned int N = 0;
pthread_mutex_t queue_mutex;
pthread_mutex_t result_mutex;
queue *q;
int enq = 0;
int dq = 0;

void enqueue(int val)
{
  queue_node *temp_node;
  temp_node = NULL;
  
  pthread_mutex_lock (&queue_mutex);  
  temp_node = (queue_node*) malloc(sizeof(queue_node));
  
  if(temp_node ==  NULL)
  {
    printf("Could not create a node\n");
    exit(-1);
  }
  
  temp_node->config_val = val;
  temp_node->next = NULL;
  
  if(q->front == NULL && q->rear == NULL)
  {
    q->front = temp_node;
    q->rear = temp_node;
  }
  else
  {
    q->rear->next = temp_node;
    q->rear = temp_node;
  }
 
  pthread_mutex_unlock (&queue_mutex);  
}


int dequeue(int *val)
{
  queue_node *temp_node = NULL;

  pthread_mutex_lock (&queue_mutex);  
  
  if(q->front == NULL)
  {
    pthread_mutex_unlock (&queue_mutex);
    return QUEUE_EMPTY;
  }
  
  if(q->front == q->rear)
  {
    *val = q->front->config_val;
    free(q->front);
    q->front = NULL;
    q->rear = NULL;
  }
  else
  {
    *val = q->front->config_val;
    temp_node = q->front;
    q->front = q->front->next;
    free(temp_node);
  }    
  
  pthread_mutex_unlock (&queue_mutex);  
  return OK; 
}

void blackout(int **a, int i, int j)
{
  //blackout the row
  
  int i1, j1;
  int g1,g2;
  for(g1 = 0; g1 < N; g1++)
  {
    *(*(a + i) + g1) = -1;
  }

  //blackout the column
  for(g2 = 0; g2 < N; g2++)
  {
     *(*(a + g2) + j) = -1;
  }

  //blackout the diagonal
  i1 = i;
  j1 = j;

  while(i1 >= 0 && j1 >= 0)
  {
     *(*(a + i1) + j1) = -1;
      i1--;
      j1--;
  }

  i1 = i;
  j1 = j;
  while(i1 <= N-1 && j1 <= N-1)
  {
    *(*(a + i1) + j1) = -1;
    i1++;
    j1++;
  }

  i1 = i;
  j1 = j;
  while(i1 >= 0 && j1 <= N-1)
  {
    *(*(a + i1) + j1) = -1;
     i1--;
     j1++;
  }

  i1 = i;
  j1 = j;
  while(i1 <= N-1 && j1 >= 0)
  {
    *(*(a + i1) + j1) = -1;
     i1++;
     j1--;
  }

}

void copy_board(int **a, int **temp)
{
  
 int i,j;
  for( i = 0; i < N; i++)
  {
    for( j = 0; j < N; j++)
    {
      *(*(temp + i) + j) = *(*(a + i) + j);
    }
  }
}

void config_iter(thread_arg* param)
{
  thread_arg arg;
  memset(&arg, 0, sizeof(thread_arg));

  int **a = NULL;
  int row;
  int **temp = NULL;
  int i,j;
  a = (param)->a;
  row = (param)->row;

  if(row == N-1)
  {
    int y;
    for( i = 0; i < N; i++)
    {
      if( *(*(a + N-1) + i) == 0)
      {
        pthread_mutex_lock (&result_mutex);  
        ++final_result; 
        pthread_mutex_unlock (&result_mutex);  
      }
    }
    
    for( y = 0; y < N; y++)
    {
      if((*(a+y)) != NULL)
      {  
        free(*(a + y));
        *(a + y) = NULL;
      }
    }
  }
  else
  {
    int y;
    for( j = 0; j < N; j++)
    {
      if(*(*(a + row) + j) == 0)
      {
        temp = (int**) malloc(sizeof(int*) * N);
        int k;
        for( k = 0; k < N; k++)
        {
          *(temp + k) = (int*) malloc(sizeof(int) * N);
        }
        
        copy_board(a, temp);
        blackout(temp, row, j);
        arg.a = temp;
        arg.row = row + 1; 
        config_iter(&arg);
        temp = NULL; 
      }
    }
  
    for( y = 0; y < N; y++)
    {
      if((*(a+y)) != NULL)
      {  
        free(*(a + y));
        *(a + y) = NULL;
      }
    }

  }
}

void config_finder()
{
  int v;
  int stat = QUEUE_EMPTY;
  int wait_time;
  int t = 0;
  thread_arg arg;
  memset(&arg, 0, sizeof(thread_arg)); 

  do
  {
    wait_time = BLOCK_TIME;   
    stat = dequeue(&v);
    if(stat == OK)
    {
      int **a = NULL;
      int k,i,j,t;
      a = (int**) malloc(sizeof(int*) * N);
      for ( k = 0; k < N; k++)
      {
        *(a + k) = (int*) malloc(sizeof(int) * N);
      }
       
      //Initialize the board
      for( i = 0; i < N; i++)
      {
        for( j = 0; j < N; j++)
        {
          *(*(a + i) + j) = 0;
        }
      } 
      
      blackout(a, 0, v);
     
      arg.a = a;
      arg.row = 1; 
      config_iter(&arg);
      break;
    }
    else
    {
      for(t=0; t<30; t++);
    }
  }while(1);

}


void config_init(int param)
{
  enqueue(param);
}


int main()
{
  /*if(argc < 2)
  {
    printf("Correct format <binary name> <Number of queens>\n");
    exit(-1);
  }*/
  
  //N = (unsigned int) atoi(argv[1]);
  
  
  N = 5;
  q = NULL;
  
  //nint size_of_struct = sizeof(struct queue);

  if(N < 0)
  {
    printf("only positive values accepted\n");
    exit(-1);
  }

  if(N == 0)
  {
    printf("Total number of possible configurations: 0\n");
    exit(-1);
  }
  
  if(N == 1)
  {
    printf("Total number of possible configurations: 1\n");
    exit(-1);
  }

  //pthread_t* threads = NULL;
  //pthread_t* config_thread = NULL;
  int ret;
  void **status = NULL;
  int i,k,j,l; 
  pthread_mutex_init(&queue_mutex, NULL);
  pthread_mutex_init(&result_mutex, NULL);
  
  //threads = (pthread_t*) malloc(N * sizeof(pthread_t));
  //config_thread = (pthread_t*) malloc(N * sizeof(pthread_t));
  
  q = (queue*) malloc(sizeof(queue));
  if(q == NULL)
  {
    printf("could not allocate q\n");
    exit(-1);
  }

  q->front = NULL;
  q->rear = NULL;

 /* if(threads == NULL || config_thread == NULL)
  {
    printf("error in allocating pthread_t handle\n");
    exit(-1);
  }*/

  for( i = 0; i < N; i++)
  {
    //ret = pthread_create((threads + i), NULL, config_finder, NULL);
    config_init(i);
  //  config_finder(NULL);
    /*if(ret)
    {
      printf("error in creating threads\n");
      exit(-1);
    }*/
  }
 
  for( k = 0; k < N; k++)
  {  
    //ret = pthread_create((config_thread + k), NULL, config_init , (void*)k);
  
    config_finder();
  /*  if(ret)
    {
      printf("error in creating thread\n");
      exit(-1);
    }*/
  }

  /*for( j = 0; j < N; j++) 
  {
    ret = pthread_join(*(threads + j), status);
    if (ret) 
    {
      printf("ERROR; return code from pthread_join() is %d\n", ret);
      exit(-1);
    } 
  } 
  
  
  for( l = 0; l < N; l++)
  { 
    ret = pthread_join(*(config_thread + l), status);

    if (ret) 
    {
      printf("ERROR; return code from pthread_join() is %d\n", ret);
      exit(-1);
    }
  }*/
  
  printf("Total number of possible configurations %d\n", final_result);
 // free(threads);
 // free(config_thread);
  pthread_mutex_destroy(&queue_mutex);
  pthread_mutex_destroy(&result_mutex);
  return 0;
  //pthread_exit(NULL); 
}
