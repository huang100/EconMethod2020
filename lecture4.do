// 读入数据
use mus14data.dta, clear

// 生成新的变量
global xlist age hstatusg hhincome educyear married hisp
generate line = ln(hhinc)
global extralist line female white chronic adl sretire

// 描述统计
sum ins retire $xlist $extralist

hist hhincome

// 线性概率模型
reg ins retire $xlist, vce(robust)

// 样本内预测
predict pins
sum pins

/*
预测结果有什么问题？
*/

/*
Stata下我们可以选择的模型有
1. Probit regression
logit depvar [indepvars] [if] [m] [weight] [, options]

2. Logit (logistic) regression
probit depvar [indepvars] [if] [in] [weight] [, options]

3. LPM, linear probability model
reg depvar [indepvars] [if] [in] [weight] [, vce(robust) other options]
*/

// logit regression
logit ins retire $xlist

/*
系数大小有没有意义？
是否需要计算边际效果 marginal effect？
系数符号和边际效果符号是否一样？
*/

// probit regression
probit ins retire $xlist

// Estimation of several models
quietly logit ins retire $xlist
estimates store blogit
quietly probit ins retire $xlist
estimates store bprobit
quietly regress ins retire $xlist, vce(robust)
estimates store bols
* Table for comparing models
esttab blogit bprobit bols, se stats(N ll) star(* 0.1 ** 0.05 *** 0.01) mtitle("Logit" "Probit" "OLS") nonumber

// probit regression，odds ratio
logit ins retire $xlist, or

/*
如何解释OR值？
*/

/*
每个人的边际效应是不一样的，怎么解决？
1. Marginal effect at a representative value (MER)
2. Marginal effect at the mean (MEM)
3. Average marginal effect (AME)
*/

// 平均边际效应
// Average marginal effect (AME) after logit
quietly logit ins retire $xlist
*margins, dydx(retire)
margins, dydx(*)


// 对“代表人”取边际
// Marginal effects (MEM) after logit
quietly logit ins retire $xlist
*margins, dydx(retire) atmeans
margins, dydx(*) atmeans

* 注意stata输出信息

// 比较边际效应
quietly logit ins retire $xlist
margins, dydx(*) post
est store logit_AME
quietly logit ins retire $xlist
margins, dydx(*) atmeans post
est store logit_MEM
quietly probit ins retire $xlist
margins, dydx(*) post
est store probit_AME
quietly probit ins retire $xlist
margins, dydx(*) atmeans post
est store probit_MEM
quietly reg ins retire $xlist, vce(robust)
est store ols
esttab logit_AME logit_MEM probit_AME probit_MEM ols, ///
    se star(* 0.1 ** 0.05 *** 0.01) ///
    mtitle("Logit_AME" "Logit_MEM" "Probit_AME" "Probit_AME" "OLS") nonumber

// Wald test for zero interactions
cap drop age2 agefem agechr agewhi
generate age2 = age*age
generate agefem = age*female
generate agechr = age*chronic
generate agewhi = age*white
global intlist age2 agefem agechr agewhi
logit ins retire $xlist $intlist
test $intlist

// * Likelihood-ratio test
quietly logit ins retire $xlist $intlist
est store A
quietly logit ins retire $xlist
est store B
lrtest A B

/*
“承认”原假设：交叉项没有影响
*/

// 比较 Pseudo-R2 measure

logit ins retire $xlist
logit ins retire $xlist $extralist

// Comparing fitted probability and dichotomoiis outcome.
quietly logit ins retire $xlist
estat classification


