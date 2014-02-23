/* Parallel Queen Implementation */
#define n 4
#define number_of_configurations 24
#define queue_length 3
#define correct_result 2
#define rx_threads 2
int track[n];
int streamCount=0;
int streamRecieve = 0;
int result = 0;

bool golden_model = 0;
int count1 = 0;
int config1 = 0;

typedef configurations {
	int config[n];
	bool end;
}
chan stream =[queue_length] of {configurations};
chan unique_chan = [queue_length] of {configurations};

ltl config_check {((golden_model==1)->(always (streamCount<=config1) && eventually (streamCount==config1)))}
ltl result_check {((golden_model==1)->(always (result<=count1) && eventually (result==count1)))}
ltl parallelism_check {eventually (_nr_pr>2)}
ltl valid_input_check {always (n>=2)}
ltl result_overflow {always (result>=0)}

proctype generatePermutations(int i){
	
	if
	:: (track[i]==0) -> track[i] = 1;printf("value of %d is %d",i,track[i]);
	:: else -> skip;
	fi;

	int rows[n];
	int cols[n];
	int cols_in_use[n+1];
	int col_num;
	int queen_num=0;
	int count = 0;	
	bool flag = 1;

	configurations data;
	
	cols[0] = i;
	int j = 0;
	do
	:: (j<n) -> rows[j] = j;j++;
	:: (j>=n) -> j=0;break;
	od;

	do
	:: (queen_num<n) -> cols_in_use[queen_num] = 1;queen_num++;
	:: (queen_num>=n) -> queen_num=0;break;
	od;

	if
	:: (cols[0]==0) -> cols[1] = 1;cols[2]=2;cols[3]=3;skip;
	:: (cols[0]==1) -> cols[1] = 0;cols[2]=2;cols[3]=3;skip;
	:: (cols[0]==2) -> cols[1] = 0;cols[2]=1;cols[3]=3;skip;
	:: (cols[0]==3) -> cols[1] = 0;cols[2]=1;cols[3]=2;skip;
	fi;
	int queenPosition = cols[0];
	int dummy=0;
	do
	:: (flag==1) ->
		count++;
		do
		:: (nfull(stream)) -> 
			i=0;
			do
			:: (i<n) -> data.config[i] = cols[i];i++
			:: (i>=n) -> data.end=0;atomic{stream!data;};i=0;streamCount++;break;
			od;
			break;
		//:: (full(stream)) -> printf("The stream count is %d",streamCount);
		od;


		queen_num=n-1;
		do
		:: (queen_num>=0) -> 
			cols_in_use[cols[queen_num]] = 0;
			cols[queen_num]++;
			do
			:: (cols_in_use[cols[queen_num]]==1) -> cols[queen_num]++;
			::(cols_in_use[cols[queen_num]]==0) -> break;
			od;

			if
			:: (cols[queen_num] < n) -> cols_in_use[cols[queen_num]] = 1;break;
			:: (cols[queen_num] >= n) -> printf("Hi\n");
			fi;
			queen_num--;
		:: (queen_num<0) -> break;
		od;

		if
		:: ((queen_num<0)||(cols[0]!=queenPosition)) ->  
			printf("No of solutions are %d ",count); break;
		::  else -> skip;
		fi;

		queen_num++;
		col_num =0;
		do
		:: (queen_num < n && col_num < n) -> 
			if
			:: (cols_in_use[col_num] == 0) ->
				cols_in_use[col_num] = 1;
        		cols[queen_num] = col_num;
        		queen_num++;
        	:: (cols_in_use[col_num] == 1) -> 
        		skip;
        	fi;
        	col_num++;

        :: (queen_num >= n || col_num >= n) -> break;
        od;
        i=0;
        do
        :: (i<n) -> printf("cols[%d] is %d ",i,cols[i]);i++;
        :: (i>=n) -> break;
        od;
        
    od;


}

proctype runPerms(){
	run generatePermutations(_pid%n);
}

proctype checkPerms(){
	configurations readData;

	bool is_safe = 1;
	int queen1 = 0;
	int queen2 = 0;
	int i=0;
	int rows[n];
	int cols[n];

	do
	:: (i<n) -> rows[i] = i;i++;
	:: (i>=n) -> i=0;break;
	od;


	bool turn, flag[2];
	byte ncrit;

	do
	::  (stream?[readData]) -> 
		stream?readData;
		streamRecieve++;
		is_safe = 1;
		queen1 = 0;
		queen2 = 0;
		i=0;
		do
		:: (i<n) -> cols[i] = readData.config[i];i++;
		:: (i>=n) -> i=0;break;
		od;


		do
		:: ((is_safe==1)&&(queen1<n)) ->
			queen2 = queen1+1;
			do
			:: ((is_safe==1)&&(queen2<n)) ->
				if
				:: (((rows[queen1]-rows[queen2]==cols[queen1]-cols[queen2])) || (((rows[queen1]-rows[queen2])==-(cols[queen1]-cols[queen2])))) ->
				is_safe = 0;
				:: else -> skip;
				fi;
				queen2++;
			:: ((is_safe==0)||(queen2>=n)) -> break;
			od;
			queen1++;
		:: ((is_safe==0)||(queen1>=n)) -> break;
		od;

	flag[_pid%2] = 1;
	turn = _pid%2;
	(flag[1 - _pid%2] == 0 || turn == 1 - _pid%2);

	ncrit++;
	assert(ncrit == 1);	/* critical section */
	
		if
		:: (is_safe==1) -> result++;
		:: (is_safe==0) -> result = result+0;skip;
		fi;	
	ncrit--;

	flag[_pid%2] = 0;


	od;

}



proctype config_monitor()
{

	configurations readConfig,unique_config[number_of_configurations];
	int possible_config[number_of_configurations];
	int size = 0;
	int i=0;
	

	do
	::  (unique_chan?[readConfig]) -> 
		unique_chan?readConfig;
		//number++;
	//:: else -> break;
	//od;
		i=0;
		do
		:: (i<n) -> 
					unique_config[size].config[i] = readConfig.config[i];
					
					i++;

		:: (i>=n) -> 
			i=0;size++;break;
		od;
		if
		:: (size>=number_of_configurations) -> break;
		:: else -> skip;
		fi;
	//:: else -> break;
	od;

	i=0;int j=0;
	do
	:: (i<n) ->
		


		j=i+1;
		do
		:: (j<n) ->
			
			int k=0;
			int l=0;
			do
			:: (k<n) -> 
				if
				:: (unique_config[i].config[k] == unique_config[j].config[k]) -> l++;
				:: else	 -> skip;
				fi;
				k++;
			:: else	-> break;
			od;
			atomic { !(l!=n) -> assert(false) }
			l=0;j++;
		:: else -> break;
		od;
		i++;
	:: else -> break;
	od;

	i=0;j=0;k=0;
	do
	:: (i<n) -> 
		do
		:: (j<n) ->
			k = j+1;
			do
			:: (k<n) -> 
				if
				:: (unique_config[i].config[j]==unique_config[i].config[k]) -> assert(false)
				::	else ->	 k++;skip;
				fi;
			:: else -> break;
			od;
			j++;
		:: else -> break;
		od;
		i++;
	:: else -> break;
	od;




}




proctype noPawns(){
	//int n = 4;
	int rows[n];
	int cols[n];
	int cols_in_use[n+1];
	int col_num;
	int i=0;
	bool flag = 1;

	do
	:: (i<n) -> rows[i] = i;cols[i] = i;i++;
	:: (i>=n) -> i=0;break;
	od;
	
	int queen_num=0;
	int queen1;
	int queen2;
    

    do
	:: (queen_num<n) -> cols_in_use[queen_num] = 1;queen_num++;
	:: (queen_num>=n) -> break;
	od;
	

	do
	:: (flag==1) ->  
		config1++;
		bool is_safe = 1;
		queen1 = 0;
		queen2 = 0;

		do
		:: ((is_safe==1)&&(queen1<n)) ->
			queen2 = queen1+1;
			do
			:: ((is_safe==1)&&(queen2<n)) ->
				if
				:: (((rows[queen1]-rows[queen2]==cols[queen1]-cols[queen2])) || (((rows[queen1]-rows[queen2])==-(cols[queen1]-cols[queen2])))) ->
				is_safe = 0;
				:: else -> skip;
				fi;
				queen2++;
			:: ((is_safe==0)||(queen2>=n)) -> break;
			od;
			queen1++;
		:: ((is_safe==0)||(queen1>=n)) -> break;
		od;
		

		if
		:: (is_safe==1) -> count1++;
		:: (is_safe==0) -> skip;
		fi;
	
		queen_num=n-1;
		do
		:: (queen_num>=0) -> 
			cols_in_use[cols[queen_num]] = 0;
			cols[queen_num]++;
			do
			:: (cols_in_use[cols[queen_num]]==1) -> cols[queen_num]++;
			::(cols_in_use[cols[queen_num]]==0) -> break;
			od;

			if
			:: (cols[queen_num] < n) -> cols_in_use[cols[queen_num]] = 1;break;
			:: (cols[queen_num] >= n) -> printf("Hi\n");
			fi;
			queen_num--;
		:: (queen_num<0) -> break;
		od;
	
		if
		:: (queen_num<0) ->  printf("Number of solutions are :  %d\n",count1);break;
		::  else -> skip;
		fi;

		queen_num++;
		col_num =0;
		do
		:: (queen_num < n && col_num < n) -> 
			if
			:: (cols_in_use[col_num] == 0) ->
				cols_in_use[col_num] = 1;
        		cols[queen_num] = col_num;
        		queen_num++;
        	:: (cols_in_use[col_num] == 1) -> 
        		skip;
        	fi;
        	col_num++;

        :: (queen_num >= n || col_num >= n) -> break;
        od;
    
	od;

}






init {
	
	pid process;
	process = _nr_pr;
  	run noPawns();
  	(process == _nr_pr);
  	printf("That value of count is %d ",count1);
  	golden_model = 1;
	int x = 0;
	do
	:: (x<n) -> run generatePermutations(x);x++;
	:: else -> x=0;break;
	od;

	do
	:: (x<rx_threads) -> run checkPerms();x++;
	:: else -> break;
	od;
	run config_monitor();




}
