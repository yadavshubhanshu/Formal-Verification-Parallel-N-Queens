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
