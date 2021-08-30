# AccAltProj for RPCA
This is the Matlab code repo for a fast provable non-convex Robust Principal Component Analysis (RPCA) algorithm introduced in <a href=https://jmlr.org/papers/v20/18-022.html>[1]</a>, which has theoretical global linear convergence guarantee and high robustness in practice. 

###### To display math symbols properly, one may have to install a MathJax plugin. For example, [MathJax Plugin for Github](https://chrome.google.com/webstore/detail/mathjax-plugin-for-github/ioemnmodlmafdkllaclgeombjnmnbima?hl=en).

## Robust Principal Component Analysis
In this project, we focus on RPCA problem under fully observed setting, that is about separating a low rank matrix $L\in \mathbb{R}^{m\times n}$ and a sparse outlier matrix $S\in \mathbb{R}^{m\times n}$ from their sum $D = L + S$.

## Key Idea for Acceleration
Alternating projections is a minimization approach that has been successfully used in many fields. Naturally, for RPCA, we want to project between the sets $\mathcal{M} :=$ \{$ (L,S) | L\text{ is low rank}$ \} and $\mathcal{S} :=$ \{$(L,S) | S\text{ is sparse and } L + S =D$ \} for convergence, an earlier example of such approach is [2].

In our algorithm, we used a manifold tangent space projection $\mathcal{P}_T$ along with a very small singular value decomposition (SVD) to accelerate the projection onto the manifold $\mathcal{M}$. Our method of $L$ updating is a lot faster than using the full size truncated SVD, and is tied with the other state-of-the-art RPCA algorithms in terms of complexity, such as gradient decent based $L$ updating in [3].

When update $S$, we employ hard thresholding operator with selected threshold values per iteration. In terms of speed, ours are tied with [2], being the fastest $S$ updating method as we knew. Additionally, the selected threshold values are proved for supplying the desired sparsity for $S$ at each iterition under some nature conditions., that is projection onto the set $\mathcal{S}$ .

Together with the speed of $L$ updating, $S$ updating, and guaranteed global linear convergence, we proudly introduce this fast provable non-convex algorithm for fully observed RPCA, namely AccAltProj.

## Installation
Our algorithm uses the full size truncated SVD exactly once, during its initialization. However, this one-time usage has become the bottleneck of our speed comparing to the speed of the rest parts. We choose to use PROPACK to speed up this one-time full size truncated SVD. 

For running our code successfully, the user should download and install the "PROPACK for Matlab" package from http://sun.stanford.edu/~rmunk/PROPACK/. 

PROPACK should be installed under the same directory with the other AccAltProj codes. After installation, your directory should read like:
```
|-PROPACK
	|- Afunc.m
 	|- AtAfunc.m
	...
|- AccAltProj.m
|- trim.m
...
```
  
\*  If user wish not to install PROPACK, or the installation is incorrect, then the program will automatically use "svds" (a built-in truncated SVD function of Matlab) instead of "lansvd" (a truncated SVD function in PROPACK) in *AccAltProj.m* and *get_mu_kappa.m*. This will allow the user to run the algorithm without PROPACK installation, but may significantly impact the speed of initialization when the problem dimension is large.

\*\* In the current verion, the problem check the existence of PROPACK folder (e.g., line 40-45 in AccAltProj.m) before we call the functions from it. This folder checking is based on Windows system, Mac and Linux user may find troubles for the problem to check the PROPACK folder. The user should manually remove these lines of the code in this case, and add the correct path of PROPACK accordingly.  

\*\*\* User may download a completed AccAltProj package from my personal website, which includes all neccessary parts for running the algorithm directly, without extra installations.

## Warning for AMD CPU User
We found this code runs very slow on AMD CPUs with earlier versions of Matlab. For best experience, please use this code on Intel CPU based computer, and update Matlab to the latest version.

We suspect earier Matlab versions didn't optimize for the AVX instruction sets of AMD CUPs. We welcome you to provide more data points of running AccAltProj on AMD CPUs with different Matlab versions, so we can figure out exactly why there is latency with AMD CPUs. 

Update: We learned that, Matlab calls AVX2 instruction sets for Intel CPU, but calls legacy SSE instruction sets for AMD CPU. While the QR decomp steps in our method have significate prefermence drop with SSE instruction sets, the workaround for AMD user is to active AVX2 for matlab. Read https://www.mathworks.com/matlabcentral/answers/396296-what-if-anything-can-be-done-to-optimize-performance-for-modern-amd-cpu-s?s_tid=ab_old_mlc_ans_email_view for more details.

## Syntex
Using all default parameters:
```
[L, S] = AccAltProj( D, r, '' );
```

Using custom parameters:
```
para.mu        = [5,10];
para.beta_init = 0.8;
para.beta      = 0.4;
para.trimming  = true;
para.tol       = 1e-10;
para.gamma     = 0.6;
para.max_iter  = 100;
[L, S] = AccAltProj( D, r, para );
```

## Input Description
1. D : Observed matrix. Sum of underlying low rank matrix and underlying sparse matrix.
1. r : Target rank of underlying low rank matrix.
1. params : parameters for the algorithm.
	* .max_iter : Maximum number of iterations. (default 50)
	* .tol : Desired Frobenius norm error. (default 1e-5)
	* .beta_init : Parameter for thresholding at initialization. (default 4\*beta)
	* .beta : Parameter for thresholding. (default 1/(2\*nthroot(m\*n,4)))
	* .gamma : Parameter for desired convergence rate. Value should between 0.3 and 1 (exclude 1 itself). Turn this parameter bigger will slow the convergence speed but tolerate harder problem, such as higher $\alpha$, $r$ or $\mu$. In the extreme cases, our algorithm can recover from a 92% corrupted $D$ by setting gamma = 0.95 (default 0.5)   
	* .trimming : Determine whether using trimming step. (default false)
	* .mu : Incoherence of underlying low rank matrix. Input can be in format of .mu = mu_max, or .mu = [mu_U, mu_V]. (default 5)

## Output Description
1. L : The estimated low-rank component of $D$.
1. S : The estimated sparse component of $D$.

## Demo
Clone the codes and install PROPACK. Your directory should read as 
```
|-PROPACK
	|- Afunc.m
 	|- AtAfunc.m
	...
|- AccAltProj.m
|- get_mu_kappa.m
|- test_AccAltProj.m
|- trim.m
```
You may run the demo file *test_AccAltProj.m* directly from here. It contains 2 demos, one for default parameters (without trim), another for custom parameters based on the properties of ground truth (with trim).

The file *get_mu_kappa.m* yields the properties of true $L$, this is used for parameters turning propose only. In reality, the user needs to estimate these properties if wishes to use custom $\mu$ and $\beta$.

## Reference
[1] HanQin Cai, Jian-Feng Cai, and Ke Wei. Accelerated alternating projections for robust principal component analysis. *Journal of Machine Learning Research* 20(1), 685-717, 2019.

[2] Praneeth Netrapalli, UN Niranjan, Sujay Sanghavi, Animashree Anandkumar, and Prateek Jain. Non-convex robust PCA. *In Advances in Neural Information Processing Systems*, 1107–1115, 2014.

[3] Xinyang Yi, Dohyung Park, Yudong Chen, and Constantine Caramanis. Fast algorithms for robust PCA via gradient descent. *In Advances in Neural Information Processing Systems*, 4152–4160, 2016.
