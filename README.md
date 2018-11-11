This is the Matlab code repo for a super fast Robust Principal Component Analysis (RPCA) algorithm introduced in [1], which has theoretical global linear convergence guarantee and high robustness in practice. 

## Robust Principal Component Analysis
In this project, we focus on RPCA problem under fully observed setting, that is about separating a low rank matrix L and a sparse outlier matrix S from their sum D = L + S.

## Key Idea for Acceleration
Alternating projections is a minimization approach that has been successfully used in many fields. Naturely, for RPCA, we want to project between the sets \mathcal{L} := {(L,S) | L is low rank} and \mathcal{S} = {(L,S) | S is sparse & L + S =D} for convergence. 

In our algorithm, we used a manifold tangent space projection \mathcal{P}_T along with a very small singular value decomposition (SVD) to accelerate the projection onto \mathcal{L}. Our method of L updating is a lot faster than the full size truncated SVD in [2], and is tied with the other state-of-the-art RPCA algorithms in terms of complexity, such as gradient decent based L updating in [3].

When update S, we employ hard thresholding operator with selected threshold values per iteration. In terms of speed, ours are tied with [1], being the fastest S updating method so far. The selected threshold values are proved for supplying the desired sparsity for S under some nature conditions. While [3] uses a sparsification operator that also guarantees the sparsity of S at each iteration, their repeated partial sorting is not only time consuming, but also requires an accurate estimation of the sparsity of the underlaying S.

Together with the speed of L updating, S updating, and guaranteed global linear convergence, we are currently the fastest provable algorithm for fully observed RPCA.

## Syntex


## Reference
[1] HanQin Cai, Jian-Feng Cai, and Ke Wei. Accelerated Alternating Projections for Robust Principal Component Analysis. Journal of Machine Learning Research, accepted with minor revision.

[2] Praneeth Netrapalli, UN Niranjan, Sujay Sanghavi, Animashree Anandkumar, and Prateek Jain. Non-convex robust PCA. In Advances in Neural Information Processing Systems, pages 1107–1115, 2014.

[3] Xinyang Yi, Dohyung Park, Yudong Chen, and Constantine Caramanis. Fast algorithms for robust PCA via gradient descent. In Advances in neural information processing systems, pages 4152–4160, 2016.
