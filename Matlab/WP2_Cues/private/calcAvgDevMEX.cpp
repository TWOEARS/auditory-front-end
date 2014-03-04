#include <math.h>
#include "mex.h"
#include "string.h"

/* Helper functions */
#define max(x, y)   ((x) > (y) ? (x) : (y))
#define	min(A, B)	((A) < (B) ? (A) : (B))

/* Input Arguments */
#define   INPUT      	 prhs[0]  // input data 

/* Output Arguments */
#define   ADEV  	     plhs[0]  // Average deviation

void usage()
{
	mexPrintf("\n");		
	mexPrintf(" calcAvgDevMEX \n");		
	mexPrintf("		Calculates the average deviation of a distribution.\n");
	mexPrintf("\n");		
	mexPrintf(" USAGE \n");
	mexPrintf(" adev = calcAvgDevMEX(input)\n");                                     
	mexPrintf("\n");                                                                      
	mexPrintf(" INPUT ARGUMENTS\n");                                                                
	mexPrintf("     input : input data         [nSamples x nChannels]\n");            
	mexPrintf("\n"); 
	mexPrintf(" OUTPUT ARGUMENTS\n");                                                                
	mexPrintf("     adev  : average deviation  [1 x nChannels]\n");       
	mexPrintf("\n"); 
	mexPrintf(" Implementation by Tobias May © 2011, Philips Research Eindhoven \n");
	mexPrintf("\n"); 
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	double *input, *adev;
	double s, mean;
	int    nSamples, nChannels, hh, ii, exit = false;
	
  	/* Check for proper number of arguments */
  	if ((nrhs < 1) || (nlhs > 1)) {
    	usage();
    	exit = true;   
  	} 
  		
  	if(!exit){
  		/* Check the dimensions and type of INPUT */
	  	nSamples  = (int) mxGetM(INPUT);
  		nChannels = (int) mxGetN(INPUT);

	  	if (!mxIsNumeric(INPUT) || mxIsComplex(INPUT) || mxIsSparse(INPUT)  || !mxIsDouble(INPUT))
   			mexErrMsgTxt("calcAvgDevMEX requires a real input matrix of size [nSamples x nChannels].");
		
		/* Assign pointers and values to the various parameters*/
  		input = mxGetPr(INPUT);

		// Allocate memroy
        ADEV = mxCreateDoubleMatrix(1, nChannels, mxREAL);

        // Assign pointers
		adev = mxGetPr(ADEV);

     	/* Loop over all channels */
		for (hh=0; hh<nChannels; hh++){
			
			// Reset helper variables
			s = 0.0;
			
			// Get the mean
			for (ii=0; ii<nSamples; ii++) s+=input[ii+hh*nSamples];
				
			mean=s/nSamples;

			// Loop over all samples 
			for (ii=0; ii<nSamples; ii++){	
				adev[hh] += fabs(s=input[ii+hh*nSamples]-mean);
			}

			adev[hh] /= nSamples;
		}
  	}
}   /* end mexFunction() */

