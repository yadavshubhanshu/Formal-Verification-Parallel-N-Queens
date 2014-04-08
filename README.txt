Formal verification of Parallel N-Queens problem turned out to be an interesting study as firstly
the problem is quite popular and interesting, secondly we wanted to verify concurrency using
formal verfication techniques.

N-Queens is a popular problem in which one has to find all possible configurations of placing
queens on a chess board in a way that no two queens attack each other. It is actually a
modification of the eight queens puzzle, we have just the number of queens to be a variable.

We created a parallel implementation of N-Queens in promela. The specifications of this
model are explained as below:
1) There would be M number of threads which would be creating unique configurations.
2) The configurations created would be put in a fixed sized channel.
3) The threads cannot add more configurations when the channel is full.
4) There would be N number of threads picking up configurations from the channel, each
picking one and validating the configuration. If the configuration is valid update the
result.
5) The threads cannot read if there are no elements in the channel.
6) Develop a locking machanism to ensure that the result is updated atomically. (We
developed Peterson's Lock).


The above specifications gave us the opportunity to verify a lot of properties. We verified
properties using LTL, developed property monitor, and used asserts.

1) parallelism_check (ltl property)
Check if the implementation is parallel in nature or not

2) config_check (ltl property)
Checks the total number of configurations.

3) result_check (ltl property)
Checks if the result is correct.

4) Atomicity verification
We did a Peterson's lock implementation for this purpose.

5) Unique configurations and valid configurations
This is a very important property to verify as it can directly affect the result. We
used a property monitor named config_monitor. This monitor checks the
uniqueness and valdity of the configurations with respect to the golden model.

6) Termination
All processes should terminate.

7) result_overflow (ltl property)
This property is to verify if the result variable has overfown its maximum limit

8) valid_input_check (ltl property)
It checks if the input, that is, the number of queens should be greater than 2.




There are two folders:

A) formal_verification_using_spin

 This is where you will find the parallel Nqueens model implemented by us on promela.

B) C_code_and_extracted_model_using_modex

 This is where you will find the C code implementation of parallel Nqueens and test harness file.

Steps to run and verify Parallel Nqueens using spin implementation(Open folder "formal_verification_using_spin"):

1) Install spin and ispin from http://spinroot.com/spin/whatispin.html
2) Open ispin. And load queen_parallel.pml file.
3) Open the queen_parallel.pml file.
4) Click the Verification tab.
5) Check the use claim flag.
6) Populate the claim name field using the ltl properties, namely:
   a) parallelism_check
   b) config_check
   c) result_check
   d) valid_input_check
   e) result_overflow

7) Click Run.

-O -DXVECTORZ=2048  //this flag should be added as the extra compile type options in the gcc to prevent overflowing of the memory


Steps to extract a promela model using modex and simulate using spin: (Open folder C_code_and_prx_using_modex).

1) Follow the instruction to install the required tools from the following link:
   http://spinroot.com/modex/

2) Copy the path of the "verify" script in the bin directory as specified in the above link.
3) Make sure you have NQuenns.c and NQuenns.prx in the same directory. NQuenns.c is the C implementation of Nqueens problem.
 And NQuenns.prx is the modex test harness file.
4) Run this command:
   $ verify NQuenns.prx
5) It should create a model file. This file is the promela model.
6) Now open ispin and load this file.
7) Click the simulate tab. And click "Run".
