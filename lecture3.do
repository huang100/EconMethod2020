// 读入数据
use mus03data.dta, clear

// 变量描述
describe totexp ltotexp posexp suppins phylim actlim totchr age female income

sum totexp ltotexp posexp suppins phylim actlim totchr age female income

** 仔细看一下这些变量的编码，有没有什么问题？

tabulate income if income <= 0

/*
Only one observation is negative, and negative income is possible for income from self- employment or investment.
We include the observation in the analysis here, though checking the original data source may be warranted.  
*/

// Plots
hist totexp

kdensity totexp

summarize totexp, detail

// 列联表
tabulate female suppins, row chi2

** 性别和购买私人保险有没有关系？对我们的研究问题可能会产生怎样的影响？

// Three-way table
table female totchr suppins

// 统计表
tabstat totexp ltotexp, stat (count mean p50 sd skew kurt) col(stat) 

** 解释这些统计量

// Pairwise correlations for dependent variable and regressor variables
correlate ltotexp suppins phylim actlim totchr age female income 

// Regression in levels，对医疗花费的绝对值进行回归
reg totexp suppins phylim actlim totchr age female income, vce(robust) 

/*
怎么解释suppins的系数？模型是否合理？
考虑咱们都没有保险，你现在的医疗费用是100元，我现在的医疗费用是10000元...
*/

// Regression in logs，对医疗花费的相对值进行回归
regress ltotexp suppins phylim actlim totchr age female income, vce(robust) 

/*
怎样解释suppins的系数？
半弹性，为什么？
*/

// Top-down (由复杂到简单) or bottom-up (由简单到复杂)
// 研究变量：保险
eststo m1: qui regress ltotexp suppins, vce(robust) 
// +人口学变量
eststo m2: qui regress ltotexp suppins age female, vce(robust) 
// +社会经济变量（SES）
eststo m3: qui regress ltotexp suppins age female income, vce(robust) 
// +疾病状况
eststo m4: qui regress ltotexp suppins age female income phylim actlim, vce(robust) 
esttab m1 m2 m3 m4, b(%10.3f) se star(* 0.1 ** 0.05 *** 0.01) scalars(N r2 ll) title("回归结果") 

/*
注意两个问题：
1. 新加入的变量是否显著
2. 新加入的变量是否会影响已经存在变量的估计
*/

regress totexp suppins phylim actlim i.totchr age female income, vce(robust)

test suppins

test 1.totchr 2.totchr 3.totchr 4.totchr 5.totchr 6.totchr 7.totchr

test 1.totchr = 2.totchr

test income = 0

test _b[female] = 0

test female = 0

// 回归后预测
qui regress ltotexp suppins phylim actlim totchr age female income
qui predict ltotexp_hat

// 预测效果
scatter ltotexp_hat ltotexp

/*
1. 预测效果如何？
2. 这样的预测是否符合实际？
*/

// 样本外预测
// 随机分组: 估计组/预测组
gen rand = runiform()
gen sample_split = 0
replace sample_split = 1 if rand >= 0.5
la var sample_split "1 if test sample"

// 使用一半样本进行模型拟合
qui regress ltotexp suppins phylim actlim totchr age female income if sample_split == 0

// 使用另一半样本进行预测
qui predict lfit_test if sample_split == 1

// 预测效果
scatter lfit_test ltotexp if sample_split == 1

// 边际效应
regress ltotexp suppins phylim actlim totchr age female income

margins, dydx(*)

/*
线性模型中，边际效应就是系数
因此，没有必要在回归后再计算边际
*/
