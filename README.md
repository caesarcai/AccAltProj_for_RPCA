# AccAltProj for RPCA
This is the Matlab code repo for a fast provable non-convex Robust Principal Component Analysis (RPCA) algorithm introduced in [1], which has theoretical global linear convergence guarantee and high robustness in practice. 

## Robust Principal Component Analysis
In this project, we focus on RPCA problem under fully observed setting, that is about separating a low rank matrix $L$ and a sparse outlier matrix $S$ from their sum $D = L + S$.

## Key Idea for Acceleration
Alternating projections is a minimization approach that has been successfully used in many fields. Naturally, for RPCA, we want to project between the sets $\mathcal{M} := \{ (L,S) | L\text{ is low rank} \}$ and $\mathcal{S} := \{(L,S) | S\text{ is sparse and } L + S =D\}$ for convergence, an earlier example of such approach is [2].

In our algorithm, we used a manifold tangent space projection $\mathcal{P}_T$ along with a very small singular value decomposition (SVD) to accelerate the projection onto the manifold $\mathcal{M}$. Our method of L updating is a lot faster than using the full size truncated SVD, and is tied with the other state-of-the-art RPCA algorithms in terms of complexity, such as gradient decent based L updating in [3].

When update $S$, we employ hard thresholding operator with selected threshold values per iteration. In terms of speed, ours are tied with [1], being the fastest $S$ updating method so far. Additionally, the selected threshold values are proved for supplying the desired sparsity for $S$ at each iterition under some nature conditions., that is projection onto the set $\mathcal{S}$ .

Together with the speed of $L$ updating, $S$ updating, and guaranteed global linear convergence, we proudly introduce this fast provable non-convex algorithm for fully observed RPCA, namely AccAltProj.

## Installation
Our algorithm uses the full size truncated SVD exactly once, during its initialization. However, this one-time usage has become the bottleneck of our speed comparing to the speed of the rest parts. We choose to use PROPACK to speed up this one-time full size truncated SVD. 

For run our code successfully, the user should download and  install the PROPACK for Matlab package from http://sun.stanford.edu/~rmunk/PROPACK/. 

PROPACK should be installed under the same directory with the other AccAltProj codes. After installation, your directory should read like:
```
	|-PROPACK
		|- Afunc.m
 	   	|- AtAfunc.m
		etc.
	|- AccAltProj.m
	|- get_mu_kappa.m
	|- trim.m
```
  
\*  If user wish not to install PROPACK, they may change "lansvd" to "svds" on line 105 and 110 of AccAltProj.m. This will allow the user to run the algorithm without PROPACK installation, but may significantly impact the speed of initialization.

\*\* User may download a completed AccAltProj package from my personal website, which includes all neccessary parts for running the algorithm directly, without extra installations.


## Syntex

## Input Description and Parameters Turning

## Output Description

## Warning for AMD CPU Users

## Demo

## Reference
[1] HanQin Cai, Jian-Feng Cai, and Ke Wei. Accelerated Alternating Projections for Robust Principal Component Analysis. Journal of Machine Learning Research, accepted with minor revision.

[2] Praneeth Netrapalli, UN Niranjan, Sujay Sanghavi, Animashree Anandkumar, and Prateek Jain. Non-convex robust PCA. In Advances in Neural Information Processing Systems, pages 1107–1115, 2014.

[3] Xinyang Yi, Dohyung Park, Yudong Chen, and Constantine Caramanis. Fast algorithms for robust PCA via gradient descent. In Advances in neural information processing systems, pages 4152–4160, 2016.
